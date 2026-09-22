//
//  CalendarEventDetailsView.swift
//  MSA
//
//  تفاصيل حدث في التقويم الاقتصادي — الأرقام والوصف والرسم البياني.
//  نفس الشاشة في أندرويد (EventDetailsScreen.kt).
//

import SwiftUI

// MARK: - الرسم البياني

/**
 رسم سلسلة المؤشر.

 ## ليه Path بدل Swift Charts؟

 `Charts` متاح من iOS 16 بس، والتطبيق بينزل على نسخ أقدم. غير كده
 الرسم ده خط واحد ونقاط — الشكل الافتراضي للمكتبة كان هيحتاج شغل
 لتطويعه لألوان التطبيق أكتر من رسمه بإيدينا.

 ## المدى الرأسي

 بيتحسب من القيم نفسها مش من صفر. مؤشر بيتحرك بين 4.1% و4.3% لو
 رسمناه من صفر بيبقى خط مستقيم — والحركة اللي المستخدم فاتح الشاشة
 عشانها بتختفي. فيه هامش ١٠٪ فوق وتحت عشان النقاط ما تلزقش بالحواف.

 ## الاتجاه

 التطبيق عربي (RTL) بس **الزمن بيمشي من الشمال لليمين في أي لغة** —
 عرف عالمي في الرسوم البيانية. `environment(\.layoutDirection)`
 مضبوط على LTR على الرسم عشان الاتجاه ما يتقلبش.
 */
struct EventChartView: View {

    let points: [APICalendarPoint]
    let unit: String?

    private var values: [Double] { points.map(\.value) }

    var body: some View {
        // نقطة واحدة مش رسم — خط من غير طول مالوش معنى
        if points.count >= 2 {
            content
        }
    }

    private var content: some View {
        let rawMin = values.min() ?? 0
        let rawMax = values.max() ?? 0

        /*
         سلسلة كل قيمها واحدة (مؤشر ثابت زي سعر فايدة ما اتغيّرش).

         `max - min = 0` معناها قسمة على صفر. بنفتح مدى صناعي حوالين
         القيمة عشان الخط يظهر في النص بدل ما يختفي أو يدي NaN.
         */
        let rawSpan = rawMax - rawMin
        let span = rawSpan > 0 ? rawSpan : (abs(rawMax) > 0 ? abs(rawMax) * 0.1 : 1)

        let padding = span * 0.1
        let minValue = rawMin - padding
        let maxValue = rawMax + padding
        let range = (maxValue - minValue) > 0 ? (maxValue - minValue) : 1

        return VStack(alignment: .leading, spacing: 4) {

            // القيمة الأعلى والأدنى — بديل محور رأسي كامل، وأوضح منه
            // على عرض الموبايل
            Text(format(rawMax))
                .font(.msa(10))
                .foregroundColor(Color(white: 0.53))

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // خطوط شبكة أفقية — ٣ خطوط كفاية للقراءة من غير زحمة
                    ForEach(1..<4, id: \.self) { i in
                        Path { path in
                            let y = h * CGFloat(i) / 4
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: w, y: y))
                        }
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    }

                    // خط القيم
                    Path { path in
                        for (index, point) in points.enumerated() {
                            let position = CGPoint(
                                x: xOf(index, width: w),
                                y: yOf(point.value, height: h, min: minValue, range: range)
                            )

                            if index == 0 { path.move(to: position) }
                            else { path.addLine(to: position) }
                        }
                    }
                    .stroke(Color("MainColor"), lineWidth: 2.5)

