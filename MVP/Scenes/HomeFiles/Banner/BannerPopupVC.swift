//
//  BannerPopupVC.swift
//  MSA
//
//  بانر الرئيسية كـ popup في نص الشاشة.
//
//  الشكل:
//                       ✕   ← زرار إغلاق فوق الكارت
//   ┌────────────────────────┐
//   │       ميديا 16:9       │  ← نفس BannerSliderView: صور وفيديو بتقلب أوتوماتيك
//   └────────────────────────┘
//   [       اعرف أكثر       ]  ← زرار ذهبي (بيظهر لو البانر عنده لينك)
//
//  بتتعرض بـ .overFullScreen عشان الرئيسية تفضل باينة ورا الخلفية
//  المعتّمة — إحساس popup مش شاشة جديدة.
//

import UIKit

final class BannerPopupVC: UIViewController {

    // MARK: - Callbacks

    /// المستخدم دوس على بانر عنده لينك (من الكارت أو من زرار "اعرف أكثر").
    var onOpenLink: ((String) -> Void)?

    /// المستخدم دوس على بانر مالوش لينك — الميديا تتفتح بملء الشاشة.
    var onOpenMedia: ((Banner) -> Void)?

    /// بتتنادى أول ما الـ popup يختفي بأي طريقة — HomeVC بيستخدمها
    /// عشان يفضّي الريفرنس بتاعه.
    var onClosed: (() -> Void)?

    // MARK: - Data

    private let items: [Banner]
    private var currentItem: Banner

    // MARK: - UI

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.80)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// كل محتوى الـ popup — بيتعمله scale في أنيميشن الدخول كوحدة واحدة.
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var closeButton: UIButton = {

        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var card: UIView = {
        let view = UIView()
        view.backgroundColor = BannerBrand.placeholder
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = BannerBrand.gold.withAlphaComponent(0.22).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var slider: BannerSliderView = {
        let view = BannerSliderView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ctaButton: UIButton = {

        let button = UIButton(type: .system)
        button.setTitle("اعرف أكثر", for: .normal)
        button.setTitleColor(BannerBrand.ink, for: .normal)
        button.titleLabel?.font = UIFont(name: "\(FontfamilyName)-Bold", size: 15)
            ?? .systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// التدرج الذهبي بتاع زرار الـ CTA.
    private let ctaGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = BannerBrand.goldGradientColors
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private var ctaHeightConstraint: NSLayoutConstraint?
    private var ctaTopConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(items: [Banner]) {

        self.items = items
        // آمن: الـ VC دي مبتتعرضش أصلاً لو اللستة فاضية (شوف HomeVC+Banner).
        self.currentItem = items[0]

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupUI()

        slider.onTapBanner = { [weak self] item in
            self?.handleTap(item)
        }

        slider.onPageChanged = { [weak self] item in
            self?.currentItem = item
            self?.updateCTA(for: item)
        }

        slider.setItems(items)
        updateCTA(for: currentItem)

        // نبدأ صغير وشفاف، وبنكبر في viewDidAppear.
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        slider.viewWillAppear()

        UIView.animate(
            withDuration: 0.42,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction]
        ) {
            self.container.alpha = 1
            self.container.transform = .identity
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        slider.viewWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // بنبلّغ بس لما نختفي فعلاً (isBeingDismissed)، مش لما تتفتح
        // شاشة فوقنا زي عارض الصور أو مشغل الفيديو.
        if isBeingDismissed {
            onClosed?()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // CALayer مبيتحركش مع Auto Layout، فبنظبطه يدوي كل مرة.
        ctaGradient.frame = ctaButton.bounds
    }

    // MARK: - Setup

    private func setupUI() {

        view.addSubview(dimView)
        view.addSubview(container)

        container.addSubview(closeButton)
        container.addSubview(card)
        container.addSubview(ctaButton)

        card.addSubview(slider)
        ctaButton.layer.insertSublayer(ctaGradient, at: 0)

        // الضغط على الخلفية بيقفل.
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        dimView.addGestureRecognizer(tap)

        let ctaHeight = ctaButton.heightAnchor.constraint(equalToConstant: 48)
        ctaHeightConstraint = ctaHeight

        let ctaTop = ctaButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 14)
        ctaTopConstraint = ctaTop

        NSLayoutConstraint.activate([

            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // عرض الشاشة كامل ناقص ١٦ يمين وشمال.
            // بنستخدم safeArea عشان ما نخشّش تحت الحواف المنحنية.
            container.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 34),
            closeButton.heightAnchor.constraint(equalToConstant: 34),

            card.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            // 16:9 — الارتفاع بيتحسب من العرض تلقائياً.
            // الـ multiplier هنا هو الارتفاع ÷ العرض، فـ 9/16 = مستطيل عريض.
            // غيّره لـ 1 لمربع أو 4.0/3.0 لطولي.
            card.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: 9.0 / 16.0),

            slider.topAnchor.constraint(equalTo: card.topAnchor),
            slider.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            ctaTop,
            ctaButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ctaHeight,

            ctaButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    // MARK: - CTA

    /// زرار "اعرف أكثر" بيظهر بس لو البانر الحالي عنده لينك.
    /// بانر من غير لينك = مفيش زرار، أحسن من زرار بيودّي على لا حاجة.
    private func updateCTA(for item: Banner) {

        let hasLink = (item.linkURL?.isEmpty == false)

        ctaButton.isHidden = !hasLink

        // بنصفّر الارتفاع **والمسافة اللي فوقه** — لو صفّرنا الارتفاع بس
        // هيفضل ١٤ نقطة فراغ تحت الكارت من غير أي حاجة فيها.
        ctaHeightConstraint?.constant = hasLink ? 48 : 0
        ctaTopConstraint?.constant = hasLink ? 14 : 0

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    private func handleTap(_ item: Banner) {

        if let link = item.linkURL, !link.isEmpty {
            dismiss(animated: true) { [weak self] in
                self?.onOpenLink?(link)
            }
        } else {
            // الميديا بتتفتح فوق الـ popup، فبنوقف السلايدر بس من غير ما نقفل.
            slider.viewWillDisappear()
            onOpenMedia?(item)
        }
    }

    /// بتتنادى من HomeVC لما شاشة الفل سكرين تتقفل ونرجع للـ popup.
    func resumeSlider() {
        slider.viewWillAppear()
    }

    /// إيقاف مؤقت من برّه (احتياطي — الـ popup بيوقف نفسه أصلاً).
    func pauseSlider() {
        slider.viewWillDisappear()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func ctaTapped() {

        guard let link = currentItem.linkURL, !link.isEmpty else { return }

        dismiss(animated: true) { [weak self] in
            self?.onOpenLink?(link)
        }
    }

}
