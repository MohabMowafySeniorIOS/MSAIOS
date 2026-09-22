//
//  BranchAPI.swift
//  MSA
//
//  فروع الشركة — «أقرب فرع ليك».
//
//  الترتيب بالمسافة بيحصل في السيرفر (Haversine في SQL) مش في التطبيق:
//  منطق واحد مشترك بين iOS وأندرويد، وبيفضل شغّال لو عدد الفروع كبر.
//  التطبيق بيبعت نقطة ويستقبل قايمة جاهزة.
//

import Foundation
import CoreLocation

// MARK: - النموذج

struct APIBranch: Decodable, Identifiable {
    let id: Int

    let name_ar: String?
    let name_en: String?
    let address_ar: String?
    let address_en: String?
    let city_ar: String?
    let city_en: String?

    let latitude: Double?
    let longitude: Double?

    let phone: String?
    let whatsapp: String?

    let working_hours_ar: String?
    let working_hours_en: String?

    let image_url: String?
    let directions_url: String?

    /// المسافة بالكيلومتر — بيرجع بس لما الطلب يبعت إحداثيات المستخدم
    let distance_km: Double?

    // الاسم والعنوان بيرجعوا باللغتين والاختيار بيحصل هنا، فتبديل لغة
    // التطبيق مبيحتاجش طلب شبكة جديد. نفس نمط ContentAPI.swift.

    var name: String { pick(name_ar, name_en) ?? "" }
    var address: String? { pick(address_ar, address_en) }
    var city: String? { pick(city_ar, city_en) }
    var workingHours: String? { pick(working_hours_ar, working_hours_en) }

    private func pick(_ ar: String?, _ en: String?) -> String? {
        let arabic = L102Language.currentAppleLanguage() == "ar"
        let primary = arabic ? ar : en
        let fallback = arabic ? en : ar

        if let primary, !primary.isEmpty { return primary }

        return (fallback?.isEmpty == false) ? fallback : nil
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// الفرع اللي مالوش إحداثيات مش بيتعرضله مسافة ولا خريطة
    var hasLocation: Bool { coordinate != nil }
}

// MARK: - المتجر

private struct BranchEnvelope<T: Decodable>: Decodable { let data: T }

/**
 الفروع.

 مفتاح الكاش هو الموقع مقرّباً لـ٣ خانات عشرية (≈ ١١٠ متر): لو خزّنا
 بالإحداثيات الكاملة كان كل تحديث بسيط للموقع — والمستخدم واقف مكانه —
 بيدّي مفتاح جديد وطلب شبكة جديد على الفاضي. ولو اتحرك مسافة حقيقية
 المفتاح بيتغيّر والترتيب بيتحدّث.
 */
@MainActor
final class BranchStore: ObservableObject {

    static let shared = BranchStore()
    private init() {}

    @Published private(set) var branches: [APIBranch] = []
    @Published private(set) var isLoading = false
    @Published private(set) var failed = false

    /// الترتيب دلوقتي بالأقرب؟ الشاشة بتعرض شرح مختلف لكل حالة
    @Published private(set) var sortedByDistance = false

    private var cachedKey: String?
    private var loadedAt: Date?
    private let cacheTTL: TimeInterval = 10 * 60

    private func key(lat: Double?, lng: Double?) -> String {
        guard let lat, let lng else { return "no-location" }

        return String(format: "%.3f,%.3f", lat, lng)
    }

    func load(coordinate: CLLocationCoordinate2D?, force: Bool = false) async {
        let newKey = key(lat: coordinate?.latitude, lng: coordinate?.longitude)

        if !force,
           newKey == cachedKey,
           !branches.isEmpty,
           let loadedAt,
           Date().timeIntervalSince(loadedAt) < cacheTTL {
            sortedByDistance = coordinate != nil
            return
        }

        isLoading = branches.isEmpty
        failed = false

        var path = "branches"

        // الإحداثي الواحد لوحده بيرفضه السيرفر بـ422، فبنبعت الاتنين
        // أو ولا واحد
        if let coordinate {
            path += "?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)"
        }

        guard let url = URL(string: hostName + path) else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            branches = try JSONDecoder()
                .decode(BranchEnvelope<[APIBranch]>.self, from: data).data

            cachedKey = newKey
            loadedAt = Date()
            sortedByDistance = coordinate != nil
            failed = false
        } catch {
            print("BranchStore: تعذّر تحميل الفروع — \(error.localizedDescription)")
            failed = branches.isEmpty
        }

