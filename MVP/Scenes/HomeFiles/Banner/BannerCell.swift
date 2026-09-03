//
//  BannerCell.swift
//  MSA
//
//  خلية البانر — بتعرض صورة أو فيديو حسب نوع العنصر.
//  متعملة بالكود بالكامل (مفيش xib) عشان ما نضطرش نضيف ملفات
//  للـ target من Xcode غير ملفات الـ swift.
//

import UIKit
import AVFoundation
import Kingfisher

final class BannerCell: UICollectionViewCell {

    static let identifier = "BannerCell"

    // MARK: - Callbacks

    /// بتتنادى أول ما نعرف مدة الفيديو، عشان السلايدر يعرف يستنى قد إيه
    /// قبل ما يقلب للعنصر اللي بعده بدل ما يقطع الفيديو في نصه.
    var onVideoDurationKnown: ((TimeInterval) -> Void)?

    // MARK: - UI

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let videoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// علامة الفيديو الدائمة في الركن.
    /// بتفضل ظاهرة طول الوقت حتى والفيديو شغال، عشان المستخدم يعرف
    /// إن ده فيديو وإن الضغط عليه هيفتحه بالصوت وبملء الشاشة.
    private let videoBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        view.layer.cornerRadius = 13
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let badgeIcon: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "play.fill"))
        view.tintColor = .white
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// مدة الفيديو جنب الأيقونة — بتظهر أول ما نعرفها.
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// أيقونة كبيرة في النص — بتظهر بس والفيديو لسه بيحمّل.
    private let loadingIcon: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        view.tintColor = UIColor.white.withAlphaComponent(0.85)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "\(FontfamilyName)-Bold", size: 14)
            ?? .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// تدرّج أسود تحت عشان الليبل يبان فوق أي صورة.
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        layer.locations = [0.45, 1.0]
        return layer
    }()

    // MARK: - Video

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var endObserver: NSObjectProtocol?
    private var currentItem: Banner?

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

        contentView.clipsToBounds = true
        // الحواف بقت مسؤولية اللي شايل السلايدر (كارت الـ popup بيدوّر
        // على 24)، عشان ما يحصلش تدوير جوه تدوير ويبان شكل غريب.
        contentView.layer.cornerRadius = 0
        contentView.backgroundColor = BannerBrand.placeholder

        contentView.addSubview(imageView)
        contentView.addSubview(videoContainer)
        contentView.layer.addSublayer(gradientLayer)
        contentView.addSubview(loadingIcon)
        contentView.addSubview(titleLabel)

        videoBadge.addSubview(badgeIcon)
        videoBadge.addSubview(badgeLabel)
        contentView.addSubview(videoBadge)

        NSLayoutConstraint.activate([

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            videoContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            loadingIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            loadingIcon.widthAnchor.constraint(equalToConstant: 44),
            loadingIcon.heightAnchor.constraint(equalToConstant: 44),

            // الشارة فوق على الشمال، بعيد عن العنوان اللي تحت
            videoBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            videoBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            videoBadge.heightAnchor.constraint(equalToConstant: 26),

            badgeIcon.leadingAnchor.constraint(equalTo: videoBadge.leadingAnchor, constant: 9),
            badgeIcon.centerYAnchor.constraint(equalTo: videoBadge.centerYAnchor),
            badgeIcon.widthAnchor.constraint(equalToConstant: 11),
            badgeIcon.heightAnchor.constraint(equalToConstant: 11),

            badgeLabel.leadingAnchor.constraint(equalTo: badgeIcon.trailingAnchor, constant: 5),
            badgeLabel.centerYAnchor.constraint(equalTo: videoBadge.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: videoBadge.trailingAnchor, constant: -9)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        // الشارة دايماً LTR (أيقونة بعدين وقت) حتى في الواجهة العربية،
        // لأن ده الشكل المتعارف عليه في كل مشغلات الفيديو.
        videoBadge.semanticContentAttribute = .forceLeftToRight
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // CALayer مبيتحركش مع Auto Layout، فبنظبطه يدوي كل مرة.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = contentView.bounds
        playerLayer?.frame = videoContainer.bounds
        CATransaction.commit()
    }

    // MARK: - Configure

    func configure(with item: Banner) {

        currentItem = item
        titleLabel.text = item.name
        titleLabel.isHidden = item.name.isEmpty

        switch item.mediaType {

        case .image:
            configureAsImage(item)

        case .video:
            configureAsVideo(item)
        }
    }

    private func configureAsImage(_ item: Banner) {

        videoContainer.isHidden = true
        loadingIcon.isHidden = true
        videoBadge.isHidden = true
        imageView.isHidden = false

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: item.thumbURL.flatMap { URL(string: $0) },
            placeholder: UIImage(named: "sliderPlaceHolder"),
            options: [.transition(.fade(0.25)), .cacheOriginalImage]
        )
    }

    private func configureAsVideo(_ item: Banner) {

        // الغلاف بيفضل ظاهر تحت الفيديو لحد ما أول فريم يترسم،
        // عشان ما يبانش مستطيل أسود لحظة التحميل.
        imageView.isHidden = false
        imageView.kf.setImage(
            with: item.thumbURL.flatMap { URL(string: $0) },
            placeholder: UIImage(named: "sliderPlaceHolder")
        )

        videoContainer.isHidden = false
        loadingIcon.isHidden = false

        // الشارة بتبان فوراً — حتى قبل ما الفيديو يحمّل —
        // عشان المستخدم يعرف من أول لحظة إن ده فيديو.
        videoBadge.isHidden = false
        badgeLabel.text = ""

        guard let url = URL(string: item.mediaURL) else { return }

        // مهم: الجلسة الصوتية على ambient عشان الفيديو المكتوم
        // ما يوقّفش الأغنية اللي المستخدم سامعها في تطبيق تاني.
        BannerAudioSession.setAmbient()

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        let player = AVPlayer(playerItem: playerItem)
        // مكتوم دايماً في البانر: بيشتغل لوحده من غير ما المستخدم يطلبه،
        // فصوت فجأة حاجة مزعجة. الصوت بيشتغل لما يفتحه بملء الشاشة.
        player.isMuted = true
        player.actionAtItemEnd = .none

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = videoContainer.bounds
        videoContainer.layer.addSublayer(layer)

        self.player = player
        self.playerLayer = layer

        // اللوب: أول ما يخلص نرجّعه لأوله تاني.
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        // بنقرا المدة async لأن قراءتها sync بتقفل الـ main thread على شبكة بطيئة.
        Task { [weak self] in

            guard let duration = try? await asset.load(.duration) else { return }

            let seconds = CMTimeGetSeconds(duration)
            guard seconds.isFinite, seconds > 0 else { return }

            await MainActor.run {
                self?.badgeLabel.text = Self.formatDuration(seconds)
                self?.onVideoDurationKnown?(seconds)
            }
        }
    }

    private static func formatDuration(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    // MARK: - Playback control

    func play() {

        guard currentItem?.mediaType == .video else { return }

        loadingIcon.isHidden = true
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        teardownPlayer()

        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        badgeLabel.text = nil
        onVideoDurationKnown = nil
        currentItem = nil
    }

    deinit {
        teardownPlayer()
    }

    private func teardownPlayer() {

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }

        player?.pause()
        player = nil

        playerLayer?.removeFromSuperlayer()
        playerLayer = nil

        videoContainer.isHidden = true
        loadingIcon.isHidden = true
        videoBadge.isHidden = true
    }
}

// MARK: - Audio session

/// الجلسة الصوتية حاجة عامة على مستوى التطبيق كله، فبنجمّع
/// التعامل معاها في مكان واحد بدل ما تتظبط من كذا مكان وتتضارب.
enum BannerAudioSession {

    /// للبانر المكتوم: مبيوقّفش صوت أي تطبيق تاني شغال.
    static func setAmbient() {
        try? AVAudioSession.sharedInstance()
            .setCategory(.ambient, mode: .default, options: [.mixWithOthers])
    }

    /// للفيديو بملء الشاشة: صوت شغال حتى لو مفتاح الصامت مقفول،
    /// لأن المستخدم هو اللي طلب يفتحه.
    static func setPlayback() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)
    }
}

