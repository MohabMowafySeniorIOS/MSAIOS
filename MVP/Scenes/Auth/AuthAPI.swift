//
//  AuthAPI.swift
//  MSA
//
//  عميل الـ API الخاص بالحساب — URLSession مباشرة بدل ApiServices القديمة،
//  لأن مساراتها من قالب مشروع تاني (client/auth/…) ومش مطابقة للباك اند.
//

import Foundation

/// أخطاء الـ API بالشكل اللي لارافيل بيرجّعه.
struct APIErrorBody: Decodable {
    let message: String?
    let error: String?
    let errors: [String: [String]]?
    let cooldown: Int?

    /// أول رسالة مفيدة نعرضها للمستخدم
    var firstMessage: String? {
        errors?.values.first?.first ?? message
    }
}

enum AuthAPIError: Error {
    case server(message: String, code: String?, cooldown: Int?)
    case network

    var displayMessage: String {
        switch self {
        case .server(let message, _, _): return message
        case .network: return "تأكد من اتصالك بالإنترنت وجرّب تاني"
        }
    }

    var serverCode: String? {
        if case .server(_, let code, _) = self { return code }
        return nil
    }
}

// MARK: - النماذج

struct AuthUser: Decodable {
    let id: Int
    let name: String
    let email: String?
    let phone: String
    let phone_verified: Bool?
}

struct AuthTokenResponse: Decodable {
    let token: String
    let user: AuthUser
}

struct RegisterResponse: Decodable {
    let message: String?
    let phone: String?
    let otp_expires_in: Int?
}

struct SimpleMessage: Decodable {
    let message: String?
}

// MARK: - العميل

enum AuthAPI {

    /// نفس الـ base URL المستخدم في باقي التطبيق
    private static var base: String { hostName }

    private static func request(
        _ path: String,
        method: String,
        body: [String: Any]? = nil,
        token: String? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: base + path) else { throw AuthAPIError.network }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 25
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(L102Language.currentAppleLanguage(), forHTTPHeaderField: "Accept-Language")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
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
                message: body?.firstMessage ?? defaultMessage(for: status),
                code: body?.error,
                cooldown: body?.cooldown
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AuthAPIError.server(message: "رد غير متوقع من السيرفر", code: nil, cooldown: nil)
        }
    }

    private static func defaultMessage(for status: Int) -> String {
        switch status {
        case 401: return "لازم تسجّل الدخول"
        case 403: return "الحساب موقوف. تواصل مع الدعم."
        case 404: return "الرقم ده مش مسجّل"
        case 429: return "حاولت كتير، استنى شوية وجرّب تاني"
        case 500...599: return "في مشكلة في السيرفر، جرّب كمان شوية"
        default: return "حصل خطأ غير متوقع"
        }
    }

    /// توحيد صيغة الموبايل — نفس منطق الباك اند والأندرويد.
    static func normalizePhone(_ raw: String) -> String {
        var digits = raw.filter(\.isNumber)
        if digits.hasPrefix("00") { digits = String(digits.dropFirst(2)) }
        if digits.hasPrefix("20") { digits = "0" + digits.dropFirst(2) }
        if digits.count == 10, digits.hasPrefix("1") { digits = "0" + digits }
        return digits
    }

    // MARK: العمليات

    /// بيعمل الحساب ويبعت الكود — التوكن مبيرجعش هنا.
    static func register(
        name: String, email: String, phone: String,
        password: String, confirm: String, fcmToken: String?
    ) async throws -> RegisterResponse {
        var body: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "phone": normalizePhone(phone),
            "password": password,
            "password_confirmation": confirm,
            "device_platform": "ios",
            /*
             * `ar` أو `en` بس. السيرفر بيقبل الاتنين دول، والتطبيق فيه
             * أوردو كمان — فاللغة الخام كانت هترجّع 422 وتوقّف التسجيل
             * نفسه. ونفس التطبيع في `updateDeviceToken` تحت، عشان
             * المسارين ما يكتبوش قيمتين مختلفتين لنفس المستخدم.
             */
            "locale": L102Language.currentAppleLanguage() == "en" ? "en" : "ar",
        ]
        if let fcmToken { body["fcm_token"] = fcmToken }
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            body["app_version"] = version
        }
        return try await send(request("register", method: "POST", body: body), as: RegisterResponse.self)
    }

    /// تأكيد الكود — هنا بس بيرجع التوكن.
    static func verifyOtp(phone: String, code: String) async throws -> AuthTokenResponse {
        let body: [String: Any] = ["phone": normalizePhone(phone), "code": code]
        return try await send(request("verify-otp", method: "POST", body: body), as: AuthTokenResponse.self)
    }

    static func resendOtp(phone: String) async throws -> SimpleMessage {
        let body: [String: Any] = ["phone": normalizePhone(phone)]
        return try await send(request("resend-otp", method: "POST", body: body), as: SimpleMessage.self)
    }

    static func login(phone: String, password: String, fcmToken: String?) async throws -> AuthTokenResponse {
        var body: [String: Any] = [
            "phone": normalizePhone(phone),
            "password": password,
            "device_platform": "ios",
        ]
        if let fcmToken { body["fcm_token"] = fcmToken }
        return try await send(request("login", method: "POST", body: body), as: AuthTokenResponse.self)
    }

    /// تحديث توكن الجهاز واللغة — شوف `DeviceTokenSync`.
    ///
    /// مش بيرمي: بيتنادى في خلفية حاجات تانية (فتح التطبيق · تغيير
    /// اللغة · تجديد توكن FCM) وما ينفعش يوقّف أي واحدة منهم. نفس
    /// أسلوب `logout` فوق بالظبط.
    static func updateDeviceToken(fcmToken: String, locale: String, token: String) async {
        var body: [String: Any] = [
            "fcm_token": fcmToken,
            "device_platform": "ios",
            // السيرفر بيقبل ar/en بس، وأي لغة تالتة بترجع للعربي
            "locale": locale == "en" ? "en" : "ar",
        ]
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            body["app_version"] = version
        }

        guard let req = try? request("device-token", method: "POST", body: body, token: token) else { return }
        _ = try? await URLSession.shared.data(for: req)
    }

    static func logout(token: String) async {
        guard let req = try? request("logout", method: "POST", token: token) else { return }
        _ = try? await URLSession.shared.data(for: req)
    }

    static func deleteAccount(token: String) async throws -> SimpleMessage {
        try await send(request("account", method: "DELETE", token: token), as: SimpleMessage.self)
    }
}
