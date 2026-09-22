//
//  FomcFormatters.swift
//  MSA
//
//  تنسيق أوقات الاجتماعات ومسافات الفروع.
//
//  القاعدة الأساسية هنا: **مفيش أي منطقة زمنية ثابتة في الواجهة**.
//  السيرفر بيرجّع UTC وإحنا بنعرض بـ TimeZone.current — يعني توقيت جهاز
//  المستخدم. اللي في القاهرة بيشوف ٨ م واللي في لندن بيشوف ٦ م لنفس
//  اللحظة، وده المطلوب.
//

import Foundation

enum MSAFormat {

    /// لغة الواجهة الفعلية مش لغة الجهاز — عشان لو المستخدم مغيّر لغة
    /// التطبيق لعربي والجهاز إنجليزي، التاريخ يتعرض عربي زي باقي الشاشة.
    private static var locale: Locale {
        Locale(identifier: L102Language.currentAppleLanguage())
    }

    // MARK: التواريخ

    private static func formatter(
        date: DateFormatter.Style,
        time: DateFormatter.Style
    ) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = .current      // ← توقيت الجهاز، مش ثابت
        formatter.dateStyle = date
        formatter.timeStyle = time

        return formatter
    }

    /// ١٦ سبتمبر ٢٠٢٦
    static func date(_ value: Date?) -> String {
        guard let value else { return "—" }

        return formatter(date: .long, time: .none).string(from: value)
    }

    /// ١٦ سبتمبر ٢٠٢٦، ٨:٠٠ م
    static func dateTime(_ value: Date?) -> String {
        guard let value else { return "—" }

        return formatter(date: .medium, time: .short).string(from: value)
    }

    /// مدى الاجتماع: «١٥ – ١٦ سبتمبر ٢٠٢٦»، أو تاريخ واحد لو يوم واحد
    static func range(_ start: Date?, _ end: Date?) -> String {
        guard let start else { return "—" }
        guard let end else { return date(start) }

        var calendar = Calendar.current
        calendar.timeZone = .current

        if calendar.isDate(start, inSameDayAs: end) { return date(start) }

        // نفس الشهر → «١٥ – ١٦ سبتمبر ٢٠٢٦» بدل تكرار الشهر مرتين
        if calendar.isDate(start, equalTo: end, toGranularity: .month) {
            let dayOnly = DateFormatter()
            dayOnly.locale = locale
            dayOnly.timeZone = .current
            dayOnly.setLocalizedDateFormatFromTemplate("d")

            return "\(dayOnly.string(from: start)) – \(date(end))"
        }

        return "\(date(start)) – \(date(end))"
    }

    // MARK: العدّاد

    /**
     «٣ ي ١٢ س ٤ د» — الوحدات مترجمة في Localizable.strings.

     بنعرض يوم/ساعة/دقيقة من غير ثواني لما يكون فاضل أكتر من ساعة: عدّاد
     ثواني في حدث بعيد بأسابيع بيلفت النظر من غير فايدة وبيخلّي الواجهة
     تعيد الرسم كل ثانية على الفاضي.

     بيرجّع `nil` لو الوقت عدّى — الواجهة بتخفي العدّاد بالكامل وقتها بدل
     ما تعرض صفر أو رقم بالسالب.
     */
    static func countdown(_ seconds: TimeInterval?) -> String? {
        guard let seconds, seconds > 0 else { return nil }

        let total = Int(seconds)
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60

        let number = NumberFormatter()
        number.locale = locale

        func n(_ value: Int) -> String {
            number.string(from: NSNumber(value: value)) ?? "\(value)"
        }

        if days > 0 {
            return String(format: "fomc_countdown_dhm".localized, n(days), n(hours), n(minutes))
        }

        if hours > 0 {
            return String(format: "fomc_countdown_hms".localized, n(hours), n(minutes), n(secs))
        }

        return String(format: "fomc_countdown_ms".localized, n(minutes), n(secs))
    }

    // MARK: الفائدة

    /// «٤٫٢٥٪» — بنقص الأصفار الزايدة: الفيدرالي بيتحرك بربع نقطة، فـ
    /// «4.25» و«4.5» هما الشكلين الطبيعيين و«4.500» بتبان غلط.
    static func rate(_ value: Double?) -> String {
        guard let value else { return "—" }

        let number = NumberFormatter()
        number.locale = locale
        number.minimumFractionDigits = 0
        number.maximumFractionDigits = 3

        let text = number.string(from: NSNumber(value: value)) ?? "\(value)"

        return String(format: "fomc_rate_percent".localized, text)
    }

    static func rateRange(_ lower: Double?, _ upper: Double?) -> String? {
        guard let lower, let upper else { return nil }

        return "\(rate(lower)) – \(rate(upper))"
    }

    /// «+٠٫٢٥٪» أو «−٠٫٢٥٪» — بإشارة صريحة
    static func rateChange(_ value: Double?) -> String? {
        guard let value, abs(value) >= 0.0001 else { return nil }

        return (value > 0 ? "+" : "−") + rate(abs(value))
    }

    // MARK: المسافة

    /// أقل من كيلومتر بيتعرض بالمتر: «٣٠٠ م» أوضح بكتير من «٠٫٣ كم»
    /// للمستخدم اللي الفرع على بعد شارع منه.
    static func distance(_ km: Double?) -> String? {
        guard let km else { return nil }

        let number = NumberFormatter()
        number.locale = locale

        if km < 1.0 {
            number.maximumFractionDigits = 0
            let text = number.string(from: NSNumber(value: km * 1000)) ?? "\(Int(km * 1000))"

            return String(format: "branch_distance_m".localized, text)
        }

        number.maximumFractionDigits = 1
        let text = number.string(from: NSNumber(value: km)) ?? "\(km)"

        return String(format: "branch_distance_km".localized, text)
    }
}
