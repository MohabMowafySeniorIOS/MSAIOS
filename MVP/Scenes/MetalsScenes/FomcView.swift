//
//  FomcView.swift
//  MSA
//
//  اجتماعات الفيدرالي — التقويم والتفاصيل وكارت الرئيسية.
//  نفس الشاشات في أندرويد (FomcScreen.kt).
//

import SwiftUI

// MARK: - العناصر المشتركة

/// شارة الحالة — قادم / جاري / منتهي
struct FomcStatusChip: View {

    let status: FomcStatus

    private var color: Color {
        switch status {
        case .upcoming:   return Color("MainColor")
        case .inProgress: return Color(red: 0.09, green: 0.66, blue: 0.34)
        case .completed:  return Color(white: 0.62)
        }
    }

    var body: some View {
        Text(status.title)
            .font(.msa(12, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.6), lineWidth: 1)
            )
    }
}

/// العدّاد التنازلي — بيختفي تماماً لو الوقت عدّى بدل ما يعرض صفر
struct FomcCountdownView: View {

    let seconds: TimeInterval?
    var big = true

    var body: some View {
        if let text = MSAFormat.countdown(seconds) {
            VStack(spacing: 4) {
                Text("fomc_time_remaining".localized)
                    .font(.msa(12))
                    .foregroundColor(Color(white: 0.75))

                Text(text)
                    .font(.msa(big ? 24 : 17, weight: .bold))
                    .foregroundColor(Color("MainColor"))
            }
        }
    }
}

/**
 قرار الفائدة مع اتجاه التغيير.

 ما بيرسمش حاجة لو الفائدة لسه ما صدرتش: كارت باهت مكتوب فيه «—» في
 اجتماع قادم بيوحي إن فيه بيانات ناقصة، والصح إن الحقل ما يظهرش أصلاً.
 */
struct FomcRateBadge: View {

    let event: APIFomcEvent
    var compact = false

    private var directionColor: Color {
        switch event.rateDirection {
        case .hike: return Color(red: 0.90, green: 0.22, blue: 0.21)   // رفع = ضغط على الذهب
        case .cut:  return Color(red: 0.09, green: 0.66, blue: 0.34)
        default:    return .white
        }
    }

    var body: some View {
        if let rate = event.federal_funds_rate {
            HStack(spacing: 8) {
                Text(MSAFormat.rate(rate))
                    .font(.msa(compact ? 16 : 22, weight: .bold))
                    .foregroundColor(.white)

                if let change = MSAFormat.rateChange(event.rate_change) {
                    Text(change)
                        .font(.msa(compact ? 13 : 15, weight: .semibold))
                        .foregroundColor(directionColor)
                }
            }
        }
    }
}

/// كارت بنفس ستايل باقي التطبيق — أسود شفاف بحدود ذهبية
struct MSAPanel<Content: View>: View {

    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("MainColor").opacity(0.45), lineWidth: 1)
            )
    }
}

