//
//  ShopAPI.swift
//  MSA
//
//  المتجر — سبائك ومشغولات، السلة، والطلبات.
//
//  ## السعر مصدره السيرفر
//
//  `PortfolioAPI` بيبعت `gold21` و`silver999` مع الطلب لأن المحفظة
//  **عرض بس** — مفيش فلوس بتتحرك. هنا العكس تماماً: مفيش أي مسار
//  بيبعت سعر. السيرفر بيقرا نفس مستندات Firestore اللي الرئيسية
//  بتقرا منها، بيحسب، وبيرجّع الرقم جاهز.
//
//  ده مش تنظيم: تطبيق معدّل بيبعت «سعر الجرام = ١ جنيه» ويطلب ١٠٠
//  جرام بعربون ٢٠ جنيه هو أسهل طريقة لسرقة المحل.
//

import Foundation

// MARK: - النصوص باللغتين

/// `{ "ar": "...", "en": "..." }` — نفس شكل `/news` و`/branches`
struct APILocalizedText: Decodable {
    let ar: String?
    let en: String?

    /// بيختار حسب لغة التطبيق وبيقع على التانية لو الأولى فاضية،
    /// فتبديل اللغة مبيحتاجش طلب شبكة جديد
    var value: String {
        let arabic = L102Language.currentAppleLanguage() == "ar"
        let primary = arabic ? ar : en
        let fallback = arabic ? en : ar

        if let primary, !primary.isEmpty { return primary }

        return fallback ?? ""
    }
}

/// `{ "value": "bullion", "label": { "ar": "سبائك", "en": "Bullion" } }`
struct APILabeledValue: Decodable {
    let value: String?
    let label: APILocalizedText?

    var text: String { label?.value ?? value ?? "" }
}

// MARK: - المنتج

struct APIProduct: Decodable, Identifiable {
    let id: Int

    let name: APILocalizedText?
    let description: APILocalizedText?

    let media_url: String?
    let thumb_url: String?

    let kind: APILabeledValue?
    let metal: String
    let karat: Int

    let weight_grams: Double
    let manufacturing: APIManufacturing?
    let tax_percent: Double

    /// `null` = مخزون مفتوح. الشاشة بتخفي عدّاد الكمية في الحالة دي
    let stock: Int?
    let in_stock: Bool

    let allow_deposit: Bool
    let allow_on_arrival: Bool

    let price: APIProductPrice?

    var title: String { name?.value ?? "" }
    var details: String? {
        let text = description?.value ?? ""
        return text.isEmpty ? nil : text
    }

    var isGold: Bool { metal != "silver" }

    /// الصورة المصغّرة، وبنقع على الكاملة لو ناقصة — الكارت من غير
    /// صورة بيبان مكسور
    var listImage: String? { thumb_url ?? media_url }

    /// فيه سعر جاهز للعرض؟ غير كده الشاشة بتعرض «جاري تحميل السعر»
    var hasPrice: Bool { price?.priced == true }

    var manufacturingPerGram: Double { manufacturing?.per_gram ?? 0 }
}

struct APIManufacturing: Decodable {
    let mode: String
    let value: Double
    let per_gram: Double
}

struct APIProductPrice: Decodable {
    let gram_price: Double
    let metal_value: Double
    let manufacturing_total: Double
    let tax_amount: Double
    let total: Double
    let currency: String

    /**
     `false` معناه السعر لسه ما وصلش من Firestore.

     الشاشة بتعرض «جاري تحميل السعر» مش صفر جنيه — نفس اللي الرئيسية
     بتعمله لما المستند يبقى فاضي. عرض صفر معناه العميل هيفتكر إن
     المنتج ببلاش.
     */
    let priced: Bool
}

/// أسعار الجرام الحالية زي ما السيرفر قراها
struct APIShopPrices: Decodable {
    let gold_gram_21: Double
    let silver_gram_999: Double
    let fetched_at: String?

    /// السعر من آخر نسخة محفوظة — Firestore مش راد دلوقتي
    let is_stale: Bool
}

/// إعدادات المتجر من اللوحة — بتتغيّر من غير تحديث للتطبيق
struct APIShopInfo: Decodable {
    let is_enabled: Bool
    let deposit_percent: Double
    let min_deposit: Double
    let lock_hours: Int
    let max_items_per_order: Int
    let terms: APILocalizedText?
    let deposit_instructions: APILocalizedText?
    let prices: APIShopPrices?
}

// MARK: - السلة

struct APICart: Decodable {
    let items: [APICartItem]
    let count: Int
    let totals: APICartTotals?
    let prices: APIShopPrices?

    var isEmpty: Bool { items.isEmpty }
}

