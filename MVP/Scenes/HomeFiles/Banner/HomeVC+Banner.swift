//
//  HomeVC+Banner.swift
//  MSA
//
//  ربط بانر الرئيسية — دلوقتي بيظهر كـ **popup في نص الشاشة** بدل ما
//  يكون شريط جوه المحتوى.
//
//  ملحوظة: الـ `banneView` بتاعة الـ 150 نقطة في Home.storyboard بقت
//  مخفية على طول. هي جوه stackView رأسي، فالـ stackView بيقفل مكانها
//  لوحده والشاشة بتترص عادي من غير فراغ.
//

import UIKit
import SwiftUI
import AVKit
import ObjectiveC

private var bannerPopupKey: UInt8 = 0

extension HomeVC {

    /// الـ popup المعروض دلوقتي (لو فيه).
    ///
    /// بنستخدم associated object لأن الـ extension مينفعش يضيف stored
    /// property. لو حبيت تنضّفها أكتر، انقل السطر ده جوه كلاس HomeVC:
    /// `weak var bannerPopup: BannerPopupVC?`
    ///
    /// RETAIN مش ASSIGN: الـ ASSIGN بتسيب pointer معلّق بعد ما الـ popup
    /// يتفكّ من الذاكرة، وأول ما نقراه بعدها التطبيق بيكراش. بنفضّيه
    /// بإيدينا في `onClosed`.
    var bannerPopup: BannerPopupVC? {
        get { objc_getAssociatedObject(self, &bannerPopupKey) as? BannerPopupVC }
        set { objc_setAssociatedObject(self, &bannerPopupKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Setup

    /// نادِها من `viewDidLoad` في HomeVC.
    ///
    /// `viewDidLoad` بتشتغل مرة واحدة لكل تشغيلة للتطبيق (الـ tab bar
    /// بيحتفظ بالـ HomeVC)، فالنداء على الـ API من هنا معناه إن الإعلان
    /// بيتجاب ويظهر مع كل فتحة للتطبيق.
    func setupBannerSlider() {

    

        loadBanners()
    }

    // MARK: - Loading

    func loadBanners() {

        // مفيش كاش — بنسأل الـ API على طول كل مرة.
        BannerService.fetchBanners { [weak self] items in
            self?.showPopupIfNeeded(items)
        }
    }

    private func showPopupIfNeeded(_ banners: [Banner], retry: Bool = true) {

        guard !banners.isEmpty else { return }

    
        guard BannerService.shouldShowPopup(banners) else { return }

       

        presentBannerPopup(banners)
    }

    private func presentBannerPopup(_ banners: [Banner]) {

        let popup = BannerPopupVC(items: banners)

        popup.onOpenLink = { [weak self] link in
            guard let url = URL(string: link) else { return }
            self?.openLink(url)
        }

        popup.onOpenMedia = { [weak self] item in
            self?.openBannerMedia(item)
        }

        popup.onClosed = { [weak self] in
            self?.bannerPopup = nil
        }

        bannerPopup = popup
        present(popup, animated: true)
    }

    // MARK: - فتح الميديا بملء الشاشة

    private func openBannerMedia(_ item: Banner) {

        switch item.mediaType {
        case .image: openImageViewer(item)
        case .video: openVideoPlayer(item)
        }
    }

    /// الصورة بتتفتح بملء الشاشة مع زووم إن وآوت.
    ///
    /// بنستخدم `PhotoDetialsVC` الموجودة أصلاً في المشروع (نفس الشاشة
    /// اللي `AllNewsVC` بيستخدمها) بدل ما نعمل واحدة جديدة.
    private func openImageViewer(_ item: Banner) {

        guard !item.mediaURL.isEmpty else { return }

        // الـ popup لسه معروض، فبنفتح من فوقه.
        let host = bannerPopup ?? self
        Helper.openZoomAbleImage(image: [item.mediaURL], vc: host, index: 0)
    }

    /// الفيديو بيتفتح بملء الشاشة، بالصوت، وبأزرار التحكم الكاملة
    /// (تشغيل، إيقاف، شريط تقدّم، AirPlay، picture-in-picture).
    private func openVideoPlayer(_ item: Banner) {

        guard let url = URL(string: item.mediaURL) else { return }

        // على عكس البانر، هنا المستخدم طلب الفيديو بنفسه —
        // فالصوت بيشتغل حتى لو مفتاح الصامت مقفول.
        BannerAudioSession.setPlayback()

        let player = AVPlayer(url: url)

        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .fullScreen
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.exitsFullScreenWhenPlaybackEnds = false

        let host = bannerPopup ?? self

        host.present(controller, animated: true) {
            player.play()
        }
    }

    private func openLink(_ link: URL) {

        let webView = WebView(url: link)
        let hosting = UIHostingController(rootView: webView)

        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hosting, animated: true)
    }

    // MARK: - Lifecycle hooks

    /// نادِها من `viewWillAppear` في HomeVC.
    func resumeBannerSlider() {

        // رجعنا من مشغل الفيديو أو من شاشة الزووم: نرجّع الجلسة الصوتية
        // لوضع "ما تزعجش حد" قبل ما البانر يشتغل تاني.
        BannerAudioSession.setAmbient()

        bannerPopup?.resumeSlider()
    }

    /// نادِها من `viewWillDisappear` في HomeVC.
    ///
    /// بنوقف بس، **مش بنقفل**: فتح عارض الصور أو مشغل الفيديو بيعمل
    /// `viewWillDisappear` للرئيسية كمان، فلو قفلنا هنا الـ popup هيختفي
    /// من ورا المستخدم وهو لسه بيتفرج.
    func pauseBannerSlider() {
        bannerPopup?.pauseSlider()
    }
}
