//
//  HomeVC+FomcCard.swift
//  MSA
//
//  كارت «الاجتماع القادم للفيدرالي» في الشاشة الرئيسية.
//
//  قرار الفائدة الأمريكية أكبر محرّك لسعر الذهب العالمي، فمكانه الطبيعي
//  في الرئيسية جنب الأسعار — نفس مكانه في أندرويد (HomeScreen.kt).
//
//  الكارت بيتحط كـ `tableFooterView` مش كصف في الجدول: كده مش بنلمس
//  `numberOfRowsInSection` ولا `cellForRowAt`، فمفيش أي احتمال نكسر
//  جدول الأسعار الموجود، وبيتمرّر مع المحتوى بشكل طبيعي.
//
//  الكارت بيخفي نفسه لوحده لو مفيش اجتماع معلن أو لو الطلب فشل — مش
//  بيسيب فراغ في نص الشاشة.
//

import UIKit
import SwiftUI
import ObjectiveC

extension HomeVC {

    /// بيتنادى من `viewDidLoad` بعد إعداد الجدول
    func installFomcCard() {
        // لو اتنادت مرتين مانضيفش كارت فوق كارت
        guard fomcHost == nil else { return }

        var card = FomcNextEventCard()
        card.onTap = { [weak self] in self?.openFomcCalendar() }

        /*
         الكارت بيتحمّل من الشبكة، فارتفاعه بيبدأ صفر وبيكبر لما
         الاجتماع يوصل.

         `tableFooterView` محتاج إطار برقم ثابت ومش بيعيد القياس لوحده،
         فلو قِسنا مرة واحدة وقت `viewDidLoad` كان الكارت هيتقاس وهو
         فاضي ويفضل مخفي للأبد. عشان كده الكارت نفسه بيبلّغنا بارتفاعه
         كل ما يتغيّر وإحنا بنعيد بناء التذييل.
         */
        card.onHeightChange = { [weak self] height in
            self?.updateFomcFooter(height: height)
        }

        let host = UIHostingController(rootView: card)
        host.view.backgroundColor = .clear

        addChild(host)
        host.didMove(toParent: self)
        fomcHost = host
    }

    /// بيبني تذييل الجدول بالارتفاع اللي الكارت بلّغ بيه
    private func updateFomcFooter(height: CGFloat) {
        guard let host = fomcHost else { return }

        // ارتفاع صفر = مفيش اجتماع يتعرض. بنشيل التذييل خالص عشان
        // ما يسيبش مسافة فاضية تحت آخر سعر.
        guard height > 1 else {
            if tableView.tableFooterView != nil { tableView.tableFooterView = nil }
            return
        }

        let width = tableView.bounds.width

        // لسه الجدول ماتقاسش — نأجّل للدورة الجاية بدل ما نبني على عرض صفر
        guard width > 0 else {
            DispatchQueue.main.async { [weak self] in self?.updateFomcFooter(height: height) }
            return
        }

        let total = height + 24   // هامش فوق وتحت

        // نفس الارتفاع؟ مانعيدش البناء — إعادة تعيين `tableFooterView`
        // بتعمل ومضة بصرية وبتقطع التمرير لو المستخدم بيمرّر.
        if let existing = tableView.tableFooterView,
           abs(existing.frame.height - total) < 1,
           abs(existing.frame.width - width) < 1 {
            return
        }

        let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: total))
        container.backgroundColor = .clear

        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.removeFromSuperview()
        container.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            host.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        tableView.tableFooterView = container
    }

    /// فتح تقويم الاجتماعات من الكارت
    func openFomcCalendar() {
        var view = FomcCalendarView()
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onOpenEvent = { [weak self] id in self?.pushFomcEvent(id: id) }
        // حدث التقويم له شاشة تفاصيل مختلفة تماماً عن الاجتماع
        view.onOpenCalendarEvent = { [weak self] id in self?.pushCalendarEvent(id: id) }
        host.rootView = view

        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    private func pushFomcEvent(id: Int) {
        var details = FomcEventDetailsView(eventId: id)
        let host = UIHostingController(rootView: details)

        details.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = details

        navigationController?.pushViewController(host, animated: true)
    }

    /// تفاصيل حدث في التقويم الاقتصادي
    private func pushCalendarEvent(id: Int) {
        var details = CalendarEventDetailsView(eventId: id)
        let host = UIHostingController(rootView: details)

        details.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = details

        navigationController?.pushViewController(host, animated: true)
    }
}

/**
 مرجع الـ hosting controller.

 الـ extension مش بيقدر يضيف خاصية مخزّنة، فبنستخدم associated object —
 وده أنضف من إضافة متغيّر في HomeVC.swift نفسه وخلط الميزة الجديدة مع
 الكود القديم.
 */
private var fomcHostKey: UInt8 = 0

extension HomeVC {

    var fomcHost: UIHostingController<FomcNextEventCard>? {
        get { objc_getAssociatedObject(self, &fomcHostKey) as? UIHostingController<FomcNextEventCard> }
        set { objc_setAssociatedObject(self, &fomcHostKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
