//
//  BullionScanView.swift
//  MSA
//
//  مسح كود QR على سبيكة والتأكد إنها مسجّلة عندنا.
//
//  ## الحكم من السيرفر مش من التطبيق
//
//  التطبيق بيبعت النص اللي الكاميرا قرته زي ما هو، والسيرفر بيطبّعه
//  (ممكن يكون رابط كامل)، بيدوّر عليه، بيسجّل المحاولة، وبيرجّع الحكم
//  **مع نصّه جاهز باللغة المطلوبة**.
//
//  يعني أندرويد و iOS وصفحة الويب بيقولوا نفس الكلام بالحرف لنفس
//  السبيكة. لو كل واحد كتب نصّه، أول تعديل في الصياغة كان لازم ينزل
//  ٣ مرات — ونسخة واحدة تتنسى فالعميل يشوف كلام مختلف حسب إيه اللي
//  مسح بيه.
//

import AVFoundation
import SwiftUI
import UIKit

// MARK: - الرد

struct APIBullionVerification: Decodable {
    /// valid | void | unknown
    let status: String
    let valid: Bool
    let title: String
    let message: String
    /// بيرجع للكود السليم بس — الملغي والمجهول بيرجّعوا `null`
    let bullion: APIBullionDetails?
}

struct APIBullionDetails: Decodable {
    let code: String
    let metal: String?
    let karat: Int?
    let weight_grams: Double?
    let serial: String?
}

private struct APIBullionEnvelope: Decodable {
    let data: APIBullionVerification
}

// MARK: - النداء

enum BullionCodeAPI {

    /**
     التحقّق من كود.

     مفتوح من غير توكن: العميل ممكن يمسح سبيكة قبل ما يعمل حساب
     أصلاً، والسبيكة أصلية أو لأ بغض النظر. لو فيه توكن بنبعته عشان
     السيرفر يربط المسح بصاحبه في السجل.
     */
    static func verify(code: String) async throws -> APIBullionVerification {
        let lang = L102Language.currentAppleLanguage() == "ar" ? "ar" : "en"

        guard let url = URL(string: hostName + "bullion-codes/verify?lang=\(lang)") else {
            throw ShopAPIError.network
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = AuthSession.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: ["code": code])

        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ShopAPIError.network
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        /*
         السيرفر بيرجّع ٢٠٠ للكود المجهول زي السليم بالظبط — ده نتيجة
         تحقّق مش خطأ في الطلب. فأي حالة برّه ٢xx معناها الشبكة أو
         السيرفر، وبتترمي كخطأ اتصال مش كـ«سبيكة مضروبة».
         */
        guard (200..<300).contains(status) else { throw ShopAPIError.network }

        do {
            return try JSONDecoder().decode(APIBullionEnvelope.self, from: data).data
        } catch {
            throw ShopAPIError.server("رد غير متوقع من السيرفر")
        }
    }
}

// MARK: - الحالة

@MainActor
final class BullionScanStore: ObservableObject {

    @Published var result: APIBullionVerification?
    @Published var checking = false
    /// فشل اتصال — **مش** نفس «الكود مش عندنا»
    @Published var networkFailed = false

    /*
     الكاميرا بتقرا نفس الكود عشرات المرات في الثانية طول ما هو
     قدّامها. من غير القفل ده كنا هنبعت عشرات الطلبات لنفس الكود،
     وكل واحد بيتسجّل عند المشرف — فسبيكة اتمسحت مرة تبان كأنها
     اتمسحت ٢٠٠ مرة.
     */
    private var busy = false

    func scanned(_ code: String) {
        guard !busy, result == nil, !networkFailed, !code.isEmpty else { return }
        busy = true
        checking = true

        Task {
            do {
                result = try await BullionCodeAPI.verify(code: code)
            } catch {
                networkFailed = true
            }
            checking = false
        }
    }

    func reset() {
        result = nil
        networkFailed = false
        checking = false
        busy = false
    }
}

// MARK: - الشاشة

struct BullionScanView: View {

