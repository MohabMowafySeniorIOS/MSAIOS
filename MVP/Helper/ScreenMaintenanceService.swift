//
//  ScreenMaintenanceService.swift
//  MSA
//
//  Per-screen maintenance switches, read live from Firestore.
//

import Foundation
import FirebaseFirestore

/// A screen that can be taken down on its own.
///
/// Each case owns its own set of keys inside the `appVersion` collection, so
/// every gated screen is independent of the others — and independent of
/// `iosneedMaintain`, which still blocks the whole app (see
/// `HomeVC.getAppVersion()`).
///
/// `home` and `dollar` use iOS-specific keys on purpose: Android reads
/// `homeMaintain` / `dollarMaintain` from the same document, so either screen
/// can be switched off on one platform without touching the other.
///
/// `federal`, `news` and `bullions` are the exceptions — they read the shared
/// `FedralliMaintain` / `NewsMaintain` / `BullionsMaintain`, which take those
/// screens down on both platforms at once. See `flagKey`.
enum MaintainedScreen {
    case home
    case dollar
    case federal
    case news
    case bullions

    /// Boolean flag that turns the screen off.
    ///
    /// `federal` is the odd one out: there is no `iosFedralliMaintain` in the
    /// console, so iOS and Android both read the same `FedralliMaintain` field
    /// and the screen goes down on both platforms together. Add the `ios`
    /// twin there and change this line if per-platform control is ever needed.
    ///
    /// "Fedralli" is spelled the way the console spells it. It is a typo, but
    /// the field already exists and renaming it would silently switch the
    /// screen back on for every build that still reads the old name.
    var flagKey: String {
        switch self {
        case .home:     return "ioshomeMaintain"
        case .dollar:   return "iosdollarMaintain"
        case .federal:  return "FedralliMaintain"
        case .news:     return "NewsMaintain"
        case .bullions: return "BullionsMaintain"
        }
    }

    /// Base key for the remote headline. Read as `<key>_ar` / `<key>_en`,
    /// then plain `<key>`, then the bundled translation.
    var titleKey: String {
        switch self {
        case .home:     return "homeMaintainTitle"
        case .dollar:   return "dollarMaintainTitle"
        case .federal:  return "FedralliMaintainTitle"
        case .news:     return "NewsMaintainTitle"
        case .bullions: return "BullionsMaintainTitle"
        }
    }

    /// Base key for the remote body copy — same lookup order as `titleKey`.
    var messageKey: String {
        switch self {
        case .home:     return "homeMaintainMessage"
        case .dollar:   return "dollarMaintainMessage"
        case .federal:  return "FedralliMaintainMessage"
        case .news:     return "NewsMaintainMessage"
        case .bullions: return "BullionsMaintainMessage"
        }
    }
}

/// Resolved state handed to the view layer, already in the user's language.
struct ScreenMaintenanceState {
    var isUnderMaintenance: Bool = false
    var title: String = ScreenMaintenanceService.defaultTitle
    var message: String = ScreenMaintenanceService.defaultMessage
}

/// Live listener on the `appVersion` collection.
///
/// It is a snapshot listener rather than a one-off `getDocuments`, so flipping
/// a flag in the Firebase console reaches a user who is *already sitting on*
/// the screen — the overlay slides in (or out) without a relaunch, matching how
/// `iosneedMaintain` already behaves.
///
/// One shared listener serves every observer; callers register with
/// `observe(_:owner:onChange:)` and are automatically dropped when their view
/// controller is deallocated.
final class ScreenMaintenanceService {

    static let shared = ScreenMaintenanceService()

    /// Bundled fallbacks — translated in ar.lproj / en.lproj / ur.lproj.
    static var defaultTitle: String { "maintenance_screen_title".localized }
    static var defaultMessage: String { "maintenance_screen_message".localized }

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// Latest merged payload of every document in the `appVersion` collection.
    /// Merged (rather than "first document") because the existing iOS code
    /// iterates the whole collection too — this keeps working whatever the
    /// document is named.
    private var latestData: [String: Any] = [:]

    /// Weak-boxed subscribers, so a dismissed screen can't keep itself alive.
    private final class Subscription {
        let screen: MaintainedScreen
        weak var owner: AnyObject?
        let onChange: (ScreenMaintenanceState) -> Void

        init(screen: MaintainedScreen,
             owner: AnyObject?,
             onChange: @escaping (ScreenMaintenanceState) -> Void) {
            self.screen = screen
            self.owner = owner
            self.onChange = onChange
        }
    }

    private var subscriptions: [Subscription] = []

    private init() {}

    /// Current state for a screen, computed from the last snapshot received.
    func state(for screen: MaintainedScreen) -> ScreenMaintenanceState {
        var state = ScreenMaintenanceState()
        state.isUnderMaintenance = latestData[screen.flagKey] as? Bool ?? false

        if let title = localizedValue(forKey: screen.titleKey) {
            state.title = title
        }
        if let message = localizedValue(forKey: screen.messageKey) {
            state.message = message
        }
        return state
    }

    /// Picks the copy that matches the app language, mirroring how the rest of
    /// the app reads Firestore text (`title_ar` / `title_en`).
    ///
    /// Lookup order: current language → the other language → the un-suffixed
    /// key (so a document written before the copy was split still works).
    /// Returns `nil` when nothing usable is set, which leaves the bundled
    /// translation in place. Urdu falls back to the English field, since the
    /// console only carries `_ar` / `_en`.
    private func localizedValue(forKey key: String) -> String? {
        let isArabic = L102Language.currentAppleLanguage() == "ar"
        let preferred = isArabic ? "\(key)_ar" : "\(key)_en"
        let secondary = isArabic ? "\(key)_en" : "\(key)_ar"

        for candidate in [preferred, secondary, key] {
            if let value = latestData[candidate] as? String,
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value
            }
        }
        return nil
    }

    /// Subscribe a view controller to one screen's flag.
    ///
    /// `onChange` fires immediately with whatever is already cached (so a screen
    /// opened after the first snapshot doesn't flash un-gated content), then again
    /// on every remote change.
    func observe(_ screen: MaintainedScreen,
                 owner: AnyObject,
                 onChange: @escaping (ScreenMaintenanceState) -> Void) {

        subscriptions.append(Subscription(screen: screen, owner: owner, onChange: onChange))
        startListeningIfNeeded()

        // Deliver the cached value right away.
        onChange(state(for: screen))
    }

    /// Drop every subscription belonging to `owner` (call from `deinit`).
    func stopObserving(owner: AnyObject) {
        subscriptions.removeAll { $0.owner == nil || $0.owner === owner }
    }

    private func startListeningIfNeeded() {
        guard listener == nil else { return }

        listener = db.collection("appVersion").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("ScreenMaintenanceService listener error:", error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else { return }

            var merged: [String: Any] = [:]
            for document in documents {
                document.data().forEach { merged[$0.key] = $0.value }
            }
            self.latestData = merged
            self.notifySubscribers()
        }
    }

    private func notifySubscribers() {
        // Prune anything whose owner is gone before dispatching.
        subscriptions.removeAll { $0.owner == nil }

        let snapshotOfSubs = subscriptions
        DispatchQueue.main.async {
            for sub in snapshotOfSubs where sub.owner != nil {
                sub.onChange(self.state(for: sub.screen))
            }
        }
    }
}
