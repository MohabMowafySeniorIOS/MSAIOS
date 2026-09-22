//
//  CalendarAPI.swift
//  MSA
//
//  التقويم الاقتصادي — من سيرفر MSA.
//
//  التطبيق عمره ما بيوصل للمصدر الخارجي. السيرفر بيزامن كل ساعة،
//  والتطبيق بيقرا من الـ API بس — فلو المصدر وقع، التطبيق بيفضل
//  شغّال على آخر بيانات صحيحة. نفس نمط FomcAPI.swift بالظبط.
//

import Foundation

// MARK: - الأهمية

enum EventImpact: String, CaseIterable {
    case high, medium, low, holiday

    /// أي قيمة مش معروفة بترجع `low` بدل ما تكسر الشاشة
    init(raw: String?) {
        self = EventImpact(rawValue: (raw ?? "").lowercased()) ?? .low
    }

    var title: String {
        switch self {
        case .high:    return "calendar_impact_high".localized
        case .medium:  return "calendar_impact_medium".localized
        case .low:     return "calendar_impact_low".localized
        case .holiday: return "calendar_impact_holiday".localized
        }
    }
}

// MARK: - النموذج

/**
 حدث واحد في التقويم.

 ## القيمة نص ورقم

 `actual` نص زي ما صدر («$146.3B») و`actual_value` رقم (146.3). الصف
 بيعرض النص عشان الرمز والوحدة يبانوا، والرسم البياني بيرسم الرقم.

 ## `nil` معناها «لسه ما صدرش» مش صفر

 صفر في «معدل التضخم» خبر ضخم، وفاضي معناه الرقم لسه ما نزلش. كل
 الحقول الرقمية اختيارية عشان كده، والشاشة بتعرض «—».
 */
struct APICalendarEvent: Decodable, Identifiable {
    let id: Int
    let title: String?

    /// مفتاح المؤشر — ثابت عبر كل إصداراته
    let event_key: String?

    let currency: String?
    /// حرفين ISO — `flagEmoji` بيحوّلهم لعلم
    let country_code: String?

    let occurs_at: String?
    /// مفيش ساعة محددة («All Day» / «Tentative»)
    let all_day: Bool?

    let impact: String?

    let actual: String?
    let forecast: String?
    let previous: String?

    let actual_value: Double?
    let forecast_value: Double?
    let previous_value: Double?

    let unit: String?
    let category: String?
    let description: String?

    let source_url: String?

    // MARK: مشتقّات

    var date: Date? { FomcDate.parse(occurs_at) }
    var isAllDay: Bool { all_day ?? false }
    var eventImpact: EventImpact { EventImpact(raw: impact) }
    var name: String { title ?? "" }

    /**
     الفعلي أعلى ولا أقل من المتوقّع؟

     `nil` لو واحد منهم ناقص — ولون محايد أصدق من أخضر على مقارنة
     ما حصلتش.

     ⚠️ «أعلى» مش دايماً «أحسن»: تضخم أعلى من المتوقّع خبر وحش للدهب.
     الاسم `isAboveForecast` مش `isGood` عن قصد — الشاشة بتعرض
     الاتجاه والمستخدم بيفسّره.
     */
    var isAboveForecast: Bool? {
        guard let a = actual_value, let f = forecast_value, a != f else { return nil }

        return a > f
    }

    /// الوقت الفاضل للحدث — `nil` لو عدّى، عشان العدّاد يختفي بدل
    /// ما يعرض رقم بالسالب
    func secondsUntil(_ now: Date = Date()) -> TimeInterval? {
        guard let date else { return nil }

        let remaining = date.timeIntervalSince(now)

        return remaining > 0 ? remaining : nil
    }
}

/// يوم وأحداثه — التجميع جاي من السيرفر
struct APICalendarDay: Decodable {
    let date: String?
    let events: [APICalendarEvent]
}

struct APICalendarPayload: Decodable {
    let from: String?
    let to: String?
    let total: Int?
    let days: [APICalendarDay]
}

/// الحدث + الإصدار الجاي لنفس المؤشر
struct APICalendarDetails: Decodable {
    let event: APICalendarEvent
    /// `nil` لو مفيش إصدار جاي معلن
    let next: APICalendarEvent?
}

/// نقطة على الرسم البياني
struct APICalendarPoint: Decodable, Identifiable {
    let occurs_at: String?
    let actual: String?
    let value: Double
    let forecast: Double?

    var id: String { occurs_at ?? UUID().uuidString }
    var date: Date? { FomcDate.parse(occurs_at) }
}

struct APICalendarHistory: Decodable {
    let event_key: String?
    let title: String?
    let unit: String?

    /// الإصدارات اللي ليها رقم فعلي بس — دي اللي بتترسم
    let points: [APICalendarPoint]