    @StateObject private var store = BullionScanStore()
    @State private var cameraDenied = false
    /// الكاميرا مش متاحة (محاكي · مشغولة · عطل) — مش رفض إذن
    @State private var cameraUnavailable = false

    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "bullion_scan_title".localized, isBackShow: true) {
                onBack?()
            }

            if let result = store.result {
                ScrollView { resultCard(result) .padding(16) }
            } else if store.networkFailed {
                ScrollView { networkCard.padding(16) }
            } else if cameraDenied || cameraUnavailable {
                ScrollView { deniedCard.padding(16) }
            } else {
                camera
            }
        }
        .background(BGSwiftUIView())
    }

    // MARK: الكاميرا

    private var camera: some View {
        VStack(spacing: 16) {
            ZStack {
                QRCameraView(
                    onCode: { store.scanned($0) },
                    onDenied: { cameraDenied = true },
                    onUnavailable: { cameraUnavailable = true }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // إطار التصويب — بيقول للمستخدم يحط الكود فين
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color("MainColor").opacity(0.8), lineWidth: 2)
                    .frame(width: 220, height: 220)

                if store.checking {
                    Color.black.opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    Text("bullion_scan_checking".localized)
                        .font(.msa(16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 420)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Text("bullion_scan_hint".localized)
                .font(.msa(13))
                .foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer(minLength: 20)
        }
    }

    // MARK: النتيجة

    private func resultCard(_ result: APIBullionVerification) -> some View {
        /*
         اللون قبل الكلام: المستخدم واقف في محل ماسك سبيكة، وأول حاجة
         محتاج يعرفها هي «ماشي ولا لأ». النص بيشرح بعد كده.
         */
        let accent: Color = {
            switch result.status {
            case "valid": return Color(red: 0.30, green: 0.69, blue: 0.31)
            case "void":  return Color("MainColor")
            default:      return Color(red: 0.90, green: 0.22, blue: 0.21)
            }
        }()

        let glyph = result.status == "valid" ? "✓" : (result.status == "void" ? "!" : "✕")

        return VStack(spacing: 16) {
            badge(glyph, accent)

            Text(result.title)
                .font(.msa(20, weight: .bold))
                .foregroundColor(accent)
                .multilineTextAlignment(.center)

            Text(result.message)
                .font(.msa(14))
                .foregroundColor(Color(white: 0.8))
                .multilineTextAlignment(.center)

            if let bullion = result.bullion {
                VStack(spacing: 10) {
                    detailRow("bullion_scan_code".localized, bullion.code)

                    if let karat = bullion.karat {
                        // العيار مع اسم المعدن، زي صفحة الويب بالظبط
                        let metal = bullion.metal == "silver"
                            ? "silver".localized
                            : "gold".localized
                        detailRow("bullion_scan_karat".localized, "\(karat) \(metal)")
                    }
                    if let weight = bullion.weight_grams {
                        detailRow(
                            "bullion_scan_weight".localized,
                            Self.grams(weight) + " " + "bullion_scan_grams".localized
                        )
                    }
                    if let serial = bullion.serial {
                        detailRow("bullion_scan_serial".localized, serial)
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            scanAgainButton
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(accent.opacity(0.6), lineWidth: 1)
        )
    }

    /// فشل الاتصال — برتقالي مش أحمر، لأن مفيش حكم على السبيكة أصلاً
    private var networkCard: some View {
        VStack(spacing: 16) {
            badge("!", Color(red: 0.90, green: 0.49, blue: 0.13))

            Text("bullion_scan_offline_title".localized)
                .font(.msa(20, weight: .bold))
                .foregroundColor(Color(red: 0.90, green: 0.49, blue: 0.13))
                .multilineTextAlignment(.center)

            Text("bullion_scan_offline_message".localized)
                .font(.msa(14))
                .foregroundColor(Color(white: 0.8))
                .multilineTextAlignment(.center)

            scanAgainButton
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var deniedCard: some View {
        VStack(spacing: 16) {
            badge("!", Color("MainColor"))

            Text(cameraUnavailable
                 ? "bullion_scan_camera_unavailable".localized
                 : "bullion_scan_camera_denied".localized)
                .font(.msa(16, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // زرار الإعدادات مالوش لازمة لو الإذن مدّي أصلاً
            if !cameraUnavailable {
            Button {
                // الإذن بيتغيّر من الإعدادات بس — مفيش طريقة نطلبه
                // تاني بعد ما المستخدم رفض
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("bullion_scan_open_settings".localized)
                    .font(.msa(15, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("MainColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: عناصر مشتركة

    /**
     الوزن من غير أصفار زايدة.

     السيرفر بيرجّع `10.0` و`2.5`، والعرض المطلوب «١٠» و«٢٫٥» مش
     «١٠٫٠٠٠».

     **مش** `%g`: دي بتقرّب عند ٦ أرقام معنوية وبتحوّل للصيغة العلمية
     فوق المليون، فسبيكة ١٢٣٤٫٥٦٧ جرام كانت هتتعرض `1234.57` على iOS
     و`1234.567` على أندرويد والويب — نفس السبيكة برقمين مختلفين.
     */
    private static func grams(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func badge(_ glyph: String, _ color: Color) -> some View {
        Text(glyph)
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(color)
            .frame(width: 64, height: 64)
            .background(color.opacity(0.16))
            .clipShape(Circle())
            .overlay(Circle().stroke(color, lineWidth: 2))
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.msa(13))
                .foregroundColor(Color(white: 0.62))
            Spacer()
            Text(value)
                .font(.msa(13, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var scanAgainButton: some View {
        Button {
            store.reset()
        } label: {
            Text("bullion_scan_again".localized)
                .font(.msa(15, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color("MainColor"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - الكاميرا (AVFoundation)

/**
 معاينة كاميرا بتقرا أكواد QR.

 `UIViewControllerRepresentable` مش SwiftUI خالص: مفيش API في SwiftUI
 لقراءة الباركود، و`AVCaptureSession` محتاجة دورة حياة حقيقية عشان
 تقف مع اختفاء الشاشة — سيبها شغّالة معناه كاميرا شغّالة في الخلفية
 وبطارية بتفضى.
 */
private struct QRCameraView: UIViewControllerRepresentable {

    let onCode: (String) -> Void
    let onDenied: () -> Void
    let onUnavailable: () -> Void

    func makeUIViewController(context: Context) -> QRCameraViewController {
        let controller = QRCameraViewController()
        controller.onCode = onCode
        controller.onDenied = onDenied
        controller.onUnavailable = onUnavailable
        return controller
    }

    func updateUIViewController(_ controller: QRCameraViewController, context: Context) {}
}

private final class QRCameraViewController: UIViewController,
                                            AVCaptureMetadataOutputObjectsDelegate {

    var onCode: ((String) -> Void)?
    var onDenied: (() -> Void)?
    /// الكاميرا نفسها مش متاحة — مختلف عن رفض الإذن
    var onUnavailable: (() -> Void)?

    private let session = AVCaptureSession()
    private var preview: AVCaptureVideoPreviewLayer?

    /// طابور تسلسلي — الترتيب بين start و stop مضمون عليه
    private let sessionQueue = DispatchQueue(label: "msa.bullion.scanner.session")

    /// الجلسة اتظبطت خلاص؟ من غير ده `start` ممكن تشتغل على جلسة فاضية
    private var configured = false

    /// كود اتقرا خلاص — الفريمات اللي بعده بتتجاهل
    private var handled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        requestAccess()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
    }

    /**
     إعادة التشغيل مش زيادة.

     UIKit بينادي `viewWillDisappear` أول ما المستخدم يبدأ سحبة
     الرجوع — حتى لو رجع وسابها ولغى السحبة. من غير `viewWillAppear`
     هنا، الجلسة كانت بتقف ومفيش حاجة بتشغّلها، فالمستخدم بيلاقي
     معاينة سودا للأبد ومفيش طريقة يصلّحها غير ما يخرج ويدخل تاني.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }

    private func requestAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.configure() : self?.onDenied?()
                }
            }

        default:
            onDenied?()
        }
    }

    private func configure() {
        /*
         فشل هنا **مش** رفض إذن.

         محاكي من غير كاميرا، أو كاميرا ماسكها تطبيق تاني، أو عطل
         في الهاردوير — كلهم بيوصلوا هنا. كنا بنعرض «التطبيق محتاج
         إذن الكاميرا» وزرار بيودّي للإعدادات، فالمستخدم بيروح
         يلاقي الإذن مدّي أصلاً ومفيش أي طريقة يكمّل.
         */
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            onUnavailable?()
            return
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            onUnavailable?()
            return
        }
        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: .main)
        // QR بس — الباركودات التانية مش بتاعتنا وبتشوّش على القراءة
        output.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        preview = layer

        configured = true
        start()
    }

    /**
     تشغيل وإيقاف على **طابور واحد**.

     `startRunning` بتقفل الثريد الرئيسي لجزء من الثانية، فلازم تبقى
     في الخلفية. بس لو كل واحدة راحت على طابور عام لوحدها بيحصل
     سباق: المستخدم يفتح الشاشة ويرجع بسرعة، فـ`stop` تتنفّذ **قبل**
     ما `start` تخلّص، تلاقي `isRunning == false` وترجع من غير ما
     تعمل حاجة — وبعدها الكاميرا بتشتغل والمستخدم مشي.

     النتيجة كانت كاميرا شغّالة ونقطة الخصوصية نوّرة بعد الخروج من
     الشاشة. الطابور التسلسلي بيخلّي الترتيب مضمون.
     */
    private func start() {
        guard configured else { return }

        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    private func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              object.type == .qr,
              let value = object.stringValue else { return }

        /*
         الاهتزاز مرة واحدة بس.

         المعاينة بتفضل على الشاشة طول ما الطلب شغّال، والدليجيت
         بيتنادى مع كل فريم — يعني التليفون كان بيهتز من غير توقّف
         طول رحلة الشبكة. القفل هنا بيوقف ده من أصله، وبيوقف الجلسة
         كمان عشان ما نستهلكش كاميرا على فاضي.
         */
        guard !handled else { return }
        handled = true

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        stop()

        onCode?(value)
    }
}
