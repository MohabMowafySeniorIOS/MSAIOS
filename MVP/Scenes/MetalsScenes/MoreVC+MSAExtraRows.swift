//
//  MoreVC+MSAExtraRows.swift
//  MSA
//
//  صفّين جداد في شاشة «المزيد»: اجتماعات الفيدرالي، وفروعنا.
//
//  الصفوف بتتبني **بالكود** مش في الـ storyboard عن قصد: ملف
//  Home.storyboard حجمه ٤٧٥ كيلوبايت وفيه ٤٤ stackView متداخلة، وإضافة
//  صفوف فيه بالـ XML كانت هتبقى تعديل هش وصعب مراجعته. الكود هنا بيلاقي
//  حاوية الصفوف من الـ outlet الموجود (`AboutView`) ويضيف عليها صفوف
//  بنفس الشكل بالظبط.
//
//  لو شكل الشاشة اتغيّر بعدين ومالقاش الحاوية، بيسجّل تحذير ويخرج —
//  الشاشة بتفضل شغالة زي ما هي من غير الصفين، مفيش crash.
//

import UIKit
import SwiftUI

extension MoreVC {

    /// بيتنادى من `viewDidLoad`
    func installMSAExtraRows() {
        guard let container = rowsContainer() else {
            print("MoreVC: مالقيتش حاوية الصفوف — الصفين الجداد مش هيتضافوا")
            return
        }

        // لو اتنادت مرتين (مثلاً بعد إعادة تحميل الشاشة) مانكررش الصفوف
        guard container.arrangedSubviews.first(where: { $0.tag == Self.fomcRowTag }) == nil
        else { return }

        // مكان الإدراج: بعد صف «من نحن» مباشرة. لو مالقيناهوش بنحط
        // الصفوف في الآخر بدل ما نرميها في مكان عشوائي.
        let anchorIndex = container.arrangedSubviews.firstIndex(where: { $0.containsDescendant(AboutView) })
        var insertAt = (anchorIndex.map { $0 + 1 }) ?? container.arrangedSubviews.count

        let fomcRow = makeRow(
            title: "fomc_title".localized,
            systemIcon: "calendar.badge.clock",
            tag: Self.fomcRowTag
        ) { [weak self] in self?.openFomc() }

        let branchesRow = makeRow(
            title: "branches_title".localized,
            systemIcon: "mappin.and.ellipse",
            tag: Self.branchesRowTag
        ) { [weak self] in self?.openBranches() }

        let shopRow = makeRow(
            title: "shop_title".localized,
            systemIcon: "shippingbox.fill",
            tag: Self.shopRowTag
        ) { [weak self] in self?.openShop() }

        let ordersRow = makeRow(
            title: "orders_title".localized,
            systemIcon: "list.bullet.rectangle.portrait",
            tag: Self.ordersRowTag
        ) { [weak self] in self?.openOrders() }

        // التحقّق من سبيكة بمسح كود الـQR اللي عليها
        let scanRow = makeRow(
            title: "bullion_scan_title".localized,
            systemIcon: "qrcode.viewfinder",
            tag: Self.bullionScanRowTag
        ) { [weak self] in self?.openBullionScan() }

        for row in [fomcRow, branchesRow, shopRow, ordersRow, scanRow] {
            container.insertArrangedSubview(row, at: min(insertAt, container.arrangedSubviews.count))
            insertAt += 1
        }
    }

    // MARK: الانتقال

