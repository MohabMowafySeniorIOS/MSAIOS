//
//  AuthSession.swift
//  MSA
//
//  حالة الدخول والتوكن.
//
//  التوكن متخزّن في الـ Keychain مش UserDefaults — UserDefaults بيتاخد
//  في نسخ iTunes الاحتياطية وبيتقرا من أي أداة على جهاز مكسور الحماية.
//

import Foundation
import Security

final class AuthSession: ObservableObject {

    static let shared = AuthSession()

    @Published private(set) var isLoggedIn = false
    @Published private(set) var userName: String?
    @Published private(set) var userPhone: String?

    private let service = "com.msa.ios.auth"
    private let tokenKey = "auth_token"

    private init() {
        isLoggedIn = token != nil
        userName = UserDefaults.standard.string(forKey: "auth_user_name")
        userPhone = UserDefaults.standard.string(forKey: "auth_user_phone")
    }

    var token: String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        query.removeAll()
        return String(data: data, encoding: .utf8)
    }

    @MainActor
    func save(_ response: AuthTokenResponse) {
        setToken(response.token)
        UserDefaults.standard.set(response.user.name, forKey: "auth_user_name")
        UserDefaults.standard.set(response.user.phone, forKey: "auth_user_phone")
        userName = response.user.name
        userPhone = response.user.phone
        isLoggedIn = true
    }

    /// الخروج بيمسح الجلسة محلياً حتى لو الطلب فشل — المستخدم دوس خروج
    /// ولازم يخرج فعلاً، مش يفضل داخل لأن النت فصل.
    @MainActor
    func logout() {
        let current = token
        setToken(nil)
        UserDefaults.standard.removeObject(forKey: "auth_user_name")
        UserDefaults.standard.removeObject(forKey: "auth_user_phone")
        userName = nil
        userPhone = nil
        isLoggedIn = false

        if let current {
            Task { await AuthAPI.logout(token: current) }
        }
    }

    // MARK: Keychain

    private func setToken(_ value: String?) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
        ]
        SecItemDelete(query as CFDictionary)

        guard let value, let data = value.data(using: .utf8) else { return }

        var add = query
        add[kSecValueData as String] = data
        // التوكن يفضل متاح بعد أول فتح للجهاز بس — مش قبل ما المستخدم يفكّ القفل
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(add as CFDictionary, nil)
    }
}
