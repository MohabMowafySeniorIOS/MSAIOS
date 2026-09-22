//
//  ScreenMaintenanceView.swift
//  MSA
//
//  Placeholder shown over a single screen that is under maintenance.
//

import UIKit
import SwiftUI

/// Covers one screen's content while its Firestore flag is on.
///
/// Built in code on purpose — it's added straight onto a view controller's
/// `view`, which sits *inside* the tab bar controller, so the tab bar stays
/// visible and tappable underneath. That's the difference from `UpdateAppVC`,
/// which hides the tab bar and traps the user.
final class ScreenMaintenanceView: UIView {

    private let card = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    // MARK: - Init

    init(title: String, message: String) {
        super.init(frame: .zero)
        setupUI()
        configure(title: title, message: message)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// Updates the copy in place — used when the text changes remotely while
    /// the overlay is already on screen.
    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }

    // MARK: - Layout

    private func setupUI() {
        backgroundColor = UIColor(named: "BlackColor") ?? UIColor(red: 0.137, green: 0.098, blue: 0.094, alpha: 1)
        isUserInteractionEnabled = true   // swallow taps meant for the hidden content

        // Same subtle texture the rest of the app uses, if it's in the catalogue.
        if let bg = UIImage(named: "BGImage") {
            let bgView = UIImageView(image: bg)
            bgView.contentMode = .scaleAspectFill
            bgView.alpha = 0.15
            bgView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bgView)
            NSLayoutConstraint.activate([
                bgView.topAnchor.constraint(equalTo: topAnchor),
                bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
                bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
                bgView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 1, alpha: 0.08)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.85, green: 0.75, blue: 0.54, alpha: 0.5).cgColor
        addSubview(card)

        iconLabel.text = "🛠️"
        iconLabel.font = .systemFont(ofSize: 52)
        iconLabel.textAlignment = .center

        titleLabel.font = UIFont(name: "\(FontfamilyName)-Bold", size: 20)
            ?? .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.font = UIFont(name: "\(FontfamilyName)-Regular", size: 15)
            ?? .systemFont(ofSize: 15)
        messageLabel.textColor = UIColor(white: 0.8, alpha: 1)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconLabel, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        stack.setCustomSpacing(18, after: iconLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - Attaching the overlay to a screen

extension UIViewController {

    private static let maintenanceOverlayTag = 987_612

    /// Binds this view controller to one screen's Firestore flag.
    ///
    /// Call once from `viewDidLoad`. The overlay is added and removed on its
    /// own as the flag changes remotely, and the subscription is dropped when
    /// the controller goes away.
    /// - Parameter onLive: fires whenever the screen resolves to *not* under
    ///   maintenance — including the first, cached resolution. Use it to start
    ///   loading, so a gated screen never hits the network behind the card.
    ///   Guard it with your own "already loaded" flag; it can fire more than
    ///   once if the flag is toggled.
    func bindScreenMaintenance(_ screen: MaintainedScreen, onLive: (() -> Void)? = nil) {
        ScreenMaintenanceService.shared.observe(screen, owner: self) { [weak self] state in
            guard let self = self else { return }
            if state.isUnderMaintenance {
                self.showMaintenanceOverlay(title: state.title, message: state.message)
            } else {
                self.hideMaintenanceOverlay()
                onLive?()
            }
        }
    }

    private var maintenanceOverlay: ScreenMaintenanceView? {
        view.viewWithTag(UIViewController.maintenanceOverlayTag) as? ScreenMaintenanceView
    }

    func showMaintenanceOverlay(title: String, message: String) {
        // Already up — just refresh the copy.
        if let existing = maintenanceOverlay {
            existing.configure(title: title, message: message)
            view.bringSubviewToFront(existing)
            return
        }

        /*
         أي لودر شغّال لازم يقف.

         `lock()` بتضيف مؤشر تحميل كـsubview و`addSubview` بتحطه
         **فوق** الغطا، فالمستخدم كان بيشوف مؤشر بيلف في نص كارت
         «في صيانة». وطلب معلّق معناه المؤشر ده ممكن ما يختفيش أبداً.
         */
        unlock()

        let overlay = ScreenMaintenanceView(title: title, message: message)
        overlay.tag = UIViewController.maintenanceOverlayTag
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.alpha = 0
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        UIView.animate(withDuration: 0.25) { overlay.alpha = 1 }
    }

    func hideMaintenanceOverlay() {
        guard let overlay = maintenanceOverlay else { return }
        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
        })
    }
}

// MARK: - SwiftUI

/// Watches one screen's flag for a SwiftUI view.
///
/// The UIKit path above (`bindScreenMaintenance`) covers a view controller's
/// whole `view`, which is right for a tab: the tab bar sits outside it and
/// stays tappable. A pushed SwiftUI screen draws its own header **inside** the
/// same view, so covering everything would take the back button with it and
/// strand the user. Screens like the Fed calendar observe through this object
/// instead and swap only their body.
final class ScreenMaintenanceObserver: ObservableObject {

    @Published private(set) var state = ScreenMaintenanceState()

    init(_ screen: MaintainedScreen) {
        // Fires straight away with whatever is cached, then on every change,
        // so the screen never flashes un-gated content on the way in.
        ScreenMaintenanceService.shared.observe(screen, owner: self) { [weak self] newState in
            self?.state = newState
        }
    }

    deinit {
        ScreenMaintenanceService.shared.stopObserving(owner: self)
    }
}

/// The same card `ScreenMaintenanceView` draws, in SwiftUI.
///
/// Kept visually identical on purpose — a user who sees the maintenance notice
/// on Home and then on the Fed screen should recognise it as the same message,
/// not wonder whether something else broke.
struct ScreenMaintenanceCardView: View {

    let title: String
    let message: String

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Text("\u{1F6E0}\u{FE0F}")
                    .font(.system(size: 52))
                    .padding(.bottom, 6)

                Text(title)
                    .font(.msa(20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.msa(15))
                    .foregroundColor(Color(white: 0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.85, green: 0.75, blue: 0.54).opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
