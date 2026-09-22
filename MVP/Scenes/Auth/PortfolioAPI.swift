//
//  PortfolioAPI.swift
//  MSA
//
//  المحفظة والبروفايل — نفس عقد الـ API المستخدم في الأندرويد.
//

import Foundation

// MARK: - النماذج

enum PortfolioMetal: String, CaseIterable, Identifiable {
    case gold, silver
    var id: String { rawValue }

    /// العيارات المتاحة لكل معدن — الفضة بمقياس الألف مش بالعيار
    var karats: [String] {
        self == .gold ? ["24", "22", "21", "18", "14"] : ["999", "925", "800"]
    }

    var titleKey: String { self == .gold ? "gold" : "silver" }

    /// مقياس النقاء: الذهب على 24 والفضة على الألف
    var purityScale: Double { self == .gold ? 24 : 1000 }

    var nisab: Double { self == .gold ? 85 : 595 }
}

enum PortfolioItemType: String, CaseIterable, Identifiable {
    case bullion, coin, jewellery, scrap
    var id: String { rawValue }

    var titleKey: String { "wallet_type_\(rawValue)" }
}

struct PortfolioItem: Decodable, Identifiable {
    let id: Int
    let metal: String
    let karat: String
    let item_type: String
    let purchase_date: String?
    let weight: Double
    let gram_price: Double
    let manufacturing_per_gram: Double
    let cashback_per_gram: Double
    let total_paid: Double
    let note: String?
    let image_url: String?
    let current_value: Double
    let shop_sell_value: Double
    let profit: Double

    var metalKind: PortfolioMetal { PortfolioMetal(rawValue: metal) ?? .gold }
    var type: PortfolioItemType { PortfolioItemType(rawValue: item_type) ?? .bullion }
    var isProfit: Bool { profit >= 0 }
    var profitPercent: Double { total_paid > 0 ? profit / total_paid * 100 : 0 }
}

struct MetalBreakdown: Decodable {
    let metal: String
    let current_value: Double
    let total_paid: Double
    let total_weight: Double
    let items_count: Int
    let profit: Double
    let profit_percent: Double
    let avg_buy_price: Double
}

struct PortfolioSummary: Decodable {
    let current_value: Double
    let total_paid: Double
    let total_weight: Double
    let cashback_total: Double
    let shop_sell_value: Double
    let profit: Double
    let profit_percent: Double
    let items_count: Int
    let by_metal: [MetalBreakdown]

    static let empty = PortfolioSummary(
        current_value: 0, total_paid: 0, total_weight: 0, cashback_total: 0,
        shop_sell_value: 0, profit: 0, profit_percent: 0, items_count: 0, by_metal: [])

    var isProfit: Bool { profit >= 0 }

    func forMetal(_ metal: PortfolioMetal) -> MetalBreakdown? {
        by_metal.first { $0.metal == metal.rawValue }
    }
}

private struct PortfolioPayload: Decodable {
    let summary: PortfolioSummary
    let items: [PortfolioItem]
}

private struct Envelope<T: Decodable>: Decodable {
    let data: T
}

/// بيانات القطعة وقت الإضافة أو التعديل
struct PortfolioDraft {
    var metal: PortfolioMetal = .gold
    var karat: String = "24"
    var type: PortfolioItemType = .bullion
    var weight: String = ""
    var gramPrice: String = ""
    var manufacturing: String = ""
    var cashback: String = ""
    var totalPaid: String = ""
    var note: String = ""
}

// MARK: - العميل

enum PortfolioAPI {

    private static func authorized(_ path: String, method: String,
                                   body: Data? = nil,
                                   contentType: String? = nil) throws -> URLRequest {
        guard let url = URL(string: hostName + path),
              let token = AuthSession.shared.token else { throw AuthAPIError.network }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 25
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(L102Language.currentAppleLanguage(), forHTTPHeaderField: "Accept-Language")
        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = body
        return request
    }

    private static func send<T: Decodable>(_ request: URLRequest, as: T.Type) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AuthAPIError.network
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let body = try? JSONDecoder().decode(APIErrorBody.self, from: data)
            throw AuthAPIError.server(
                message: body?.firstMessage ?? defaultMessage(status),
                code: body?.error, cooldown: nil)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AuthAPIError.server(message: "رد غير متوقع من السيرفر", code: nil, cooldown: nil)
        }
    }

    private static func defaultMessage(_ status: Int) -> String {
        switch status {
        case 401: return "لازم تسجّل الدخول"
        case 403: return "مش من حقك تعدّل القطعة دي"
        case 500...599: return "في مشكلة في السيرفر، جرّب كمان شوية"
        default: return "حصل خطأ غير متوقع"
        }
    }

    /// الأسعار الحالية بتتبعت مع الطلب لأنها جاية من Firestore
    /// لحظة بلحظة والسيرفر مش مشترك فيها.
    static func load(gold21: Double, silver999: Double)
    async throws -> (summary: PortfolioSummary, items: [PortfolioItem]) {
        let path = "portfolio?gold21=\(gold21)&silver999=\(silver999)"
        let payload = try await send(authorized(path, method: "GET"), as: Envelope<PortfolioPayload>.self)
        return (payload.data.summary, payload.data.items)
    }

    /// الإضافة والتعديل الاتنين POST — PHP مبيفكّش multipart في PUT.
    static func save(_ draft: PortfolioDraft, existingId: Int?) async throws {
        var fields: [String: String] = [
            "metal": draft.metal.rawValue,
            "karat": draft.karat,
            "item_type": draft.type.rawValue,
            "weight": draft.weight,
            "gram_price": draft.gramPrice,
            "manufacturing_per_gram": draft.manufacturing.isEmpty ? "0" : draft.manufacturing,
            "cashback_per_gram": draft.cashback.isEmpty ? "0" : draft.cashback,
        ]
        // الحقول الاختيارية بتتبعت بس لو ليها قيمة — إرسالها فاضية
        // بيخلّي تحقق لارافيل يرفضها.
        if !draft.totalPaid.isEmpty { fields["total_paid"] = draft.totalPaid }
        if !draft.note.isEmpty { fields["note"] = draft.note }

        let body = fields
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")" }
            .joined(separator: "&")

        let path = existingId == nil ? "portfolio" : "portfolio/\(existingId!)"
        let request = try authorized(path, method: "POST",
                                     body: body.data(using: .utf8),
                                     contentType: "application/x-www-form-urlencoded")
        _ = try await send(request, as: Envelope<PortfolioItem>.self)
    }

    static func delete(id: Int) async throws {
        _ = try await send(authorized("portfolio/\(id)", method: "DELETE"), as: SimpleMessage.self)
    }

    // MARK: البروفايل

    static func profile() async throws -> AuthUser {
        try await send(authorized("profile", method: "GET"), as: Envelope<AuthUser>.self).data
    }

    static func updateProfile(name: String, email: String) async throws -> AuthUser {
        let body = try JSONSerialization.data(withJSONObject: ["name": name, "email": email])
        let request = try authorized("profile", method: "PUT", body: body,
                                     contentType: "application/json")
        return try await send(request, as: Envelope<AuthUser>.self).data
    }

    static func changePassword(current: String, new: String, confirm: String) async throws {
        let body = try JSONSerialization.data(withJSONObject: [
            "current_password": current,
            "password": new,
            "password_confirmation": confirm,
        ])
        let request = try authorized("profile/password", method: "PUT", body: body,
                                     contentType: "application/json")
        _ = try await send(request, as: SimpleMessage.self)
    }
}
