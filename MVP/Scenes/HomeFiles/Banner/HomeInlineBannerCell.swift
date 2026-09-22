//
//  HomeInlineBannerCell.swift
//  MSA
//
//  البانر الإعلاني **التاني** — شريط ثابت في الرئيسية تحت صف الفجوة
//  السعرية مباشرةً.
//
//  الأول هو الـ popup اللي بيطلع في نص الشاشة أول ما التطبيق يفتح
//  (`BannerPopupVC`). الاتنين بيتحكّم فيهم نفس شاشة «بانرات الرئيسية»
//  في اللوحة، بس كل واحد له تبويب مستقل — والتطبيق بيطلب كل مكان
//  لوحده بـ `?placement=`.
//
//  ## ليه خلية في نفس الجدول مش view في الـ storyboard؟
//
//  صف الفجوة السعرية جوه `OunceDollarCell` جوه الجدول، و«تحته
//  مباشرةً» يعني صف بعده في نفس الجدول. أي view في الـ storyboard
//  كان هيقع تحت الجدول كله مش تحت الصف.
//

import UIKit

final class HomeInlineBannerCell: UITableViewCell {

    static let identifier = "HomeInlineBannerCell"

    /// نفس ارتفاع `HomeInlineBanner` في أندرويد (96dp/pt).
    static let bannerHeight: CGFloat = 96

    /// بتتنادى لما المستخدم يدوس على الشريط.
    var onTapBanner: ((Banner) -> Void)?

    private let slider: BannerSliderView = {
        let view = BannerSliderView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        // نفس خلفية باقي صفوف الرئيسية: الخلفية البنية/الرمادية بتبان
        // من ورا الجدول، فأي لون هنا كان هيعمل مستطيل غريب.
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(slider)

        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // أندرويد بيحط 12dp فوق البانر، ومن غير مساحة إضافية تحته.
            slider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            slider.heightAnchor.constraint(equalToConstant: Self.bannerHeight)
        ])

        slider.onTapBanner = { [weak self] item in
            self?.onTapBanner?(item)
        }
    }

    // MARK: - Configure

    func configure(with items: [Banner]) {

        slider.setItems(items)

        // الخلية بتتبني وبتتعرض في نفس اللحظة تقريباً، والجدول مش
        // بيبعت `viewWillAppear`. من غير السطر ده التقليب التلقائي
        // مكانش هيبدأ غير لما المستخدم يسيب الرئيسية ويرجع لها.
        slider.viewWillAppear()
    }

    // MARK: - Lifecycle

    /// بتتنادى من `HomeVC.viewWillAppear` / `viewWillDisappear` عن
    /// طريق الخلايا الظاهرة.
    func resume() { slider.viewWillAppear() }
    func pause() { slider.viewWillDisappear() }

    override func prepareForReuse() {
        super.prepareForReuse()
        // الخلية دي وحيدة في الجدول فالإعادة مش متوقعة، بس لو حصلت
        // مش عايزين تايمر شغّال على بيانات قديمة.
        slider.viewWillDisappear()
    }
}
