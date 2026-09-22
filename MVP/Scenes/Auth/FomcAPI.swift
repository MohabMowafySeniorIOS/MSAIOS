//
//  FomcAPI.swift
//  MSA
//
//  اجتماعات وقرارات الفيدرالي — من سيرفر MSA.
//
//  التطبيق عمره ما بيوصل لـ FRED ولا لموقع الفيدرالي. السيرفر هو اللي
//  بيزامن، والتطبيق بيقرا من الـ API بس — فلو المصدر الخارجي وقع،
//  التطبيق بيفضل شغّال على آخر بيانات صحيحة.
//
//  نفس نمط ContentAPI.swift بالظبط.
//

import Foundation

// MARK: - النموذج

struct APIFomcEvent: Decodable, Identifiable {
    let id: Int
    let external_id: String?
    let title: String?

    let meeting_start_at: String?
    let meeting_end_at: String?
    let decision_at: String?
    let press_conference_at: String?
    let minutes_at: String?

    let federal_funds_rate: Double?
    let rate_lower_bound: Double?
    let rate_upper_bound: Double?
    let previous_rate: Double?
    let rate_change: Double?

    /// الحالة زي ما السيرفر حسبها لحظة الرد — مرجع احتياطي بس،
    /// `status(at:)` تحت هي المصدر الحقيقي.
    let status: String?

    let has_press_conference: Bool?
    let has_projections: Bool?

    let statement_url: String?
    let minutes_url: String?
    let source_url: String?

    /// التوقيت الرسمي للحدث (America/New_York) — بيتعرض كسطر توضيحي بس
    let timezone: String?

    // MARK: التواريخ

    var meetingStart: Date? { FomcDate.parse(meeting_start_at) }
    var meetingEnd: Date? { FomcDate.parse(meeting_end_at) }
    var decision: Date? { FomcDate.parse(decision_at) }
    var pressConference: Date? { FomcDate.parse(press_conference_at) }
    var minutes: Date? { FomcDate.parse(minutes_at) }

    // MARK: الحالة

    /**
     الحالة بتتحسب محلياً من الوقت الحالي، مش من حقل `status` اللي جاي
     من السيرفر.

     السبب: الرد ممكن يكون من الكاش من ساعة، فلو اعتمدنا عليه كان اجتماع
     خلص من ساعة هيفضل ظاهر «قادم» والعدّاد التنازلي يمشي بالسالب.
     */
    func status(at now: Date = Date()) -> FomcStatus {
        guard let start = meetingStart else {
            return FomcStatus(raw: status)
        }

        if now < start { return .upcoming }

        // الاجتماع يفضل «جاري» لحد ما القرار يصدر، مش لحد نهاية اليوم.
        // نفس منطق FomcEvent::getStatusAttribute() في لارافيل.
        let closesAt = decision ?? meetingEnd ?? start

        return now > closesAt ? .completed : .inProgress
    }

    /// الوقت اللي العدّاد بيعدّ ناحيته: لحظة القرار لو معروفة، وإلا بداية الاجتماع
    var countdownTarget: Date? { decision ?? meetingStart }

    /// الثواني الفاضلة — `nil` لو الحدث عدّى، عشان الواجهة تخفي العدّاد
    /// بدل ما تعرض رقم بالسالب
    func secondsUntil(_ now: Date = Date()) -> TimeInterval? {
        guard let target = countdownTarget else { return nil }

        let remaining = target.timeIntervalSince(now)

        return remaining > 0 ? remaining : nil
    }

    /// اتجاه قرار الفائدة — من `rate_change` لو موجود، وإلا من الفرق
    /// بين الحالي والسابق
    var rateDirection: FomcRateDirection {
        let change: Double

        if let rate_change {
            change = rate_change
        } else if let federal_funds_rate, let previous_rate {
            change = federal_funds_rate - previous_rate
        } else {
            return .none
        }

        if change > 0.0001 { return .hike }
        if change < -0.0001 { return .cut }

        return .hold
    }
}

enum FomcStatus: String {
    case upcoming
    case inProgress = "in_progress"
    case completed

    init(raw: String?) {
        self = FomcStatus(rawValue: raw ?? "") ?? .upcoming
    }

    /// مفتاح الترجمة — النص نفسه في Localizable.strings مش هنا
    var title: String {
        switch self {
        case .upcoming:   return "fomc_status_upcoming".localized
        case .inProgress: return "fomc_status_in_progress".localized
        case .completed:  return "fomc_status_completed".localized
        }
    }
}

/// رفع / خفض / تثبيت
enum FomcRateDirection { case hike, cut, hold, none }

// MARK: - فك التاريخ