    /**
     مسح كود سبيكة.

     شريط التبويبات بيتخبّى زي باقي الشاشات المدفوعة: الكاميرا محتاجة
     الشاشة كلها، وصف تبويبات تحت معاينة كاميرا بيبان كأنه غلطة.
     */
    func openBullionScan() {
        var view = BullionScanView()
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = view

        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    /// تقويم اجتماعات الفيدرالي
    func openFomc() {
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
        var view = FomcEventDetailsView(eventId: id)
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = view

        navigationController?.pushViewController(host, animated: true)
    }

    /// تفاصيل حدث في التقويم الاقتصادي
    private func pushCalendarEvent(id: Int) {
        var view = CalendarEventDetailsView(eventId: id)
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = view

        navigationController?.pushViewController(host, animated: true)
    }

    /// فروعنا
    func openBranches() {
        var view = BranchesView()
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onOpenBranch = { [weak self] id in self?.pushBranch(id: id) }
        host.rootView = view

        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    private func pushBranch(id: Int) {
        var view = BranchDetailsView(branchId: id)
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = view

        navigationController?.pushViewController(host, animated: true)
    }

    // MARK: المتجر

    /// سبائك ومشغولات
    func openShop() {
        var view = ShopView()
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onOpenProduct = { [weak self] id in self?.pushProduct(id: id) }
        view.onOpenCart = { [weak self] in self?.pushCart() }
        view.onNeedsLogin = { [weak self] in self?.pushLoginForShop() }
        host.rootView = view

        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    private func pushProduct(id: Int) {
        var view = ProductDetailsView(productId: id)
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onOpenCart = { [weak self] in self?.pushCart() }
        view.onNeedsLogin = { [weak self] in self?.pushLoginForShop() }
        host.rootView = view

        navigationController?.pushViewController(host, animated: true)
    }

    private func pushCart() {
        var view = CartView()
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onBrowseProducts = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onOrderPlaced = { [weak self] id in self?.showOrdersAfterPlacing(id: id) }
        host.rootView = view

        navigationController?.pushViewController(host, animated: true)
    }

    /// طلباتي
    func openOrders(highlight id: Int? = nil) {
        var view = OrdersView(highlightOrderId: id)
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onBrowseProducts = { [weak self] in self?.openShop() }
        host.rootView = view

        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    /**
     بعد نجاح الطلب.

     بنشيل شاشات المتجر والسلة من الـ stack ونحط «طلباتي» مكانهم:
     الرجوع لسلة فاضية بعد ما تطلب بيبان كأن حاجة ضاعت.
     */
    private func showOrdersAfterPlacing(id: Int) {
        guard let navigation = navigationController else { return }

        var view = OrdersView(highlightOrderId: id)
        let host = UIHostingController(rootView: view)

        view.onBack = { [weak navigation] in navigation?.popViewController(animated: true) }
        view.onBrowseProducts = { [weak self] in self?.openShop() }
        host.rootView = view

        // بنسيب أول شاشة (المزيد) وبنحط الطلبات بعدها مباشرة
        var stack = navigation.viewControllers
        if let first = stack.first {
            stack = [first, host]
        } else {
            stack.append(host)
        }

        navigation.setViewControllers(stack, animated: true)
    }

    /**
     الدخول مطلوب قبل السلة.

     بننادي `pushLogin()` الموجودة في `MoreVC` بدل ما نكرّر سلسلة
     الحساب (دخول ⇄ تسجيل ← تأكيد الكود): تكرارها كان معناه إن
     المستخدم اللي محتاج يسجّل حساب جديد يقف في طريق مسدود.

     بعد النجاح الشاشة بترجع لـ«المزيد» زي أي دخول تاني في التطبيق،
     والمستخدم يدخل المتجر تاني — خطوة زيادة، بس السلوك متوقّع
     ومتطابق مع باقي الشاشات.
     */
    private func pushLoginForShop() {
        pushLogin()
    }

    // MARK: بناء الصف

    fileprivate static let bullionScanRowTag = 90_305
    fileprivate static let fomcRowTag = 90_301
    fileprivate static let branchesRowTag = 90_302
    fileprivate static let shopRowTag = 90_303
    fileprivate static let ordersRowTag = 90_304

    /**
     بيلاقي الـ stack view الرأسي اللي فيه صفوف القايمة.

     بنطلع لفوق من `AboutView` (وهو outlet موجود أصلاً في الـ storyboard)
     لحد ما نلاقي stack رأسي. كده مش بنعتمد على ترتيب أو أسماء داخلية
     ممكن تتغيّر لو الشاشة اتعدّلت في Interface Builder.
     */
    private func rowsContainer() -> UIStackView? {
        var node: UIView? = AboutView

        while let current = node {
            if let stack = current.superview as? UIStackView, stack.axis == .vertical {
                return stack
            }
            node = current.superview
        }

        return nil
    }

    private func makeRow(
        title: String,
        systemIcon: String,
        tag: Int,
        action: @escaping () -> Void
    ) -> UIView {

        let row = UIView()
        row.tag = tag
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let icon = UIImageView(image: UIImage(systemName: systemIcon))
        icon.tintColor = UIColor(named: "MainColor")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont(name: FontfamilyName, size: 14) ?? .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false

        // السهم بيتقلب لوحده في العربي — الـ semantic content بيخلي
        // النظام يعكسه بدل ما نختار صورة مختلفة لكل لغة
        // الأصل موجود في Assets.xcassets، والبديل احتياطي بس عشان
        // الصف ما يظهرش من غير سهم لو الأصل اتشال يوم
        let arrowImage = UIImage(named: "rightArrow")
            ?? UIImage(systemName: "chevron.right")

        let arrow = UIImageView(image: arrowImage)
        arrow.tintColor = UIColor(named: "MainColor")
        arrow.contentMode = .scaleAspectFit
        // بيتقلب لوحده في الواجهة العربية
        arrow.image = arrow.image?.imageFlippedForRightToLeftLayoutDirection()
        arrow.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [icon, label, UIView(), arrow])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(stack)

        let button = MSATapButton(type: .system)
        button.onTap = action
        button.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(button)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
            arrow.widthAnchor.constraint(equalToConstant: 20),
            arrow.heightAnchor.constraint(equalToConstant: 20),

            // الزرار بيغطي الصف كله — نفس أسلوب الصفوف الموجودة في
            // الـ storyboard (زرار شفاف فوق المحتوى)
            button.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            button.topAnchor.constraint(equalTo: row.topAnchor),
            button.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }
}

/// زرار بيشيل الـ closure بتاعه — أبسط من target/action مع selector
/// و`objc` في extension.
private final class MSATapButton: UIButton {

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc private func handleTap() { onTap?() }
}

private extension UIView {
    /// هل الـ view ده (أو أي حاجة جواه) هو الـ view المطلوب؟
    func containsDescendant(_ target: UIView?) -> Bool {
        guard let target else { return false }
        if self === target { return true }

        return subviews.contains { $0.containsDescendant(target) }
    }
}