struct APICartItem: Decodable, Identifiable {
    let id: Int
    let quantity: Int
    let product: APIProduct?
    let line_total: Double
}

struct APICartTotals: Decodable {
    let metal_total: Double
    let manufacturing_total: Double
    let tax_total: Double
    let total: Double
    let deposit_amount: Double
    let priced: Bool
}

// MARK: - الطلب

struct APIOrder: Decodable, Identifiable {
    let id: Int
    let code: String

    let pricing_mode: APILabeledValue?
    let status: APILabeledValue?
    let deposit: APIOrderDeposit?

    let base_prices: APIOrderBasePrices?
    let totals: APIOrderTotals?

    let price_locked_until: String?
    let price_lock_expired: Bool

    let branch: APIBranch?

    /**
     اختيارية عن قصد.

     `whenLoaded` في لارافيل بيشيل المفتاح خالص لو العلاقة مش
     متحمّلة. الحقل غير الاختياري في Swift كان هيرمي خطأ فك ترميز
     ساعتها، والشاشة كانت هتفضل فاضية من غير أي سبب واضح — وده أسوأ
     من سطر ناقص. استخدم [lines] في العرض.
     */
    let items: [APIOrderItem]?

    let customer_name: String?
    let customer_phone: String?
    let note: String?

    let can_cancel: Bool
    let created_at: String?

    var isDeposit: Bool { pricing_mode?.value == "deposit" }

    /// الإجمالي تقديري — طلبات «التسعير عند الاستلام»
    var isEstimate: Bool { totals?.is_estimate ?? false }

    var total: Double { totals?.total ?? 0 }

    var lines: [APIOrderItem] { items ?? [] }

    /**
     التاريخ من `2026-09-14T12:04:28.000000Z` لـ `2026-09-14`.

     بنقص عند `T` بدل ما نحلّل التاريخ كامل: العرض محتاج اليوم بس،
     والتحليل الكامل بيجيب مشاكل المنطقة الزمنية من غير فايدة.
     الصيغة ثابتة من لارافيل.
     */
    var shortDate: String {
        guard let created_at, let t = created_at.firstIndex(of: "T") else { return "" }

        return String(created_at[created_at.startIndex..<t])
    }
}

struct APIOrderDeposit: Decodable {
    let status: String
    let label: APILocalizedText?
    let amount: Double
    let method: String?
    let paid_at: String?

    var exists: Bool { status != "none" }
    var isPaid: Bool { status == "paid" }
    var text: String { label?.value ?? status }
}

struct APIOrderBasePrices: Decodable {
    let gold: Double
    let silver: Double
    let fetched_at: String?
}

struct APIOrderTotals: Decodable {
    let metal_total: Double
    let manufacturing_total: Double
    let tax_total: Double
    let total: Double
    let currency: String
    let is_estimate: Bool
}

struct APIOrderItem: Decodable, Identifiable {
    let id: Int
    let product_id: Int?
    let name: APILocalizedText?
    let kind: String
    let metal: String
    let karat: Int
    let weight_grams: Double
    let quantity: Int
    let gram_price: Double
    let manufacturing_per_gram: Double
    let metal_value: Double
    let manufacturing_total: Double
    let tax_amount: Double
    let line_total: Double

    var title: String { name?.value ?? "" }
}

// MARK: - الأغلفة

private struct ShopEnvelope<T: Decodable>: Decodable { let data: T }

private struct ProductsEnvelope: Decodable {
    let data: [APIProduct]
    let prices: APIShopPrices?
}

private struct ProductEnvelope: Decodable {
    let data: APIProduct
    let prices: APIShopPrices?
}

private struct CartEnvelope: Decodable {
    /// بيرجع بس مع العمليات اللي بتعدّل — `GET /cart` مش بيرجّعه
    let message: String?
    let data: APICart
}

private struct OrderEnvelope: Decodable {
    let message: String?
    let data: APIOrder
}

// MARK: - الأخطاء

/**
 خطأ من المتجر.

 نوع خاص بدل ما نضيف حالة لـ`AuthAPIError`: الـ enum ده فيه
 `switch` شامل جوّه `displayMessage`، فأي حالة جديدة كانت هتكسّر
 الملف القايم. وبرضه المتجر محتاج يميّز **401** عن باقي الأخطاء —
 الشاشة بتودّي المستخدم لتسجيل الدخول بدل ما تعرض رسالة.
 */
enum ShopAPIError: Error {
    case unauthorized
    case server(String)
    case network

    var displayMessage: String {
        switch self {
        case .unauthorized: return "لازم تسجّل الدخول الأول"
        case .server(let message): return message
        case .network: return "تأكد من اتصالك بالإنترنت وجرّب تاني"
        }
    }

