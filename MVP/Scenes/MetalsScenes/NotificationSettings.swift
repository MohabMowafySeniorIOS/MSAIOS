//
//  NotificationSettings.swift
//  MSA
//
//  تحكّم منفصل لكل نوع إشعار — الذهب، الفضة، أسعار الدولار، الأخبار،
//  والإشعارات العامة.
//
//  نفس أسلوب BankNotificationSettings.swift بالظبط، ونفس المنطق الموجود في
//  أندرويد (NotificationPreferences.kt).
//
//  كل نوع مربوط بـ FCM topic (أو أكتر). لما المستخدم يقفل النوع بنعمل
//  unsubscribe من كل التوبيكس بتاعته، ولما يفتحه بنرجّع نشترك.
//
//  الافتراضي: كل الأنواع مفعّلة — عشان سلوك التطبيق ما يتغيرش لمستخدم قديم
//  بيحدّث، وده نفس اللي كان بيحصل قبل الشاشة دي (الاشتراك في كل التوبيكس
//  في AppDelegate).
//
//  ملحوظة مهمة: الاشتراك في التوبيك بيمنع رسايل التوبيك بس. لو السيرفر بيبعت
//  إشعار على التوكن مباشرة أو لكل الأجهزة، السويتش مش هيوقّفه — لازم السيرفر
//  يبعت على التوبيكس دي.
//

import Foundation
import FirebaseMessaging

enum NotificationCategory: String, CaseIterable {
    case gold
    case silver
    case dollar
    case news
    case general

    /// التوبيكس اللي السيرفر بيبعت عليها لكل نوع
    var topics: [String] {
        switch self {
        case .gold:    return ["gold_ar", "gold_en"]
        case .silver:  return ["silver_ar", "silver_en"]
        case .dollar:  return ["dollar_prices"]
        case .news:    return ["news_ar", "news_en"]
        case .general: return ["general_ar", "general_en"]
        }
    }

    var title: String {
        switch self {
        case .gold:    return "notif_gold".localized
        case .silver:  return "notif_silver".localized
        case .dollar:  return "notif_dollar".localized
        case .news:    return "notif_news".localized
        case .general: return "notif_general".localized
        }
    }

    var subtitle: String {
        switch self {
        case .gold:    return "notif_gold_desc".localized
        case .silver:  return "notif_silver_desc".localized
        case .dollar:  return "notif_dollar_desc".localized
        case .news:    return "notif_news_desc".localized
        case .general: return "notif_general_desc".localized
        }
    }
}

enum NotificationSettings {

    private static let defaults = UserDefaults.standard
    private static let keyPrefix = "notif_enabled_v1_"

    private static func key(for category: NotificationCategory) -> String {
        keyPrefix + category.rawValue
    }

    /// أي نوع لسه المستخدم مغيّرش فيه حاجة بيرجع مفعّل.
    static func isEnabled(_ category: NotificationCategory) -> Bool {
        guard defaults.object(forKey: key(for: category)) != nil else { return true }
        return defaults.bool(forKey: key(for: category))
    }

    /// بينادى لما المستخدم يغيّر السويتش من شاشة الإعدادات.
    static func setEnabled(_ enabled: Bool, for category: NotificationCategory) {
        defaults.set(enabled, forKey: key(for: category))
        applySubscription(enabled: enabled, category: category)
    }

    /// بيطبّق الاختيارات المحفوظة على FCM. بيتنادى من AppDelegate بدل
    /// الاشتراك الأعمى في كل التوبيكس، عشان اختيار المستخدم ما يتلغيش كل
    /// مرة يفتح التطبيق.
    static func applyAll() {
        for category in NotificationCategory.allCases {
            applySubscription(enabled: isEnabled(category), category: category)
        }
    }

    private static func applySubscription(enabled: Bool, category: NotificationCategory) {
        for topic in category.topics {
            if enabled {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    if let error {
                        print("NotificationSettings subscribe error (\(topic)):", error.localizedDescription)
                    }
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                    if let error {
                        print("NotificationSettings unsubscribe error (\(topic)):", error.localizedDescription)
                    }
                }
            }
        }
    }
}
