//
//  CalendarView.swift
//  MSA
//
//  التقويم الاقتصادي — القايمة والتفاصيل.
//  نفس الشاشات في أندرويد (CalendarSection.kt / EventDetailsScreen.kt).
//

import SwiftUI

// MARK: - العلم

/**
 علم الدولة من كود ISO بحرفين.

 `US` → 🇺🇸. الحروف بتتحوّل لرموز «المؤشر الإقليمي» في يونيكود،
 والنظام بيرسمهم كعلم.

 ليه إيموجي مش صور؟ ٢٥ علم × ٣ كثافات = ٧٥ ملف في الـ bundle لحاجة
 النظام بيرسمها ببلاش، وأي عملة جديدة من السيرفر كانت هتحتاج تحديث
 للتطبيق.
 */
func flagEmoji(_ countryCode: String?) -> String {

    guard let code = countryCode?.trimmingCharacters(in: .whitespaces).uppercased(),
          code.count == 2,
          code.allSatisfy({ $0.isLetter })
    else { return "" }

    // 0x1F1E6 هو رمز المؤشر الإقليمي للحرف A
    let base: UInt32 = 0x1F1E6 - 65

    var flag = ""

    for scalar in code.unicodeScalars {
        guard let value = UnicodeScalar(base + scalar.value) else { return "" }
        flag.unicodeScalars.append(value)
    }

    return flag
}

// MARK: - تنسيقات

enum CalendarFormat {

    /// الساعة بتوقيت الجهاز، أو «طول اليوم» للأحداث اللي مالهاش ميعاد
    static func time(_ event: APICalendarEvent) -> String {
        if event.isAllDay { return "calendar_all_day".localized }

        guard let date = event.date else { return "—" }

        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        fmt.locale = Locale(identifier: "en_US_POSIX")

        return fmt.string(from: date)
    }

    /**
     عنوان اليوم: «النهاردة» / «بكرة» / «امبارح»، وإلا التاريخ كامل.

     الكلمات النسبية بتخلّي المستخدم يعرف مكانه من غير ما يحسب
     التاريخ — وهي نفس لغة التبويبات فوق.
     */
    static func dayHeader(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date)     { return "calendar_today".localized }
        if calendar.isDateInTomorrow(date)  { return "calendar_tomorrow".localized }
        if calendar.isDateInYesterday(date) { return "calendar_yesterday".localized }

        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE، d MMMM yyyy"
        fmt.locale = Locale.current

        return fmt.string(from: date)
    }

    static func releaseDate(_ date: Date?) -> String {
        guard let date else { return "—" }

        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM yyyy"
        fmt.locale = Locale.current

        return fmt.string(from: date)
    }

    /// «سبتمبر ٢٦» — محور الرسم البياني
    static func chartLabel(_ date: Date?) -> String {
        guard let date else { return "" }

        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yy"
        fmt.locale = Locale.current

        return fmt.string(from: date)
    }

    /**
     الوقت الفاضل: «٣ س ١٥ د».

     `nil` لو الميعاد عدّى — عدّاد بالسالب معناه بيانات غلط، والصح
     إنه يختفي.
     */
    static func timeLeft(_ seconds: TimeInterval?) -> String? {
        guard let seconds, seconds > 0 else { return nil }

        let total = Int(seconds)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60

        if days > 0  { return String(format: "calendar_left_days".localized, days, hours) }
        if hours > 0 { return String(format: "calendar_left_hours".localized, hours, minutes) }

        return String(format: "calendar_left_minutes".localized, minutes)
    }
}

// MARK: - عناصر مشتركة

extension EventImpact {
    /// أحمر للعالي، ذهبي للمتوسط، أخضر للمنخفض، رمادي للعطلة
    var color: Color {
        switch self {
        case .high:    return Color(red: 0.90, green: 0.22, blue: 0.21)
        case .medium:  return Color("MainColor")
        case .low:     return Color(red: 0.09, green: 0.66, blue: 0.34)
        case .holiday: return Color(white: 0.62)
        }
    }
}

/// شارة الأهمية — نفس شكل `FomcStatusChip` عشان الشاشتين يبقوا عيلة واحدة
struct ImpactChip: View {

    let impact: EventImpact
    var compact = false

    var body: some View {
        Text(impact.title)
            .font(.msa(compact ? 10 : 12, weight: .semibold))
            .foregroundColor(impact.color)
            .padding(.horizontal, compact ? 6 : 10)
            .padding(.vertical, 2)
            .background(impact.color.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(impact.color.opacity(0.6), lineWidth: 1)
            )
    }
}

/**
 علم + كود العملة.

 الكود بيتعرض **دايماً** جنب العلم مش بدله: لو العلم ما ظهرش لأي سبب،
 المستخدم لسه شايف `USD` ومفيش معلومة ضاعت.
 */
