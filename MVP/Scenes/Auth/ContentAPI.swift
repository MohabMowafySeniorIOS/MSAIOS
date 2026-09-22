//
//  ContentAPI.swift
//  MSA
//
//  محتوى شاشة «المزيد» والسبائك — من لوحة التحكم بدل Firestore.
//

import Foundation

// MARK: - النماذج

struct APIPage: Decodable {
    let slug: String
    let title_ar: String?
    let title_en: String?
    let body_ar: String?
    let body_en: String?

    var title: String { (isArabic ? title_ar : title_en) ?? "" }
    var body: String { (isArabic ? body_ar : body_en) ?? "" }
}

struct APIFaq: Decodable, Identifiable {
    let id: Int
    let question_ar: String?
    let question_en: String?
    let answer_ar: String?
    let answer_en: String?

    var question: String { (isArabic ? question_ar : question_en) ?? "" }
    var answer: String { (isArabic ? answer_ar : answer_en) ?? "" }
}

struct APIContact: Decodable {
    let phone: String?
    let whatsapp: String?
    let email: String?
    let address_ar: String?
    let address_en: String?
    let working_hours_ar: String?
    let working_hours_en: String?
    let social: [String: String]?

    enum CodingKeys: String, CodingKey {
        case phone, whatsapp, email, address_ar, address_en
        case working_hours_ar, working_hours_en, social
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        whatsapp = try container.decodeIfPresent(String.self, forKey: .whatsapp)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        address_ar = try container.decodeIfPresent(String.self, forKey: .address_ar)
        address_en = try container.decodeIfPresent(String.self, forKey: .address_en)
        working_hours_ar = try container.decodeIfPresent(String.self, forKey: .working_hours_ar)
        working_hours_en = try container.decodeIfPresent(String.self, forKey: .working_hours_en)
        // Firebase/API قد يرجّع [] عند عدم وجود روابط اجتماعية.
        social = try? container.decode([String: String].self, forKey: .social)
    }
    
    var address: String? {
        isArabic ? address_ar : address_en
    }
    
    var workingHours: String? {
        isArabic ? working_hours_ar : working_hours_en
    }
}

struct APIBullionProduct: Decodable, Identifiable {
    let id: Int
    let name_ar: String?
    let name_en: String?
    let weight: Double
    let manufacturing: Double
    let cash_back: Double

    var name: String { (isArabic ? name_ar : name_en) ?? "" }
}

struct APIBullionCompany: Decodable, Identifiable {
    let id: Int
    let name: String
    let image_url: String?
    let products: [APIBullionProduct]
}

struct APIBullionMetal: Decodable, Identifiable {
    let slug: String
    let name_ar: String?
    let name_en: String?
    let companies: [APIBullionCompany]

    var id: String { slug }
    var name: String { (isArabic ? name_ar : name_en) ?? slug }
}

/// اللغة الحالية — الردود بترجع اللغتين والاختيار بيحصل هنا،
/// فتغيير اللغة مبيحتاجش طلب جديد للشبكة.
private var isArabic: Bool { L102Language.currentAppleLanguage() == "ar" }

private struct ContentEnvelope<T: Decodable>: Decodable { let data: T }

private struct ContentBundle: Decodable {
    let pages: [String: APIPage]?
    let faqs: [APIFaq]?
    let contact: APIContact?
}

// MARK: - الكاش

/**
 محتوى المزيد والسبائك.

 السيرفر بيرجّع كل المحتوى في طلب واحد، فبنجيبه مرة ونخزّنه.
 المستخدم بيفتح «من نحن» ثم «الأسئلة» ثم السياسات ورا بعض —
 من غير التخزين كان هيتبعت طلب لكل شاشة.
 */
@MainActor
final class ContentStore: ObservableObject {

    static let shared = ContentStore()
    private init() {}

    @Published private(set) var pages: [String: APIPage] = [:]
    @Published private(set) var faqs: [APIFaq] = []
    @Published private(set) var contact: APIContact?
    @Published private(set) var bullions: [APIBullionMetal] = []

    private var contentLoaded = false
    private var bullionsLoaded = false

    func page(_ slug: String) -> APIPage? { pages[slug] }

    /// تحميل صفحة واحدة من الـ API بدون الاعتماد على حزمة المحتوى العامة.
    func loadPage(_ slug: String) async -> APIPage? {
        guard let url = URL(string: hostName + "pages/\(slug)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder()
                .decode(ContentEnvelope<APIPage>.self, from: data).data
        } catch {
            print("ContentStore: تعذّر تحميل الصفحة \(slug) — \(error.localizedDescription)")
            return nil
        }
    }

    func loadContent(force: Bool = false) async {
        if contentLoaded && !force { return }
        guard let url = URL(string: hostName + "content") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let bundle = try JSONDecoder().decode(ContentEnvelope<ContentBundle>.self, from: data).data
            pages = bundle.pages ?? [:]
            faqs = bundle.faqs ?? []
            contact = bundle.contact
            contentLoaded = true
        } catch {
            print("ContentStore: تعذّر تحميل المحتوى — \(error.localizedDescription)")
        }
    }

    /// تحميل الأسئلة وحدها حتى لا يمنع اختلاف أي جزء آخر من المحتوى ظهورها.
    func loadFaqs(force: Bool = false) async {
        if !force && !faqs.isEmpty { return }
        guard let url = URL(string: hostName + "faqs") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            faqs = try JSONDecoder()
                .decode(ContentEnvelope<[APIFaq]>.self, from: data).data
        } catch {
            print("ContentStore: تعذّر تحميل الأسئلة — \(error.localizedDescription)")
        }
    }

    func loadBullions(force: Bool = false) async {
        if bullionsLoaded && !force { return }
        guard let url = URL(string: hostName + "bullions") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            bullions = try JSONDecoder()
                .decode(ContentEnvelope<[APIBullionMetal]>.self, from: data).data
            bullionsLoaded = true
        } catch {
            print("ContentStore: تعذّر تحميل السبائك — \(error.localizedDescription)")
        }
    }
}

/// معرّفات الصفحات على السيرفر
enum PageSlug {
    static let about   = "about_us"
    static let usage   = "usage_policy"
    static let refund  = "refund_policy"
    static let privacy = "privacy_policy"
}