    /// كل الإصدارات بما فيها اللي لسه ما صدرتش — لتبويب «التاريخ»
    let releases: [APICalendarEvent]
}

struct APICalendarCurrency: Decodable, Identifiable {
    let code: String
    let country_code: String?

    var id: String { code }
}

struct APICalendarFilters: Decodable {
    let currencies: [APICalendarCurrency]
    let impacts: [String]
}

// MARK: - المتجر

private struct CalendarEnvelope<T: Decodable>: Decodable { let data: T }

/// مدى التبويبات فوق
enum CalendarRange: CaseIterable {
    case yesterday, today, tomorrow, week

    var title: String {
        switch self {
        case .yesterday: return "calendar_yesterday".localized
        case .today:     return "calendar_today".localized
        case .tomorrow:  return "calendar_tomorrow".localized
        case .week:      return "calendar_this_week".localized
        }
    }
}

/**
 التقويم الاقتصادي.

 ## طلب واحد لكل التبويبات

 بنجيب من امبارح لحد ٧ أيام قدّام في طلب واحد، والتبويبات بتفلتر من
 نفس النتيجة — يعني تبديل التبويب فوري من غير لودينج.

 الفلتر (الأهمية والعملة) بيتطبّق في **السيرفر**: لو فلترنا محلياً كنا
 هنسحب مئات الأحداث عشان نعرض عشرة.

 ## الكاش دقيقتين بس

 `FomcStore` بيكاش ١٥ دقيقة لأن مواعيد الاجتماعات مبتتغيّرش غير كل
 كام أسبوع. هنا العكس: يوم صدور رقم مهم، خانة «الفعلي» بتتملي في
 ثواني — وكاش ربع ساعة معناه إن المستخدم يفتح الشاشة بعد الخبر
 ويلاقيها لسه فاضية.
 */
@MainActor
final class CalendarStore: ObservableObject {

    static let shared = CalendarStore()
    private init() {}

    @Published private(set) var days: [APICalendarDay] = []
    @Published private(set) var isLoading = false
    @Published private(set) var failed = false

    @Published private(set) var currencies: [APICalendarCurrency] = []

    /// الفلاتر — فاضية يعني من غير فلتر
    @Published var impacts: Set<EventImpact> = []
    @Published var selectedCurrencies: Set<String> = []

    var hasFilter: Bool { !impacts.isEmpty || !selectedCurrencies.isEmpty }

    private var loadedAt: Date?
    private var loadedKey: String?
    private let cacheTTL: TimeInterval = 2 * 60

    private var isFresh: Bool {
        guard let loadedAt, loadedKey == filterKey, !days.isEmpty else { return false }

        return Date().timeIntervalSince(loadedAt) < cacheTTL
    }

    /**
     لغة أسماء المؤشرات.

     المصدر بيبعتها بالإنجليزي بس والسيرفر بيعرّبها من قاموس عنده،
     فلازم نقول له اللغة. بناخدها من إعدادات **التطبيق**
     (`selectedLanguage`) مش من النظام: المستخدم ممكن يكون مختار
     عربي جوه التطبيق وجهازه إنجليزي — ودي نفس القيمة اللي
     `APIClient` بيبعتها في `Accept-Language`.
     */
    private var lang: String {
        let saved = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"

        return saved.lowercased().hasPrefix("ar") ? "ar" : "en"
    }

    /*
     اللغة جزء من مفتاح الكاش.

     من غيرها، تبديل لغة التطبيق كان بيسيب الأسماء القديمة معروضة
     لحد ما الكاش يقدم — يعني شاشة عربية فيها أسماء إنجليزية
     لدقيقتين.
     */
    private var filterKey: String {
        impacts.map(\.rawValue).sorted().joined(separator: ",")
            + "|" + selectedCurrencies.sorted().joined(separator: ",")
            + "|" + lang
    }

    // MARK: التحميل

    func load(force: Bool = false) async {
        if isFresh && !force { return }

        isLoading = days.isEmpty
        failed = false

        guard let url = buildURL() else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            days = try JSONDecoder()
                .decode(CalendarEnvelope<APICalendarPayload>.self, from: data).data.days

            loadedAt = Date()
            loadedKey = filterKey
            failed = false
        } catch {
            print("CalendarStore: تعذّر تحميل التقويم — \(error.localizedDescription)")
            // عندنا بيانات قديمة معروضة؟ سيبها — الفشل يبان بس لو مفيش حاجة
            failed = days.isEmpty
        }