private struct FomcDetailRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.msa(14))
                .foregroundColor(Color(white: 0.78))

            Spacer()

            Text(value)
                .font(.msa(14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - تقويم الاجتماعات

/**
 فوق: الاجتماع القادم بعدّاد. تحت: التقويم الاقتصادي.

 تبويبتي «القادمة» و«السابقة» كانوا هنا واتشالوا — التفاصيل جوه
 `content`.

 الشاشة بتقرا من السيرفر بس، والسيرفر بيقرا من قاعدة بياناته — فلو
 المصدر الخارجي وقع، الشاشة بتفضل تعرض آخر بيانات صحيحة بدل ما تفضى.
 */
struct FomcCalendarView: View {

    @StateObject private var store = FomcStore.shared
    @StateObject private var calendarStore = CalendarStore.shared

    /**
     مفتاح صيانة الشاشة `FedralliMaintain` في `appVersion`.

     مراقب حيّ: قلب المفتاح من لوحة Firebase بيغيّر الشاشة للمستخدم
     اللي **فاتحها دلوقتي** من غير ما يقفل التطبيق ويفتحه.
     */
    @StateObject private var maintenance = ScreenMaintenanceObserver(.federal)

    @State private var secondsRemaining: TimeInterval?

    // التقويم: المدى المختار وورقة الفلتر
    @State private var calendarRange: CalendarRange = .today
    @State private var filterOpen = false

    var onBack: (() -> Void)?
    var onOpenEvent: ((Int) -> Void)?

    /// حدث في التقويم الاقتصادي — شاشة تفاصيل مختلفة عن الاجتماعات
    var onOpenCalendarEvent: ((Int) -> Void)?

    /// عدّاد الثانية. `.onReceive` بدل Task عشان يتوقف لوحده مع اختفاء
    /// الشاشة من غير ما نمسك مرجع ونلغيه بإيدينا.
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "fomc_title".localized, isBackShow: true) {
                onBack?()
            }

            /*
             الصيانة بتستبدل **جسم الشاشة بس**، والهيدر بزرار الرجوع
             فوقه فاضل مكانه.

             لو استخدمنا `bindScreenMaintenance` زي الرئيسية والدولار،
             الغطا كان هيغطي الـ`view` كله بما فيه الهيدر، والمستخدم
             اللي جاي من الرئيسية كان هيتحبس في صفحة مالهاش خروج.
             التبويبات مالهاش المشكلة دي لأن شريطها السفلي برّه الـview.
             */
            if maintenance.state.isUnderMaintenance {
                ScreenMaintenanceCardView(
                    title: maintenance.state.title,
                    message: maintenance.state.message
                )
            } else {
                /*
                 مفيش لودينج ولا شاشة خطأ على مستوى الشاشة كلها.

                 التقويم مصدره مختلف تماماً وبيتحمّل لوحده، فلو استنينا
                 بيانات الفيدرالي كان عطل فيها هيقفل التقويم من غير أي
                 سبب. كارت الاجتماع القادم بيظهر لما بياناته توصل، ولو
                 فشلت بيتخطّى بهدوء.
                 */
                content
            }
        }
        .background(BGSwiftUIView())
        /*
         `id:` مش زيادة.

         `.task` من غير `id` بتتنفّذ مرة واحدة مع ظهور الشاشة. لو
         العلم كان مرفوع ساعتها، الشرط تحت بيمنع التحميل — وبعدين لو
         المشرف نزّل العلم، الجسم بيرجع يظهر **من غير بيانات وما
         بيحمّلش تاني أبداً**: لا كارت ولا لودينج ولا زرار إعادة.

         ربطها بقيمة العلم بيخلّيها تتنفّذ من جديد أول ما يتغيّر،
         فالتحميل بيحصل في اللحظة اللي الشاشة بترجع فيها للخدمة.
         */
        .task(id: maintenance.state.isUnderMaintenance) {
            // مفيش داعي نضرب السيرفر والشاشة أصلاً مقفولة للصيانة
            guard !maintenance.state.isUnderMaintenance else { return }
            await store.load()
        }
        .onReceive(ticker) { _ in
            // العدّاد مالوش لازمة ورا كارت الصيانة
            guard !maintenance.state.isUnderMaintenance else { return }
            secondsRemaining = store.next()?.secondsUntil()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 12) {

                if let next = store.next() {
                    Button {
                        onOpenEvent?(next.id)
                    } label: {
                        nextHero(next)
                    }
                    .buttonStyle(.plain)
                }

                /*
                 تبويبتي «القادمة» و«السابقة» كانوا هنا واتشالوا.

                 قايمة اجتماعات الفيدرالي ٨ صفوف في السنة، والمستخدم
                 اللي فاتح الشاشة دي عايز يعرف «إيه الخبر الجاي» —
                 وده التقويم. الاجتماع القادم نفسه لسه فوق بعدّاده،
                 والضغط عليه بيفتح تفاصيله.
                 */
                CalendarSectionView(
                    store: calendarStore,
                    range: $calendarRange,
                    filterOpen: $filterOpen,
                    onOpenEvent: onOpenCalendarEvent
                )

                Spacer(minLength: 90)
            }
            .padding(.horizontal, 16)
        }
        .refreshable {
            // الاتنين: الكارت فوق من الفيدرالي والقايمة من التقويم
            await store.load(force: true)
            await calendarStore.load(force: true)
        }
        .sheet(isPresented: $filterOpen) {
            CalendarFilterSheet(store: calendarStore)
        }
    }

    private func nextHero(_ event: APIFomcEvent) -> some View {
        VStack(spacing: 10) {
            Text("fomc_next_meeting".localized)
                .font(.msa(13, weight: .semibold))
                .foregroundColor(Color("MainColor"))

            Text(MSAFormat.range(event.meetingStart, event.meetingEnd))
                .font(.msa(19, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            FomcStatusChip(status: event.status())

            FomcCountdownView(seconds: secondsRemaining ?? event.secondsUntil())

            if let decision = event.decision {
                Text(String(format: "fomc_decision_at_value".localized,
                            MSAFormat.dateTime(decision)))
                    .font(.msa(13))
                    .foregroundColor(Color(white: 0.78))
                    .multilineTextAlignment(.center)
            }

            // التوقيت الرسمي كسطر توضيحي — الوقت فوق بتوقيت الجهاز
            if let tz = event.timezone {
                Text(String(format: "fomc_official_timezone".localized, tz))
                    .font(.msa(11))
                    .foregroundColor(Color(white: 0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color("MainColor"), lineWidth: 1)
        )
    }

}

// MARK: - تفاصيل اجتماع

struct FomcEventDetailsView: View {

    let eventId: Int
    var onBack: (() -> Void)?

    @StateObject private var store = FomcStore.shared

    private var event: APIFomcEvent? { store.event(id: eventId) }

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "fomc_details_title".localized, isBackShow: true) {
                onBack?()
            }

            if let event {
                details(event)
            } else {
                Spacer()
                ProgressView().tint(Color("MainColor"))
                Spacer()
            }
        }
        .background(BGSwiftUIView())
        .task { await store.load() }
    }

    private func details(_ event: APIFomcEvent) -> some View {
        ScrollView {
            VStack(spacing: 12) {

                MSAPanel {
                    Text(MSAFormat.range(event.meetingStart, event.meetingEnd))
                        .font(.msa(20, weight: .bold))
                        .foregroundColor(.white)

                    FomcStatusChip(status: event.status())

                    if event.status() != .completed {
                        FomcCountdownView(seconds: event.secondsUntil())
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                }

                MSAPanel {
                    Text("fomc_section_schedule".localized)
                        .font(.msa(14, weight: .bold))
                        .foregroundColor(Color("MainColor"))

                    FomcDetailRow(label: "fomc_meeting_start".localized,
                                  value: MSAFormat.date(event.meetingStart))
                    FomcDetailRow(label: "fomc_meeting_end".localized,
                                  value: MSAFormat.date(event.meetingEnd))
                    FomcDetailRow(label: "fomc_decision_at".localized,
                                  value: MSAFormat.dateTime(event.decision))

                    if event.has_press_conference == true {
                        FomcDetailRow(label: "fomc_press_conference".localized,
                                      value: MSAFormat.dateTime(event.pressConference))
                    }

                    // المحضر بيصدر بعد ٣ أسابيع — ما بيظهرش قبل كده
                    if let minutes = event.minutes {
                        FomcDetailRow(label: "fomc_minutes_at".localized,
                                      value: MSAFormat.dateTime(minutes))
                    }

                    if let tz = event.timezone {
                        Text(String(format: "fomc_local_time_note".localized, tz))
                            .font(.msa(11))
                            .foregroundColor(Color(white: 0.6))
                            .padding(.top, 6)
                    }
                }

                // الفائدة بتظهر بس لو القرار صدر فعلاً
                if event.federal_funds_rate != nil {
                    MSAPanel {
                        Text("fomc_section_rate".localized)
                            .font(.msa(14, weight: .bold))
                            .foregroundColor(Color("MainColor"))

                        FomcRateBadge(event: event)

                        if let range = MSAFormat.rateRange(event.rate_lower_bound,
                                                           event.rate_upper_bound) {
                            FomcDetailRow(label: "fomc_target_range".localized, value: range)
                        }

                        if let previous = event.previous_rate {
                            FomcDetailRow(label: "fomc_previous_rate".localized,
                                          value: MSAFormat.rate(previous))
                        }

                        if let change = MSAFormat.rateChange(event.rate_change) {
                            FomcDetailRow(label: "fomc_rate_change".localized, value: change)
                        }
                    }
                }

                if event.has_projections == true {
                    MSAPanel {
                        Text("fomc_projections_note".localized)
                            .font(.msa(13))
                            .foregroundColor(Color(white: 0.78))
                    }
                }

                officialLinks(event)

                Text("fomc_source_note".localized)
                    .font(.msa(11))
                    .foregroundColor(Color(white: 0.6))
                    .multilineTextAlignment(.center)

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
        }
    }

    /// الروابط الرسمية بتتفتح في المتصفح: صفحات الفيدرالي فيها PDF
    /// وجداول مش مظبوطة لويب فيو جوّه التطبيق.
    @ViewBuilder
    private func officialLinks(_ event: APIFomcEvent) -> some View {
        // نوع صريح مش tuple: `ForEach` محتاج عنصر Identifiable أو
        // KeyPath، والـ tuples في Swift مش بتدعم KeyPath أصلاً.
        let links: [FomcLink] = [
            ("fomc_open_statement", event.statement_url),
            ("fomc_open_minutes", event.minutes_url),
            ("fomc_open_source", event.source_url)
        ].compactMap { key, raw in
            guard let raw, let url = URL(string: raw) else { return nil }

            return FomcLink(titleKey: key, url: url)
        }

        if !links.isEmpty {
            MSAPanel {
                Text("fomc_section_links".localized)
                    .font(.msa(14, weight: .bold))
                    .foregroundColor(Color("MainColor"))

                ForEach(links) { link in
                    Link(destination: link.url) {
                        Text(link.titleKey.localized)
                            .font(.msa(14, weight: .medium))
                            .foregroundColor(Color("MainColor"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("MainColor").opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.top, 6)
                }
            }
        }
    }
}

/// رابط رسمي واحد في شاشة التفاصيل
private struct FomcLink: Identifiable {
    let titleKey: String
    let url: URL

    var id: String { url.absoluteString }
}

// MARK: - كارت الرئيسية

/**
 كارت مضغوط للاجتماع القادم — بيتحط في الشاشة الرئيسية.

 بيختفي تماماً لو مفيش اجتماع معلن أو لو التحميل فشل: كارت مكتوب فيه
 «مفيش بيانات» وسط الرئيسية أسوأ من غيابه.
 */
struct FomcNextEventCard: View {

    var onTap: (() -> Void)?

    /**
     بيبلّغ المضيف بارتفاع الكارت الحقيقي.

     الكارت بيتحمّل من الشبكة، يعني ارتفاعه بيبدأ صفر وبيكبر لما
     الاجتماع يوصل. المضيف على iOS (`tableFooterView`) محتاج إطار
     برقم ثابت، فمن غير التبليغ ده الكارت كان هيتقاس وهو فاضي ويفضل
     مخفي للأبد.
     */
    var onHeightChange: ((CGFloat) -> Void)?

    @State private var event: APIFomcEvent?
    @State private var secondsRemaining: TimeInterval?

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if let event {
                Button { onTap?() } label: { card(event) }
                    .buttonStyle(.plain)
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { onHeightChange?(proxy.size.height) }
                    .onChange(of: proxy.size.height) { newHeight in
                        onHeightChange?(newHeight)
                    }
            }
        )
        .task {
            event = await FomcStore.shared.fetchNext()
            secondsRemaining = event?.secondsUntil()
        }
        .onReceive(ticker) { _ in
            guard let current = event else { return }

            secondsRemaining = current.secondsUntil()

            // الاجتماع بدأ / القرار صدر — نجيب اللي بعده
            if secondsRemaining == nil {
                Task {
                    FomcStore.shared.invalidate()
                    event = await FomcStore.shared.fetchNext()
                    secondsRemaining = event?.secondsUntil()
                }
            }
        }
    }

    private func card(_ event: APIFomcEvent) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("fomc_next_meeting".localized)
                    .font(.msa(13, weight: .bold))
                    .foregroundColor(Color("MainColor"))

                Spacer()

                FomcStatusChip(status: event.status())
            }

            Text(MSAFormat.range(event.meetingStart, event.meetingEnd))
                .font(.msa(16, weight: .semibold))
                .foregroundColor(.white)

            if let countdown = MSAFormat.countdown(secondsRemaining) {
                HStack(spacing: 8) {
                    Text("fomc_time_remaining".localized)
                        .font(.msa(12))
                        .foregroundColor(Color(white: 0.78))

                    Text(countdown)
                        .font(.msa(15, weight: .bold))
                        .foregroundColor(Color("MainColor"))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainColor").opacity(0.6), lineWidth: 1)
        )
    }
}
