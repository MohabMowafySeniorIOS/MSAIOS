//
//  BankNotificationSettings.swift
//  MSA
//
//  إدارة تفعيل/تعطيل إشعار تغيّر سعر الدولار لكل بنك على حدة (السويتش
//  اللي بيظهر جنب كل بنك في شاشة "أسعار الدولار على البنوك").
//
//  أول مرة يظهر فيها بنك جديد للمستخدم (يعني أول مرة نوصله من Firestore):
//    - لو هو البنك المركزي المصري -> السويتش بيبقى مفعّل (ON) افتراضيًا.
//    - أي بنك تاني -> السويتش بيبقى معطّل (OFF) افتراضيًا.
//  وبعد كده القيمة بتفضل زي ما المستخدم سابها لحد ما يغيّرها بنفسه.
//
//  التوبيك بتاع كل بنك بيتحسب بنفس الخوارزمية المستخدمة في السيرفر
//  (index.js): "bank_" + md5(اسم البنك بالعربي زي ما هو من egrates.com).
//  حسابه هنا بدل ما نقراه من Firestore بيخلي السويتش يشتغل صح حتى لو
//  الشاشة بتجيب بياناتها من "currencies/USD/banks" اللي مالهاش حقل topic.
//

import Foundation
import FirebaseMessaging
import CryptoKit

enum BankNotificationSettings {

    private static let defaults = UserDefaults.standard

    private static let enabledKeyPrefix = "bank_notif_enabled_v1_"
    private static let seenBanksKey = "bank_notif_seen_banks_v1"

    // MARK: - Central bank detection

    /// نفس الطريقة المستخدمة في باقي الكود (HomeVC / DollarCell) للتعرف على
    /// البنك المركزي، مع تغطية الإملاءين الموجودين فعلاً في الداتا.
    private static func isCentralBank(_ bankName: String) -> Bool {
        return bankName.contains("المركزى")
            || bankName.contains("المركزي")
            || bankName.contains("Central")
    }

    // MARK: - Topic

    /// "bank_" + md5(bankName) - مطابق تمامًا لخوارزمية السيرفر فى index.js.
    static func topic(for bankName: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(bankName.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return "bank_" + hex
    }

    // MARK: - Storage

    private static func enabledKey(for bankName: String) -> String {
        return enabledKeyPrefix + bankName
    }

    private static func markSeen(_ bankName: String) {
        var seenBanks = Set(defaults.stringArray(forKey: seenBanksKey) ?? [])
        seenBanks.insert(bankName)
        defaults.set(Array(seenBanks), forKey: seenBanksKey)
    }

    private static func hasSeen(_ bankName: String) -> Bool {
        let seenBanks = Set(defaults.stringArray(forKey: seenBanksKey) ?? [])
        return seenBanks.contains(bankName)
    }

    // MARK: - Public API

    /// بيرجع حالة إشعارات البنك ده الحالية. أول مرة نشوف فيها البنك ده
    /// بنحدد القيمة الافتراضية (المركزي = مفعّل، غيره = معطّل)، نسجّلها،
    /// ونطبّق الاشتراك فى الـFCM topic المناسب على طول. المرات اللي بعد
    /// كده بترجع القيمة المحفوظة من غير ما تعيد الاشتراك تانى (عشان الدالة
    /// دي بتتنادى كل ما الجدول يتعمله reload).
    @discardableResult
    static func ensureDefault(for bankName: String) -> Bool {
        guard !bankName.isEmpty else { return false }

        if hasSeen(bankName) {
            return defaults.bool(forKey: enabledKey(for: bankName))
        }

        let defaultValue = isCentralBank(bankName)
        defaults.set(defaultValue, forKey: enabledKey(for: bankName))
        markSeen(bankName)
        applySubscription(enabled: defaultValue, bankName: bankName)

        return defaultValue
    }

    static func isEnabled(for bankName: String) -> Bool {
        return defaults.bool(forKey: enabledKey(for: bankName))
    }

    /// بينادى لما المستخدم يغيّر السويتش بنفسه من الشاشة.
    static func setEnabled(_ enabled: Bool, for bankName: String) {
        guard !bankName.isEmpty else { return }

        defaults.set(enabled, forKey: enabledKey(for: bankName))
        markSeen(bankName)
        applySubscription(enabled: enabled, bankName: bankName)
    }

    private static func applySubscription(enabled: Bool, bankName: String) {
        let topicName = topic(for: bankName)

        if enabled {
            Messaging.messaging().subscribe(toTopic: topicName) { error in
                if let error = error {
                    print("BankNotificationSettings subscribe error (\(topicName)):", error.localizedDescription)
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topicName) { error in
                if let error = error {
                    print("BankNotificationSettings unsubscribe error (\(topicName)):", error.localizedDescription)
                }
            }
        }
    }
}
