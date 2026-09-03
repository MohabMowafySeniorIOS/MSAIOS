//
//  BannerModel.swift
//  MSA
//
//  موديل بانرات الرئيسية — متظبط على الـ response الحقيقي من
//  https://api.msagold.com/api/v1/banners
//
//  {
//    "meta": { "current_page": 1, "per_page": 15, "total": 1, ... },
//    "data": [{
//      "id": 4,
//      "name": "MSA ",
//      "media_type": "image",
//      "media_url":  "https://api.msagold.com/storage/14/01M18....jpeg",
//      "thumb_url":  "https://api.msagold.com/storage/14/conversions/...-thumb.jpg",
//      "order": 0,
//      "starts_at": null, "ends_at": null,
//      "created_at": "2026-08-29T14:30:46.000000Z",
//      "updated_at": "2026-08-29T14:30:46.000000Z",
//      "link":   { "type": "none",   "url": null },
//      "status": { "value": "active", "label": { "ar": "نشط", "en": "Active" } }
//    }],
//    "links": { "first": "...", "last": "...", "next": null, "prev": null }
//  }
//
//  ملحوظتين مهمتين عن النسخة دي:
//
//  ١. كل حاجة بتتفك بـ decodeIfPresent. النسخة القديمة كانت بتعرّف
//     الحقول non-optional، فأي حقل ناقص من الباك اند كان بيرمي error
//     ويضيّع الـ response كله. دلوقتي البانر الوحيد اللي بيتشال هو اللي
//     مالوش `id` أو `media_url` — يعني مفيش حاجة نعرضها أصلاً.
//
//  ٢. بانر واحد باظ مبيوقعش الباقي (FailableDecodable).
//

import Foundation

// MARK: - Banners Response

struct BannersResponse: Codable {

    let data: [Banner]
    let meta: BannerMeta?
    let links: BannerPageLinks?

    enum CodingKeys: String, CodingKey {
        case data, meta, links
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // بانر واحد بصيغة غلط ما يضيّعش باقي البانرات.
        let raw = try container.decodeIfPresent(
            [FailableDecodable<Banner>].self, forKey: .data
        ) ?? []

        self.data = raw.compactMap { $0.value }
        self.meta = try? container.decodeIfPresent(BannerMeta.self, forKey: .meta)
        self.links = try? container.decodeIfPresent(BannerPageLinks.self, forKey: .links)
    }
}

/// الـ pagination.
///
/// الافتراضي `per_page = 15`، وإحنا بنطلب ٥٠ من الـ API عشان كل
/// البانرات تيجي في ريكوست واحد (شوف `BannerService`). لو عدد البانرات
/// عدّى ده فعلاً هتحتاج تلف على `links.next`.
///
/// اسمها `BannerMeta` مش `Meta` عشان ما تتضاربش مع الـ `Meta` الموجودة
/// أصلاً في `NewsModel.swift`.
struct BannerMeta: Codable {
    let currentPage: Int?
    let lastPage: Int?
    let perPage: Int?
    let total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}

struct BannerPageLinks: Codable {
    let first: String?
    let last: String?
    let next: String?
    let prev: String?
}

// MARK: - Banner

struct Banner: Codable, Identifiable, Equatable {

    let id: Int
    let name: String
    let mediaType: MediaType
    let mediaURL: String
    let thumbURL: String?
    let order: Int

    /// `nil` لو `link.type == "none"` أو الـ url فاضي.
    let linkURL: String?

    /// "active" / "inactive" / `nil` لو الباك اند مبعتش status.
    let statusValue: String?