                    // نقطة على كل إصدار — بتخلّي المستخدم يعدّ الإصدارات
                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        Circle()
                            .fill(Color("MainColor"))
                            .frame(width: 7, height: 7)
                            .position(
                                x: xOf(index, width: w),
                                y: yOf(point.value, height: h, min: minValue, range: range)
                            )
                    }

                    /*
                     آخر نقطة أكبر وبلون مميّز.

                     دي القيمة اللي نزلت آخر مرة — أهم رقم على الرسم،
                     ومن غير التمييز ده المستخدم لازم يتتبّع الخط عشان
                     يلاقيها.
                     */
                    if let last = points.last {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 11, height: 11)
                            .overlay(Circle().fill(Color("MainColor")).frame(width: 6, height: 6))
                            .position(
                                x: xOf(points.count - 1, width: w),
                                y: yOf(last.value, height: h, min: minValue, range: range)
                            )
                    }
                }
            }
            .frame(height: 144)
            // الزمن من الشمال لليمين حتى في الواجهة العربية
            .environment(\.layoutDirection, .leftToRight)

            Text(format(rawMin))
                .font(.msa(10))
                .foregroundColor(Color(white: 0.53))

            // محور التواريخ — الأول والآخر بس. ٢٤ تاريخ على عرض
            // الموبايل بيبقوا خط أسود مش معلومة.
            HStack {
                Text(CalendarFormat.chartLabel(points.first?.date))
                Spacer()
                Text(CalendarFormat.chartLabel(points.last?.date))
            }
            .font(.msa(10))
            .foregroundColor(Color(white: 0.53))
            .environment(\.layoutDirection, .leftToRight)

            // آخر قيمة بالنص الأصلي — الرسم بيدي الاتجاه، والرقم ده
            // بيدي الدقة
            if let label = points.last?.actual {
                Text(label)
                    .font(.msa(18, weight: .bold))
                    .foregroundColor(Color("MainColor"))
                    .padding(.top, 6)
            }
        }
    }

    private func xOf(_ index: Int, width: CGFloat) -> CGFloat {
        guard points.count > 1 else { return width / 2 }

        return CGFloat(index) / CGFloat(points.count - 1) * width
    }

    private func yOf(_ value: Double, height: CGFloat, min: Double, range: Double) -> CGFloat {
        height - CGFloat((value - min) / range) * height
    }

    /**
     رقم المحور.

     بنقصّه لخانتين عشريتين: المؤشرات الاقتصادية بتتنشر بخانة أو
     اتنين، وعرض `4.099999999` على المحور بيبان كأنه عطل.
     */
    private func format(_ value: Double) -> String {
        let text: String

        if value == value.rounded() {
            text = String(Int(value))
        } else {
            var trimmed = String(format: "%.2f", value)
            while trimmed.hasSuffix("0") { trimmed.removeLast() }
            if trimmed.hasSuffix(".") { trimmed.removeLast() }
            text = trimmed
        }

        return text + (unit ?? "")
    }
}

// MARK: - الشاشة

private enum DetailsTab: CaseIterable {
    case chart, history

    var title: String {
        switch self {
        case .chart:   return "calendar_chart".localized
        case .history: return "calendar_history".localized
        }
    }
}

/**
 تفاصيل حدث في التقويم الاقتصادي.

 ```
 ┌─────────────────────────────────┐
 │ الدولة 🇺🇸  الأهمية [عالي]  USD │
 ├────────────────┬────────────────┤
 │ آخر إصدار      │ الإصدار القادم │
 │ سابق   4.1%    │ التاريخ  ١٦ سب │
 │ متوقّع 4.2%    │ المتبقي  ١٨ د  │
 │ فعلي   4.3%    │ متوقّع   —     │
 ├────────────────┴────────────────┤
 │ التصنيف: التضخم   الوحدة: %     │
 │ وصف المؤشر… اعرض المزيد         │
 ├─────────────────────────────────┤
 │ [الرسم البياني] [التاريخ]        │
 └─────────────────────────────────┘
 ```
 */
struct CalendarEventDetailsView: View {

    let eventId: Int
    var onBack: (() -> Void)?

    @State private var details: APICalendarDetails?
    @State private var history: APICalendarHistory?
    @State private var isLoading = true
    @State private var failed = false
    @State private var tab: DetailsTab = .chart
    @State private var expanded = false
    @State private var secondsLeft: TimeInterval?