        isLoading = false
    }

    func branch(id: Int) -> APIBranch? {
        branches.first { $0.id == id }
    }
}

// MARK: - الموقع

/**
 موقع المستخدم لترتيب الفروع بالأقرب.

 **دقة تقريبية عن قصد** (`kCLLocationAccuracyKilometer`): الغرض ترتيب
 قايمة فروع مش ملاحة. بتقفل أسرع بكتير وبتستهلك بطارية أقل.

 طلب مرة واحدة (`requestLocation`) مش تتبّع مستمر.

 الإذن بيتطلب من **شاشة الفروع** مش عند فتح التطبيق: الطلب في سياقه
 («عايز أشوف أقرب فرع») نسبة قبوله أعلى بكتير، وبيوفّر سؤال في مراجعة
 App Store عن سبب طلب الموقع من غير مناسبة.
 */
@MainActor
final class UserLocationProvider: NSObject, ObservableObject {

    /// حالة الإذن زي ما الشاشة محتاجة تعرفها
    enum Access {
        case notDetermined
        case granted
        case denied
        /// الإذن موجود بس خدمة الموقع مقفولة في الجهاز
        case servicesOff
    }

    @Published private(set) var access: Access = .notDetermined

    private let manager = CLLocationManager()

    /// المهلة. جهاز جوّه مبنى ممكن ياخد وقت طويل للقفل، والمستخدم مش
    /// هيستنى — بعدها بنكمّل بالقايمة غير المرتّبة بدل شاشة تحميل بتلف.
    private let timeout: TimeInterval = 8

    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    private var timeoutTask: Task<Void, Never>?

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        refreshAccess()
    }

    func refreshAccess() {
        switch manager.authorizationStatus {
        case .notDetermined:
            access = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            access = CLLocationManager.locationServicesEnabled() ? .granted : .servicesOff
        default:
            access = .denied
        }
    }

    /// بيفتح نافذة الإذن. الرد بيوصل عن طريق `access`.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// بيرجّع موقع المستخدم، أو `nil` لو مفيش إذن / الخدمة مقفولة /
    /// المهلة خلصت.
    func current() async -> CLLocationCoordinate2D? {
        refreshAccess()

        guard access == .granted else { return nil }

        // لو فيه طلب شغّال، منبدأش تاني — بنسيب الأول يخلّص
        guard continuation == nil else { return nil }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            self.timeoutTask = Task { [weak self] in
                let nanos = UInt64((self?.timeout ?? 8) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanos)

                await self?.finish(with: nil)
            }

            manager.requestLocation()
        }
    }

    /**
     بينهي الطلب مرة واحدة بس — أي نداء بعديها بيتجاهل.

     من غير الحماية دي، وصول نتيجة بعد انتهاء المهلة كان هيستأنف نفس
     الـ continuation مرتين — وده **crash** في Swift مش مجرد باج.
     */
    private func finish(with coordinate: CLLocationCoordinate2D?) {
        guard let continuation else { return }

        self.continuation = nil
        timeoutTask?.cancel()
        timeoutTask = nil

        continuation.resume(returning: coordinate)
    }
}

extension UserLocationProvider: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in self?.refreshAccess() }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let coordinate = locations.last?.coordinate

        Task { @MainActor [weak self] in self?.finish(with: coordinate) }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // فشل تحديد الموقع مش خطأ يستاهل رسالة للمستخدم — الشاشة بتكمّل
        // بالقايمة غير المرتّبة
        Task { @MainActor [weak self] in self?.finish(with: nil) }
    }
}
