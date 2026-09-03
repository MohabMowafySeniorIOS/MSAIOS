//
//  BannerSliderView.swift
//  MSA
//
//  سلايدر البانر بتاع الرئيسية: بيقلب أوتوماتيك بين صور وفيديوهات.
//
//  بيتحط جوه الـ `banneView` الموجودة أصلاً في Home.storyboard
//  (الـ view بتاعة الـ 150 نقطة اللي كانت متحجوزة لإعلان Google).
//

import UIKit

final class BannerSliderView: UIView {

    // MARK: - Public

    /// بتتنادى لما المستخدم يدوس على بانر.
    var onTapBanner: ((Banner) -> Void)?

    /// بتتنادى كل ما البانر الظاهر يتغيّر — الـ popup بيستخدمها عشان
    /// زرار "اعرف أكثر" يفتح لينك البانر الصح.
    var onPageChanged: ((Banner) -> Void)?

    /// المدة اللي البانر الصورة بيفضل ظاهر فيها قبل ما يقلب.
    var imageDuration: TimeInterval = 5

    /// حد أقصى لأي فيديو مهما كان طوله، عشان فيديو 3 دقايق
    /// ما يوقّفش السلايدر كله.
    var maxVideoDuration: TimeInterval = 20

    private(set) var items: [Banner] = []

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.identifier)

        // بنثبّت الاتجاه على LTR عشان حساب الـ index ما يتقلبش
        // في اللغة العربية. الترتيب اللي جاي من الداشبورد هو المعتمد.
        view.semanticContentAttribute = .forceLeftToRight

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.hidesForSinglePage = true
        control.currentPageIndicatorTintColor = BannerBrand.gold
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.45)
        control.isUserInteractionEnabled = false
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // MARK: - State

    private var timer: Timer?
    private var currentIndex = 0
    private var isVisible = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        backgroundColor = .clear
        clipsToBounds = true

        addSubview(collectionView)
        addSubview(pageControl)

        NSLayoutConstraint.activate([

            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])

        // لما التطبيق يروح للخلفية بنوقف كل حاجة،
        // ولما يرجع بنكمّل — عشان ما نفضلش نشغل فيديو والشاشة مقفولة.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Data

    func setItems(_ items: [Banner]) {

        self.items = items
        self.currentIndex = 0

        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0

        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)

        if let first = items.first {
            onPageChanged?(first)
        }

        if isVisible {
            startIfNeeded()
        }
    }

    // MARK: - Lifecycle (بتتنادى من HomeVC)

    func viewWillAppear() {
        isVisible = true
        startIfNeeded()
    }

    func viewWillDisappear() {
        isVisible = false
        stop()
    }

    @objc private func appDidEnterBackground() {
        stop()
    }

    @objc private func appWillEnterForeground() {
        if isVisible { startIfNeeded() }
    }

    // MARK: - Auto scroll

    private func startIfNeeded() {

        guard items.count > 1 || items.first?.mediaType == .video else {
            // بانر واحد صورة: مفيش داعي لأي تايمر.
            playCurrentVideoIfNeeded()
            return
        }

        playCurrentVideoIfNeeded()
        scheduleNextAdvance(after: durationForItem(at: currentIndex))
    }

    private func stop() {

        timer?.invalidate()
        timer = nil

        collectionView.visibleCells
            .compactMap { $0 as? BannerCell }
            .forEach { $0.pause() }
    }

    private func durationForItem(at index: Int) -> TimeInterval {

        guard items.indices.contains(index) else { return imageDuration }

        // الفيديو بيبدأ بالحد الأقصى، وبعدين لما نعرف مدته الحقيقية
        // من الـ cell بنعيد جدولة القلبة على المدة الصح.
        return items[index].mediaType == .video ? maxVideoDuration : imageDuration
    }

    private func scheduleNextAdvance(after interval: TimeInterval) {

        timer?.invalidate()

        guard items.count > 1 else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.advance()
        }
    }

    private func advance() {

        guard items.count > 1 else { return }

        let next = (currentIndex + 1) % items.count

        collectionView.scrollToItem(
            at: IndexPath(item: next, section: 0),
            at: .centeredHorizontally,
            animated: true
        )

        // scrollToItem المبرمج مش بيطلّع scrollViewDidEndDecelerating،
        // فبنحدّث الحالة بإيدينا هنا.
        updateCurrentIndex(to: next)
    }

    private func updateCurrentIndex(to index: Int) {

        currentIndex = index
        pageControl.currentPage = index

        if items.indices.contains(index) {
            onPageChanged?(items[index])
        }

        playCurrentVideoIfNeeded()
        scheduleNextAdvance(after: durationForItem(at: index))
    }

    private func playCurrentVideoIfNeeded() {

        for cell in collectionView.visibleCells {

            guard let bannerCell = cell as? BannerCell,
                  let indexPath = collectionView.indexPath(for: cell)
            else { continue }

            if indexPath.item == currentIndex && isVisible {
                bannerCell.play()
            } else {
                bannerCell.pause()
            }
        }
    }
}

// MARK: - Data source

extension BannerSliderView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BannerCell.identifier,
            for: indexPath
        ) as! BannerCell

        let item = items[indexPath.item]
        cell.configure(with: item)

        cell.onVideoDurationKnown = { [weak self] duration in

            guard let self,
                  self.currentIndex == indexPath.item,
                  self.isVisible
            else { return }

            // عرفنا المدة الحقيقية: نعيد الجدولة عشان القلبة تحصل
            // بعد ما الفيديو يخلص مش في نصه.
            self.scheduleNextAdvance(after: min(duration, self.maxVideoDuration))
        }

        return cell
    }
}

// MARK: - Delegate

extension BannerSliderView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard let bannerCell = cell as? BannerCell else { return }

        if indexPath.item == currentIndex && isVisible {
            bannerCell.play()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        (cell as? BannerCell)?.pause()
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard items.indices.contains(indexPath.item) else { return }
        onTapBanner?(items[indexPath.item])
    }

    // المستخدم قلب بإيده: نوقف التايمر مؤقتاً عشان ما نخطفش
    // السلايدر من تحت إيده وهو بيتفرج.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let width = scrollView.bounds.width
        guard width > 0 else { return }

        let index = Int(round(scrollView.contentOffset.x / width))
        guard items.indices.contains(index) else { return }

        updateCurrentIndex(to: index)
    }
}
