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
    /// اجتماعات الفيدرالي — تنبيه قبل الاجتماع، وعند صدور القرار،
    /// والبيان، والمحضر. السيرفر بيبعت عليها من `php artisan fomc:notify`.
    case fomc
    case general

    /// كل التوبيكس بتاعة النوع — بكل اللغات.
    ///
    /// بنستخدمها في **الإلغاء**. الاشتراك بيمشي على `topics(for:)`.
    var allTopics: [String] {
        switch self {
        case .gold:    return ["gold_ar", "gold_en"]
        case .silver:  return ["silver_ar", "silver_en"]
        case .dollar:  return ["dollar_prices"]
        case .news:    return ["news_ar", "news_en"]
        case .fomc:    return ["fomc_ar", "fomc_en"]
        case .general: return ["general_ar", "general_en"]
        }
    }

    /// التوبيكس اللي المفروض المستخدم يكون مشترك فيها بلغته.
    ///
    /// `dollar_prices` مالهوش لاحقة لغة، فبيرجع زي ما هو للغتين.
    /// وأي لغة تالتة (الأوردو مثلاً) بترجع للعربي — مفيش `_ur` على السيرفر.
    func topics(for language: String) -> [String] {
        let suffix = language == "en" ? "_en" : "_ar"
        let localized = allTopics.filter { $0.hasSuffix("_ar") || $0.hasSuffix("_en") }

        guard !localized.isEmpty else { return allTopics }

        return allTopics.filter { !localized.contains($0) }
            + localized.filter { $0.hasSuffix(suffix) }
    }

    var title: String {
        switch self {
        case .gold:    return "notif_gold".localized
        case .silver:  return "notif_silver".localized
        case .dollar:  return "notif_dollar".localized
        case .news:    return "notif_news".localized
        case .fomc:    return "notif_fomc".localized
        case .general: return "notif_general".localized
        }
    }

    var subtitle: String {
        switch self {
        case .gold:    return "notif_gold_desc".localized
        case .silver:  return "notif_silver_desc".localized
        case .dollar:  return "notif_dollar_desc".localized
        case .news:    return "notif_news_desc".localized
        case .fomc:    return "notif_fomc_desc".localized
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
        applySubscription(enabled: enabled, category: category, language: currentLanguage())
    }

    /// بيطبّق الاختيارات المحفوظة على FCM. بيتنادى من AppDelegate بدل
    /// الاشتراك الأعمى في كل التوبيكس، عشان اختيار المستخدم ما يتلغيش كل
    /// مرة يفتح التطبيق.
    ///
    /// وبيتنادى كمان **بعد تغيير لغة التطبيق**، عشان التوبيكس تتبدّل.
    static func applyAll() {
        let language = currentLanguage()

        for category in NotificationCategory.allCases {
            applySubscription(enabled: isEnabled(category), category: category, language: language)
        }
    }

    private static func currentLanguage() -> String {
        L102Language.currentAppleLanguage()
    }

    private static func applySubscription(
        enabled: Bool,
        category: NotificationCategory,
        language: String
    ) {
        /*
         * الاشتراك في لغة المستخدم بس، وإلغاء الباقي **صراحةً**.
         *
         * النسخة القديمة كانت بتشترك في `x_ar` و`x_en` مع بعض، فلما
         * السيرفر يبعت نفس الإعلان بالعربي على الأول وبالإنجليزي على
         * التاني الجهاز كان بياخد إشعارين. والإلغاء الصريح مهم: من
         * غيره المستخدم اللي حدّث من نسخة قديمة بيفضل مشترك في اللغتين
         * للأبد، لأن مفيش حاجة تانية هتخرّجه من التوبيك القديم.
         */
        let wanted = enabled ? category.topics(for: language) : []

        for topic in category.allTopics {
            if wanted.contains(topic) {
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
