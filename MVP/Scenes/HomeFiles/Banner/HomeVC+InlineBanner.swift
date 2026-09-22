//
//  HomeVC+InlineBanner.swift
//  MSA
//
//  جلب وتشغيل البانر الإعلاني التاني في نهاية محتوى الرئيسية.
//  الخلية نفسها في `HomeInlineBannerCell.swift`.
//

import UIKit
import SwiftUI

extension HomeVC {

    // MARK: - مكان الصف

    /// رقم صف الشريط — آخر صف في الجدول، وبيرجع `nil` لو مفيش بانر.
    ///
    /// الأرقام دي جاية من `numberOfRowsInSection`: الدهب ٨ صفوف
    /// (٠–٧) والفضة ٧ (٠–٦)، والبنر بياخد الصف الذي يلي آخر صف فعلياً.
    var inlineBannerRow: Int? {
        guard !inlineBanners.isEmpty else { return nil }
        return metalType == .Gold ? 8 : 7
    }

    // MARK: - التحميل

    /// نادِها من `viewDidLoad`.
    ///
    /// طلب منفصل تماماً عن طلب الـ popup: لو واحد فيهم فشل، التاني
    /// بيفضل شغّال. ولو مفيش بانرات نشطة في المكان ده، الصف مبيتضافش
    /// أصلاً ومفيش فراغ محجوز في الشاشة.
    func loadInlineBanner() {

        BannerService.fetchBanners(placement: .homeInline) { [weak self] items in

            guard let self else { return }

            let hadRow = self.inlineBannerRow != nil
            self.inlineBanners = items

            // لو الحالة ما اتغيرتش (فاضي وفضل فاضي) مفيش داعي لإعادة
            // بناء الجدول كله.
            guard hadRow || !items.isEmpty else { return }

            self.tableView.reloadData()
        }
    }

    // MARK: - الضغط

    func handleInlineBannerTap(_ item: Banner) {

        /*
         اللينك له الأولوية هنا — على عكس الـ popup.

         الـ popup فيه زرار «اعرف أكثر» منفصل، فالضغط على الصورة نفسها
         معناه «كبّرها». الشريط مالوش زرار، فالضغط الوحيد المتاح لازم
         يودّي على اللينك لو البانر له لينك.
         */
        if let link = item.linkURL,
           !link.trimmingCharacters(in: .whitespaces).isEmpty,
           let url = URL(string: link) {

            let webView = WebView(url: url)
            let hosting = UIHostingController(rootView: webView)

            navigationController?.isNavigationBarHidden = false
            tabBarController?.tabBar.isHidden = true
            navigationController?.pushViewController(hosting, animated: true)
            return
        }

        // مفيش لينك: بنكبّر الصورة زي الـ popup بالظبط.
        guard !item.mediaURL.isEmpty else { return }
        Helper.openZoomAbleImage(image: [item.mediaURL], vc: self, index: 0)
    }

    // MARK: - دورة الحياة

    /// بنوقف/بنشغّل التقليب مع الشاشة.
    ///
    /// الخلية مش بتاخد `viewWillAppear` من الجدول، فلازم نبلّغها
    /// بإيدينا — من غير كده كانت هتفضل بتقلّب وإحنا في تاب تاني.
    func setInlineBannerActive(_ active: Bool) {

        tableView.visibleCells
            .compactMap { $0 as? HomeInlineBannerCell }
            .forEach { active ? $0.resume() : $0.pause() }
    }
}
