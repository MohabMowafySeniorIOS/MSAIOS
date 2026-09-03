//
//  BannerService.swift
//  MSA
//
//  بيجيب بانرات الرئيسية من الباك اند.
//
//  ⚠️ مفيش كاش خالص: كل مرة التطبيق يتفتح بنسأل الـ API من جديد.
//     يعني لو الداشبورد وقّفت بانر أو نشرت واحد جديد، المستخدم بيشوف
//     الجديد من أول فتحة — مش بعد ما الكاش يقدم. الثمن إن مفيش بانر
//     بيظهر وهو أوفلاين، وده مقبول لأن البانر إعلان مش محتوى أساسي.
//

import Foundation

final class BannerService {

    private init() { }

    /// اتعرض الـ popup في التشغيلة دي؟
    ///
    /// ده متغيّر في الذاكرة بس — مفيش أي حاجة بتتحفظ على الديسك. بيترمي
    /// لوحده لما التطبيق يتقفل خالص، وبيفضل موجود طول ما التطبيق شغال
    /// (حتى لو راح للخلفية).
    ///
    /// لازم يبقى `static` كده: لو `HomeVC` اتعملت من جديد لأي سبب
    /// (تبديل تابات، إعادة بناء الـ tab bar)، `viewDidLoad` هتشتغل تاني
    /// — والفلاج ده هو اللي بيمنع الإعلان إنه يظهر مرتين في نفس الجلسة.
    ///
    /// عايزه يظهر كل مرة الرئيسية تتفتح مش كل فتحة تطبيق؟ رجّع `false`
    /// من `shouldShowPopup` بدل `!shownThisLaunch`.
    private static var shownThisLaunch = false

    // MARK: - Fetch

    /// بيجيب البانرات المفعّلة من الباك اند.
    ///
    /// - Parameter completion: بترجع على الـ main thread. **مش** بتتنادى
    ///   لو الريكوست فشل — مفيش كاش نرجع له، فمفيش حاجة نعرضها.
    static func fetchBanners(completion: @escaping ([Banner]) -> Void) {

        // الـ API افتراضياً بيرجّع ١٥ بانر في الصفحة. بنطلب ٥٠ عشان كل
        // البانرات تيجي في ريكوست واحد. بنحطها في الـ URL نفسه مش في
        // parameters عشان نضمن إنها تتبعت كـ query مهما كان الـ encoding
        // اللي APIClient بيستخدمه في الـ GET.
        let base = "\(hostName)\(EndPoints.banners.rawValue)"
        let url = base.contains("?") ? "\(base)&per_page=50" : "\(base)?per_page=50"

        APIClient.shared.performRequestWithAlamofire(
            urlString: url,
            method: .get,
            parameters: nil
        ) { (model: BannersResponse?, error: String?) in

            if let error {
                print("BannerService error ----> \(error)")
            }

            guard let rawItems = model?.data else { return }

            // فلترة محلية على اللي شغّال دلوقتي (status + الفترة الزمنية).
            let items = rawItems.activeNow()

            DispatchQueue.main.async {
                completion(items)
            }
        }
    }

    // MARK: - ظهور الـ popup

    /// هل نعرض الـ popup دلوقتي؟ (مرة واحدة كل تشغيلة للتطبيق)
    static func shouldShowPopup(_ items: [Banner]) -> Bool {
        !items.isEmpty && !shownThisLaunch
    }

    /// بنسجّله وهو بيتعرض مش وهو بيتقفل — عشان لو المستخدم قفل الإعلان
    /// ورجع للرئيسية ما يظهرش تاني في نفس الجلسة.
    static func markPopupShown() {
        shownThisLaunch = true
    }
}