struct CurrencyBadge: View {

    let currency: String?
    let countryCode: String?

    var body: some View {
        VStack(spacing: 2) {
            let flag = flagEmoji(countryCode)

            if !flag.isEmpty {
                Text(flag).font(.system(size: 20))
            }

            Text(currency ?? "")
                .font(.msa(11, weight: .semibold))
                .foregroundColor(Color(white: 0.8))
        }
    }
}

/**
 خانة رقم واحدة.

 الفاضي «—» مش «0». الفرق مش تجميلي: صفر في «معدل التضخم» خبر ضخم،
 و«—» معناها الرقم لسه ما نزلش.
 */
private struct ValueCell: View {

    let label: String
    let value: String?
    var color: Color = .white

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.msa(9))
                .foregroundColor(Color(white: 0.53))
                .lineLimit(1)

            Text(value ?? "—")
                .font(.msa(12, weight: .semibold))
                .foregroundColor(value == nil ? Color(white: 0.4) : color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/**
 صف حدث في القايمة.

 الشريط الملوّن على الحافة بيخلّي المستخدم يمسح القايمة بعينه ويلاقي
 الأحداث المهمة من غير ما يقرا الشارة.
 */
struct CalendarEventRow: View {

    let event: APICalendarEvent

    var body: some View {
        HStack(spacing: 0) {

            // شريط الأهمية على الحافة
            Rectangle()
                .fill(event.eventImpact.color)
                .frame(width: 3)

            HStack(spacing: 10) {

                // الوقت + الشارة
                VStack(alignment: .leading, spacing: 4) {
                    Text(CalendarFormat.time(event))
                        .font(.msa(event.isAllDay ? 11 : 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    ImpactChip(impact: event.eventImpact, compact: true)
                }
                .frame(width: 62, alignment: .leading)

                // الاسم + الأرقام
                VStack(alignment: .leading, spacing: 5) {
                    Text(event.name)
                        .font(.msa(13, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        ValueCell(
                            label: "calendar_actual".localized,
                            value: event.actual,
                            /*
                             لون الفعلي بيتبع اتجاهه عن المتوقّع.

                             ⚠️ أخضر هنا معناه «أعلى من المتوقّع» مش
                             «خبر كويس»: تضخم أعلى من المتوقّع خبر وحش
                             للدهب. الشاشة بتعرض الاتجاه، والمستخدم
                             بيفسّره.
                             */
                            color: {
                                switch event.isAboveForecast {
                                case .some(true):  return Color(red: 0.09, green: 0.66, blue: 0.34)
                                case .some(false): return Color(red: 0.90, green: 0.22, blue: 0.21)
                                case .none:        return .white
                                }
                            }()
                        )
                        ValueCell(
                            label: "calendar_consensus".localized,
                            value: event.forecast,
                            color: Color(white: 0.8)
                        )
                        ValueCell(
                            label: "calendar_previous".localized,
                            value: event.previous,
                            color: Color(white: 0.8)
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)

                CurrencyBadge(currency: event.currency, countryCode: event.country_code)
            }
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("MainColor").opacity(0.25), lineWidth: 1)
        )
    }
}

/// عنوان اليوم بين المجموعات
struct CalendarDayHeader: View {

    let date: Date

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color("MainColor").opacity(0.2))
                .frame(height: 1)

            Text(CalendarFormat.dayHeader(date))
                .font(.msa(13, weight: .bold))
                .foregroundColor(Color("MainColor"))
                .fixedSize()

            Rectangle()
                .fill(Color("MainColor").opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - قسم التقويم

/**
 قسم التقويم جوه شاشة «مواعيد الفيدرالي».

 الاتنين نفس السياق: «إمتى الخبر اللي هيحرّك الدهب». شاشة منفصلة كانت
 هتحتاج المستخدم يعرف إنها موجودة أصلاً؛ تبويب جنب «القادمة»
 و«السابقة» بيخلّيه يلاقيها وهو بيدوّر على موعد الاجتماع.
 */
struct CalendarSectionView: View {

    @ObservedObject var store: CalendarStore
    @Binding var range: CalendarRange
    @Binding var filterOpen: Bool

    var onOpenEvent: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 10) {

            rangeTabs

            if store.isLoading && store.days.isEmpty {
                ProgressView()
                    .tint(Color("MainColor"))
                    .padding(.vertical, 60)

            } else if store.failed {
                VStack(spacing: 12) {
                    Text("calendar_failed".localized)
                        .font(.msa(15))
                        .foregroundColor(.white)

                    Button("retry".localized) {
                        Task { await store.load(force: true) }
                    }
                    .font(.msa(15, weight: .bold))
                    .foregroundColor(Color("MainColor"))
                }
                .padding(.vertical, 40)

            } else {
                let groups = store.groupedDays(for: range)

                if groups.isEmpty {
                    // رسالة مختلفة لما يكون فيه فلتر: «مفيش أحداث» على
                    // يوم مفلتر بتخلّي المستخدم يفتكر إن التقويم بايظ
                    // بدل ما يفك الفلتر
                    Text((store.hasFilter ? "calendar_empty_filtered" : "calendar_empty").localized)
                        .font(.msa(14))
                        .foregroundColor(Color(white: 0.6))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(groups, id: \.date) { group in
                        CalendarDayHeader(date: group.date)

                        ForEach(group.events) { event in
                            Button {
                                onOpenEvent?(event.id)
                            } label: {
                                CalendarEventRow(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // مصدر بيانات التقويم — مختلف عن مصدر الاجتماعات، فلازم
            // يتقال لوحده
            Text("calendar_source_note".localized)
                .font(.msa(11))
                .foregroundColor(Color(white: 0.6))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        }
        .task {
            await store.load()
            await store.loadCurrencies()
        }
    }

    /**
     تبويبات المدى + زرار الفلتر.

     التبويبات في صف بيسكرول أفقياً: «الأسبوع ده» بالعربي أطول من
     «This Week»، وعلى شاشة ضيّقة الأربع تبويبات الثابتة كانت هتتقص.
     */
    private var rangeTabs: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(CalendarRange.allCases, id: \.self) { value in
                        let active = value == range

                        Button {
                            // تبديل التبويب فلترة محلية بس — مفيش طلب شبكة
                            range = value
                        } label: {
                            Text(value.title)
                                .font(.msa(13, weight: .semibold))
                                .foregroundColor(active ? .black : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(active ? Color("MainColor") : Color.black.opacity(0.4))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color("MainColor").opacity(active ? 1 : 0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }

            // زرار الفلتر — نقطة ذهبية فوقه لما يكون شغّال، عشان
            // المستخدم ما يقعدش يدوّر على أحداث مخفية من غير ما يعرف
            // السبب
            Button {
                filterOpen = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15))
                        .foregroundColor(store.hasFilter ? Color("MainColor") : Color(white: 0.8))
                        .frame(width: 38, height: 38)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color("MainColor").opacity(0.4), lineWidth: 1)
                        )

                    if store.hasFilter {
                        Circle()
                            .fill(Color("MainColor"))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - ورقة الفلتر

/**
 الأهمية والعملة.

 العملات جاية من السيرفر مش مكتوبة في التطبيق: لو المصدر ضاف عملة أو
 وقّف واحدة، القايمة بتتحدّث لوحدها من غير تحديث للتطبيق.
 */
struct CalendarFilterSheet: View {

    @ObservedObject var store: CalendarStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 74), spacing: 6)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("calendar_filter".localized)
                .font(.msa(16, weight: .bold))
                .foregroundColor(Color("MainColor"))

            Text("calendar_filter_impact".localized)
                .font(.msa(13))
                .foregroundColor(Color(white: 0.8))

            HStack(spacing: 8) {
                ForEach([EventImpact.high, .medium, .low], id: \.self) { impact in
                    let active = store.impacts.contains(impact)

                    Button {
                        store.toggle(impact)
                    } label: {
                        Text(impact.title)
                            .font(.msa(12, weight: .semibold))
                            .foregroundColor(active ? impact.color : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(active ? impact.color.opacity(0.25) : Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(impact.color.opacity(active ? 0.9 : 0.25), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            if !store.currencies.isEmpty {
                Text("calendar_filter_currency".localized)
                    .font(.msa(13))
                    .foregroundColor(Color(white: 0.8))

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(store.currencies) { currency in
                            let active = store.selectedCurrencies.contains(currency.code)

                            Button {
                                store.toggle(currency: currency.code)
                            } label: {
                                HStack(spacing: 4) {
                                    let flag = flagEmoji(currency.country_code)
                                    if !flag.isEmpty { Text(flag).font(.system(size: 13)) }

                                    Text(currency.code)
                                        .font(.msa(12, weight: .semibold))
                                        .foregroundColor(active ? Color("MainColor") : .white)
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(active ? Color("MainColor").opacity(0.22) : Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(Color("MainColor").opacity(active ? 0.9 : 0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 220)
            }

            HStack(spacing: 10) {
                Button {
                    store.clearFilters()
                } label: {
                    Text("calendar_filter_reset".localized)
                        .font(.msa(13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("MainColor").opacity(0.4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("calendar_filter_apply".localized)
                        .font(.msa(13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color("MainColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BGSwiftUIView())
    }
}