/**
 السيرفر بيرجّع ISO-8601 بتوقيت UTC: `2026-09-16T18:00:00Z`.

 بنجرّب الشكلين (بكسور ثواني ومن غيرها) لأن ISO8601DateFormatter بترفض
 اللي مش متوافق مع خياراتها بالظبط. تاريخ واحد بايظ بيرجّع `nil` بدل ما
 يوقّع الشاشة كلها.
 */
enum FomcDate {

    private static let plain: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let withFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static func parse(_ raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }

        return plain.date(from: raw) ?? withFraction.date(from: raw)
    }
}

// MARK: - المتجر

private struct FomcEnvelope<T: Decodable>: Decodable { let data: T }
private struct FomcOptionalEnvelope<T: Decodable>: Decodable { let data: T? }

/**
 اجتماعات الفيدرالي.

 بنجيب القايمة كاملة في طلب واحد ونقسّمها محلياً لقادم/سابق — ٨ اجتماعات
 في السنة، فالرد صغير والتقسيم في الذاكرة أرخص من طلبين.

 الكاش ١٥ دقيقة (نفس `FOMC_CACHE_TTL` في لارافيل): المستخدم بيفتح القايمة،
 يدخل تفاصيل، ويرجع — من غير الكاش كان هيتبعت طلب كل مرة لبيانات مبتتغيّرش
 غير كل كام أسبوع.
 */
@MainActor
final class FomcStore: ObservableObject {

    static let shared = FomcStore()
    private init() {}

    @Published private(set) var events: [APIFomcEvent] = []
    @Published private(set) var isLoading = false

    /// فشل التحميل. الشاشة بتعرض زرار إعادة محاولة بدل قايمة فاضية —
    /// «مفيش اجتماعات» و«الشبكة وقعت» مش نفس الرسالة للمستخدم.
    @Published private(set) var failed = false

    private var loadedAt: Date?
    private let cacheTTL: TimeInterval = 15 * 60

    private var isFresh: Bool {
        guard let loadedAt, !events.isEmpty else { return false }

        return Date().timeIntervalSince(loadedAt) < cacheTTL
    }

    func load(force: Bool = false) async {
        if isFresh && !force { return }

        isLoading = events.isEmpty
        failed = false

        // ١٠٠ هو أقصى limit مسموح في لارافيل — يغطي أكتر من ١٢ سنة
        guard let url = URL(string: hostName + "fomc/events?period=all&limit=100") else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let list = try JSONDecoder()
                .decode(FomcEnvelope<[APIFomcEvent]>.self, from: data).data

            events = list.sorted {
                ($0.meetingStart ?? .distantPast) > ($1.meetingStart ?? .distantPast)
            }
            loadedAt = Date()
            failed = false
        } catch {
            print("FomcStore: تعذّر تحميل الاجتماعات — \(error.localizedDescription)")
            // عندنا بيانات قديمة معروضة؟ سيبها — الفشل يبان بس لو مفيش حاجة
            failed = events.isEmpty
        }

        isLoading = false
    }

    /// الاجتماعات اللي لسه ما خلصتش، من الأقرب للأبعد
    func upcoming(at now: Date = Date()) -> [APIFomcEvent] {
        events
            .filter { $0.status(at: now) != .completed }
            .sorted { ($0.meetingStart ?? .distantFuture) < ($1.meetingStart ?? .distantFuture) }
    }

    func past(at now: Date = Date()) -> [APIFomcEvent] {
        events
            .filter { $0.status(at: now) == .completed }
            .sorted { ($0.meetingStart ?? .distantPast) > ($1.meetingStart ?? .distantPast) }
    }

    /**
     الاجتماع القادم — للعدّاد التنازلي.

     أقرب واحد لسه القرار بتاعه ما صدرش. ممكن يكون اجتماع منعقد دلوقتي،
     وده مقصود: المستخدم عايز يشوف عدّاد على القرار وهو جاري.
     */
    func next(at now: Date = Date()) -> APIFomcEvent? {
        let list = upcoming(at: now)

        return list.first { $0.secondsUntil(now) != nil } ?? list.first
    }

    func event(id: Int) -> APIFomcEvent? {
        events.first { $0.id == id }
    }

    /**
     الاجتماع القادم من السيرفر مباشرة — للكارت في الرئيسية قبل ما
     القايمة الكاملة تتحمّل.

     لو الكاش لسه صالح بنحسبه منه بدل طلب جديد.
     */
    func fetchNext() async -> APIFomcEvent? {
        if isFresh { return next() }

        guard let url = URL(string: hostName + "fomc/next") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            return try JSONDecoder()
                .decode(FomcOptionalEnvelope<APIFomcEvent>.self, from: data).data
        } catch {
            print("FomcStore: تعذّر تحميل الاجتماع القادم — \(error.localizedDescription)")
            return nil
        }
    }

    func invalidate() {
        loadedAt = nil
    }
}