    var isUnauthorized: Bool {
        if case .unauthorized = self { return true }
        return false
    }
}

// MARK: - العميل

enum ShopAPI {

    // المنتجات مفتوحة من غير توكن — العميل بيتصفّح ويشوف الأسعار قبل
    // ما يسجّل. السلة والطلبات محتاجة توكن.

    private static func open(_ path: String) throws -> URLRequest {
        guard let url = URL(string: hostName + path) else { throw ShopAPIError.network }

        var request = URLRequest(url: url)
        request.timeoutInterval = 25
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(L102Language.currentAppleLanguage(), forHTTPHeaderField: "Accept-Language")

        return request
    }

    private static func authorized(_ path: String, method: String,
                                   body: [String: Any]? = nil) throws -> URLRequest {
        guard let token = AuthSession.shared.token else { throw ShopAPIError.unauthorized }
        guard let url = URL(string: hostName + path) else { throw ShopAPIError.network }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 25
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(L102Language.currentAppleLanguage(), forHTTPHeaderField: "Accept-Language")

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    /**
     بيبعت وبيفك، وبيطلّع **رسالة السيرفر** لو فشل.

     لارافيل بيرفض بـ422 ورسالة مفهومة بالعربي («السعر مش محدّث دلوقتي
     فمش ممكن نثبّته»، «المنتج ده خلص من المخزون»). لو حوّلناها لـ«حصل
     خطأ» المستخدم مش هيعرف يعمل إيه.
     */
    private static func send<T: Decodable>(_ request: URLRequest, as: T.Type) async throws -> T {
        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await APIActivityOverlay.shared.withLoading {
                try await URLSession.shared.data(for: request)
            }
        } catch {
            throw ShopAPIError.network
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        guard (200..<300).contains(status) else {
            // 401 لازم يفضل مميّز عن باقي الأخطاء — الشاشة بتودّي
            // المستخدم لتسجيل الدخول مش بتعرض رسالة
            if status == 401 { throw ShopAPIError.unauthorized }

            let body = try? JSONDecoder().decode(APIErrorBody.self, from: data)

            throw ShopAPIError.server(body?.firstMessage ?? "حصل خطأ، جرّب تاني")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ShopAPIError.server("رد غير متوقع من السيرفر")
        }
    }

    // MARK: المنتجات

    static func products(kind: String? = nil) async throws -> ([APIProduct], APIShopPrices?) {
        var path = "products?per_page=50"
        if let kind { path += "&kind=\(kind)" }

        let payload = try await send(open(path), as: ProductsEnvelope.self)

        return (payload.data, payload.prices)
    }

    static func product(id: Int) async throws -> APIProduct {
        try await send(open("products/\(id)"), as: ProductEnvelope.self).data
    }

    static func shopInfo() async throws -> APIShopInfo {
        try await send(open("products/shop"), as: ShopEnvelope<APIShopInfo>.self).data
    }

    // MARK: السلة

    static func cart() async throws -> APICart {
        try await send(authorized("cart", method: "GET"), as: CartEnvelope.self).data
    }

    static func addToCart(productId: Int, quantity: Int = 1) async throws -> APICart {
        try await send(
            authorized("cart", method: "POST",
                       body: ["product_id": productId, "quantity": quantity]),
            as: CartEnvelope.self
        ).data
    }

    /// الكمية صفر بتحذف الصف — مش خطأ
    static func setQuantity(productId: Int, quantity: Int) async throws -> APICart {
        try await send(
            authorized("cart", method: "PUT",
                       body: ["product_id": productId, "quantity": quantity]),
            as: CartEnvelope.self
        ).data
    }

    static func removeFromCart(productId: Int) async throws -> APICart {
        try await send(
            authorized("cart/items/\(productId)", method: "DELETE"),
            as: CartEnvelope.self
        ).data
    }

    // MARK: الطلبات

    static func orders() async throws -> [APIOrder] {
        try await send(
            authorized("orders?per_page=30", method: "GET"),
            as: ShopEnvelope<[APIOrder]>.self
        ).data
    }

    static func placeOrder(mode: String, branchId: Int?, note: String?) async throws -> APIOrder {
        var body: [String: Any] = ["pricing_mode": mode]

        if let branchId { body["branch_id"] = branchId }
        if let note, !note.isEmpty { body["note"] = note }

        return try await send(
            authorized("orders", method: "POST", body: body),
            as: OrderEnvelope.self
        ).data
    }

    static func cancelOrder(id: Int) async throws -> APIOrder {
        try await send(
            authorized("orders/\(id)/cancel", method: "POST"),
            as: OrderEnvelope.self
        ).data
    }
}