    /// عدّاد الثانية. `.onReceive` بدل Task عشان يتوقف لوحده مع اختفاء
    /// الشاشة من غير ما نمسك مرجع ونلغيه بإيدينا.
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: details?.event.name ?? "calendar_title".localized,
                       isBackShow: true) {
                onBack?()
            }

            if isLoading {
                Spacer()
                ProgressView().tint(Color("MainColor"))
                Spacer()

            } else if failed || details == nil {
                Spacer()
                Text("calendar_failed".localized)
                    .font(.msa(15))
                    .foregroundColor(.white)
                Spacer()

            } else {
                content
            }
        }
        .background(BGSwiftUIView())
        .task { await load() }
        .onReceive(ticker) { _ in
            secondsLeft = details?.next?.secondsUntil()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let details {
            ScrollView {
                VStack(spacing: 12) {

                    headerCard(details.event)

                    releasesCard(event: details.event, next: details.next)

                    // التصنيف والوصف بيظهروا **بس** لو فيهم قيمة.
                    // المصدر المجاني مبيبعتهمش، والقسم الفاضي كان
                    // هيبان كأن فيه بيانات ناقصة.
                    if details.event.category != nil
                        || details.event.unit != nil
                        || details.event.description != nil {
                        aboutCard(details.event)
                    }

                    tabsRow

                    if tab == .chart {
                        if let history, history.points.count >= 2 {
                            MSAPanel {
                                EventChartView(points: history.points, unit: history.unit)
                            }
                        } else {
                            noHistoryCard
                        }
                    } else {
                        if let history, !history.releases.isEmpty {
                            MSAPanel {
                                ForEach(history.releases) { release in
                                    releaseRow(release)
                                }
                            }
                        } else {
                            noHistoryCard
                        }
                    }

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: الكروت

    private func headerCard(_ event: APICalendarEvent) -> some View {
        MSAPanel {
            HStack(alignment: .top) {
                labelValue(
                    "calendar_country".localized,
                    flagEmoji(event.country_code).isEmpty
                        ? (event.currency ?? "—")
                        : flagEmoji(event.country_code)
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("calendar_impact".localized)
                        .font(.msa(11))
                        .foregroundColor(Color(white: 0.53))

                    ImpactChip(impact: event.eventImpact)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                labelValue("calendar_symbol".localized, event.currency ?? "—")
            }
        }
    }

    /**
     آخر إصدار جنب الإصدار القادم.

     العمودين جنب بعض مقصودين: المستخدم بيقارن الرقم اللي صدر بالرقم
     المتوقّع في المرة الجاية، والمقارنة دي أصعب لو كانوا تحت بعض.
     */
    private func releasesCard(event: APICalendarEvent, next: APICalendarEvent?) -> some View {
        MSAPanel {
            HStack(alignment: .top, spacing: 14) {

                VStack(alignment: .leading, spacing: 10) {
                    Text("calendar_latest_release".localized)
                        .font(.msa(14, weight: .bold))
                        .foregroundColor(.white)

                    line("calendar_previous".localized, event.previous)
                    line("calendar_consensus".localized, event.forecast)
                    line(
                        "calendar_actual".localized,
                        event.actual,
                        // نفس قاعدة الصف: أخضر = أعلى من المتوقّع،
                        // مش «خبر كويس»
                        color: {
                            switch event.isAboveForecast {
                            case .some(true):  return Color(red: 0.09, green: 0.66, blue: 0.34)
                            case .some(false): return Color(red: 0.90, green: 0.22, blue: 0.21)
                            case .none:        return .white
                            }
                        }()
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color("MainColor").opacity(0.2))
                    .frame(width: 1, height: 110)

                VStack(alignment: .leading, spacing: 10) {
                    Text("calendar_next_release".localized)
                        .font(.msa(14, weight: .bold))
                        .foregroundColor(.white)

                    if let next {
                        line("calendar_date".localized, CalendarFormat.releaseDate(next.date))
                        // `nil` لما الميعاد يعدّي — العدّاد بيختفي بدل
                        // ما يعرض رقم بالسالب
                        line(
                            "calendar_time_left".localized,
                            CalendarFormat.timeLeft(secondsLeft ?? next.secondsUntil()),
                            color: Color("MainColor")
                        )
                        line("calendar_consensus".localized, next.forecast)
                    } else {
                        Text("calendar_no_next_release".localized)
                            .font(.msa(12))
                            .foregroundColor(Color(white: 0.53))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func aboutCard(_ event: APICalendarEvent) -> some View {
        MSAPanel {
            HStack {
                if let category = event.category {
                    labelValue("calendar_category".localized, category)
                }
                if let unit = event.unit {
                    labelValue("calendar_unit".localized, unit)
                }
            }

            if let description = event.description {
                Text(description)
                    .font(.msa(13))
                    .foregroundColor(Color(white: 0.8))
                    // مقفول على ٣ سطور لحد ما المستخدم يفتحه — الوصف
                    // ممكن يبقى فقرة كاملة تدفن الرسم البياني تحتها
                    .lineLimit(expanded ? nil : 3)
                    .padding(.top, 6)

                Button {
                    expanded.toggle()
                } label: {
                    Text((expanded ? "calendar_show_less" : "calendar_show_more").localized)
                        .font(.msa(12, weight: .semibold))
                        .foregroundColor(Color("MainColor"))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tabsRow: some View {
        HStack(spacing: 8) {
            ForEach(DetailsTab.allCases, id: \.self) { value in
                let active = value == tab

                Button {
                    tab = value
                } label: {
                    Text(value.title)
                        .font(.msa(13, weight: .semibold))
                        .foregroundColor(active ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(active ? Color("MainColor") : Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("MainColor").opacity(active ? 1 : 0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    /**
     مفيش تاريخ لسه.

     السطر التاني مهم: المصدر بيدي الأسبوع الحالي بس، والتاريخ بيتكوّن
     من أرشيفنا إصدار ورا إصدار. من غير التوضيح ده، شاشة فاضية مكتوب
     عليها «مفيش بيانات» بتبان كعطل مش كحاجة بتتبني.
     */
    private var noHistoryCard: some View {
        MSAPanel {
            VStack(spacing: 8) {
                Text("calendar_no_history".localized)
                    .font(.msa(14))
                    .foregroundColor(.white)

                Text("calendar_history_building".localized)
                    .font(.msa(12))
                    .foregroundColor(Color(white: 0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func releaseRow(_ event: APICalendarEvent) -> some View {
        HStack {
            Text(CalendarFormat.releaseDate(event.date))
                .font(.msa(12))
                .foregroundColor(Color(white: 0.8))

            Spacer()

            Text(event.actual ?? "calendar_not_released".localized)
                .font(.msa(13, weight: .semibold))
                .foregroundColor(event.actual == nil ? Color(white: 0.4) : .white)
        }
        .padding(.vertical, 8)
    }

    // MARK: عناصر صغيرة

    private func labelValue(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.msa(11))
                .foregroundColor(Color(white: 0.53))

            Text(value)
                .font(.msa(15, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// سطر «لافتة ← قيمة». الفاضي «—» مش صفر.
    private func line(_ label: String, _ value: String?, color: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.msa(12))
                .foregroundColor(Color(white: 0.53))

            Spacer()

            Text(value ?? "—")
                .font(.msa(13, weight: .semibold))
                .foregroundColor(value == nil ? Color(white: 0.4) : color)
        }
    }

    // MARK: التحميل

    private func load() async {
        isLoading = true
        failed = false

        guard let loaded = await CalendarStore.shared.details(id: eventId) else {
            isLoading = false
            failed = true
            return
        }

        details = loaded
        isLoading = false

        /*
         التاريخ بيتجاب بعد التفاصيل مش معاها.

         الأرقام فوق هي اللي المستخدم فتح الشاشة عشانها؛ لو استنينا
         الطلبين مع بعض، طلب التاريخ البطيء كان هيأخّر ظهور معلومة
         جاهزة. وفشل التاريخ ما بيعطّلش الشاشة — تبويب الرسم بس اللي
         بيبقى فاضي.
         */
        history = await CalendarStore.shared.history(id: eventId)
    }
}