        isLoading = false
    }

    private func buildURL() -> URL? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")

        let calendar = Calendar.current
        let today = Date()

        /*
         يوم زيادة على الطرفين.

         السيرفر بيفلتر بتوقيت UTC وإحنا بنعرض بتوقيت الجهاز، والفرق
         بينهم لحد ١٤ ساعة. من غير الهامش ده، أحداث أول يوم أو آخر
         يوم كانت هتقع بره المدى وتختفي.
         */
        let from = calendar.date(byAdding: .day, value: -2, to: today) ?? today
        let to = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        var items = [
            URLQueryItem(name: "from", value: fmt.string(from: from)),
            URLQueryItem(name: "to", value: fmt.string(from: to)),
            URLQueryItem(name: "lang", value: lang),
        ]

        if !impacts.isEmpty {
            items.append(URLQueryItem(
                name: "impact",
                value: impacts.map(\.rawValue).sorted().joined(separator: ",")
            ))
        }

        if !selectedCurrencies.isEmpty {
            items.append(URLQueryItem(
                name: "currencies",
                value: selectedCurrencies.sorted().joined(separator: ",")
            ))
        }

        var components = URLComponents(string: hostName + "calendar/events")
        components?.queryItems = items

        return components?.url
    }

    /**
     قايمة العملات للفلتر.

     بتتكاش لحد ما التطبيق يتقفل: العملات الموجودة مبتتغيّرش من ساعة
     للتانية، وفتح شاشة الفلتر ما يستاهلش طلب شبكة كل مرة.

     الفشل هنا **مش بيتعرض**: الفلتر بيفضل بالأهمية بس والشاشة
     الأساسية شغّالة. رسالة خطأ على حاجة ثانوية بتقلق من غير ما تفيد.
     */
    func loadCurrencies() async {
        guard currencies.isEmpty else { return }
        guard let url = URL(string: hostName + "calendar/filters") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            currencies = try JSONDecoder()
                .decode(CalendarEnvelope<APICalendarFilters>.self, from: data).data.currencies
        } catch {
            print("CalendarStore: تعذّر تحميل الفلاتر — \(error.localizedDescription)")
        }
    }

    // MARK: الفلاتر

    func toggle(_ impact: EventImpact) {
        if impacts.contains(impact) { impacts.remove(impact) } else { impacts.insert(impact) }
        Task { await load(force: true) }
    }

    func toggle(currency: String) {
        if selectedCurrencies.contains(currency) {
            selectedCurrencies.remove(currency)
        } else {
            selectedCurrencies.insert(currency)
        }
        Task { await load(force: true) }
    }

    func clearFilters() {
        impacts.removeAll()
        selectedCurrencies.removeAll()
        Task { await load(force: true) }
    }

    // MARK: التجميع بتوقيت الجهاز

    /**
     إعادة التجميع بتوقيت الجهاز.

     السيرفر بيجمّع بـ UTC. حدث الساعة ١١ م بتوقيت نيويورك بيبقى اليوم
     اللي بعده في UTC — فلو عرضنا تجميع السيرفر زي ما هو، مستخدم في
     القاهرة كان هيشوفه تحت عنوان يوم غلط.
     */
    func groupedDays(for range: CalendarRange, now: Date = Date()) -> [(date: Date, events: [APICalendarEvent])] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let all = days.flatMap(\.events)

        let grouped = Dictionary(grouping: all) { event -> Date? in
            event.date.map { calendar.startOfDay(for: $0) }
        }

        let wanted: (Date) -> Bool = { day in
            switch range {
            case .yesterday:
                return calendar.isDate(day, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? today)
            case .today:
                return calendar.isDate(day, inSameDayAs: today)
            case .tomorrow:
                return calendar.isDate(day, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today) ?? today)
            case .week:
                // «الأسبوع ده» = النهاردة و٦ أيام قدّام. امبارح مش
                // جواه عن قصد — التبويب ده عن اللي جاي.
                let end = calendar.date(byAdding: .day, value: 6, to: today) ?? today
                return day >= today && day <= end
            }
        }

        return grouped
            .compactMap { key, value -> (date: Date, events: [APICalendarEvent])? in
                guard let key, wanted(key) else { return nil }

                return (date: key, events: value.sorted {
                    ($0.date ?? .distantPast) < ($1.date ?? .distantPast)
                })
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: التفاصيل

    func details(id: Int) async -> APICalendarDetails? {
        guard let url = URL(string: hostName + "calendar/events/\(id)?lang=\(lang)") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            return try JSONDecoder()
                .decode(CalendarEnvelope<APICalendarDetails>.self, from: data).data
        } catch {
            print("CalendarStore: تعذّر تحميل تفاصيل الحدث — \(error.localizedDescription)")
            return nil
        }
    }

    func history(id: Int, limit: Int = 24) async -> APICalendarHistory? {
        guard let url = URL(string: hostName + "calendar/events/\(id)/history?limit=\(limit)&lang=\(lang)") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            return try JSONDecoder()
                .decode(CalendarEnvelope<APICalendarHistory>.self, from: data).data
        } catch {
            print("CalendarStore: تعذّر تحميل تاريخ المؤشر — \(error.localizedDescription)")
            return nil
        }
    }
}