    let startsAt: Date?
    let endsAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, order, link, status
        case mediaType = "media_type"
        case mediaURL = "media_url"
        case thumbURL = "thumb_url"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
    }

    // MARK: Decoding

    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        // الحاجتين الوحيدتين اللي من غيرهم البانر مالوش لازمة.
        guard let id = try c.decodeIfPresent(Int.self, forKey: .id) else {
            throw BannerDecodingError.missingID
        }

        let media = try c.decodeIfPresent(String.self, forKey: .mediaURL)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let mediaURL = media, !mediaURL.isEmpty else {
            throw BannerDecodingError.missingMediaURL
        }

        self.id = id
        self.mediaURL = mediaURL

        // الاسم جاي من الداشبورد وساعات فيه مسافات زايدة ("MSA ").
        self.name = (try c.decodeIfPresent(String.self, forKey: .name) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        self.mediaType = (try? c.decode(MediaType.self, forKey: .mediaType)) ?? .image

        let thumb = try c.decodeIfPresent(String.self, forKey: .thumbURL)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.thumbURL = (thumb?.isEmpty == false) ? thumb : nil

        self.order = try c.decodeIfPresent(Int.self, forKey: .order) ?? 0

        // الباك اند بيبعت type = "none" لما مفيش لينك — بنعاملها كأنها nil
        // عشان زرار "اعرف أكثر" ما يظهرش على الفاضي.
        let link = try c.decodeIfPresent(BannerLink.self, forKey: .link)
        if let link, link.type?.lowercased() != "none",
           let url = link.url?.trimmingCharacters(in: .whitespacesAndNewlines),
           !url.isEmpty {
            self.linkURL = url
        } else {
            self.linkURL = nil
        }

        let status = try c.decodeIfPresent(BannerStatus.self, forKey: .status)
        self.statusValue = status?.value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        self.startsAt = BannerDate.parse(try c.decodeIfPresent(String.self, forKey: .startsAt))
        self.endsAt = BannerDate.parse(try c.decodeIfPresent(String.self, forKey: .endsAt))
    }

    // MARK: Encoding
    //
    // مش مستخدم دلوقتي (مفيش كاش)، بس سايبينه عشان `Banner` تفضل
    // `Codable` كاملة — لو احتجت تحفظها في أي وقت هتشتغل من غير شغل زيادة.

    func encode(to encoder: Encoder) throws {

        var c = encoder.container(keyedBy: CodingKeys.self)

        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(mediaType, forKey: .mediaType)
        try c.encode(mediaURL, forKey: .mediaURL)
        try c.encodeIfPresent(thumbURL, forKey: .thumbURL)
        try c.encode(order, forKey: .order)

        // بنرجّع نفس شكل الـ API عشان اللي يتكتب يتفك بنفس الـ decoder.
        try c.encode(BannerLink(type: linkURL == nil ? "none" : "url", url: linkURL),
                     forKey: .link)
        try c.encode(BannerStatus(value: statusValue, label: nil), forKey: .status)

        try c.encodeIfPresent(BannerDate.string(from: startsAt), forKey: .startsAt)
        try c.encodeIfPresent(BannerDate.string(from: endsAt), forKey: .endsAt)
    }

    // MARK: - الحالة

    /// البانر شغّال دلوقتي؟ (الحالة active والوقت جوه الفترة بتاعته)
    ///
    /// أي حقل ناقص = مبنفلترش بيه، عشان بانر بحقول ناقصة ما يختفيش بالغلط.
    func isActive(at now: Date = Date()) -> Bool {

        let statusOK = statusValue == nil || statusValue == "active"
        let startedOK = startsAt.map { $0 <= now } ?? true
        let notEndedOK = endsAt.map { $0 >= now } ?? true

        return statusOK && startedOK && notEndedOK
    }
}

enum BannerDecodingError: Error {
    case missingID
    case missingMediaURL
}

// MARK: - Media Type

enum MediaType: String, Codable {

    case image
    case video

    /// أي نوع مش معروف بيتعامل كصورة بدل ما يرمي error.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = MediaType(rawValue: raw.lowercased()) ?? .image
    }
}

// MARK: - Link / Status

struct BannerLink: Codable {
    /// "none" لما البانر مالوش لينك، أو "url" لما يكون عنده.
    let type: String?
    let url: String?
}

struct BannerStatus: Codable {
    let value: String?
    let label: StatusLabel?
}

struct StatusLabel: Codable {
    let ar: String?
    let en: String?
}

// MARK: - Pagination link (شكل عنصر في meta.links)

struct MetaLink: Codable {
    let active: Bool?
    let label: String?
    let page: Int?
    let url: String?
}

// MARK: - فلترة

extension Array where Element == Banner {

    /// البانرات الشغّالة دلوقتي، مرتّبة بالـ order اللي جاي من الداشبورد.
    func activeNow(at now: Date = Date()) -> [Banner] {
        filter { $0.isActive(at: now) }.sorted { $0.order < $1.order }
    }
}

// MARK: - التواريخ

/// التواريخ جاية بصيغة ISO-8601 بالميكروثانية و UTC:
/// `2026-08-29T14:30:46.000000Z`
///
/// `ISO8601DateFormatter` مبيفهمش ٦ خانات كسور، فبنقصها الأول.
enum BannerDate {

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    static func parse(_ raw: String?) -> Date? {

        guard let raw else { return nil }

        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.lowercased() != "null" else { return nil }

        var cleaned = value

        // نشيل .000000
        if let dot = cleaned.firstIndex(of: ".") {
            cleaned = String(cleaned[cleaned.startIndex..<dot])
        }

        cleaned = cleaned.replacingOccurrences(of: "Z", with: "")
        // لو الباك اند بعت "yyyy-MM-dd HH:mm:ss"
        cleaned = cleaned.replacingOccurrences(of: " ", with: "T")

        // تاريخ بصيغة غريبة = "من غير تاريخ" بدل ما نخفي البانر.
        return formatter.date(from: cleaned)
    }

    static func string(from date: Date?) -> String? {
        guard let date else { return nil }
        return formatter.string(from: date) + "Z"
    }
}

// MARK: - Failable decoding

/// بيخلّي عنصر واحد باظ في الـ array ما يوقّعش الـ array كلها.
struct FailableDecodable<T: Decodable>: Decodable {

    let value: T?

    init(from decoder: Decoder) throws {
        value = try? T(from: decoder)
    }
}
