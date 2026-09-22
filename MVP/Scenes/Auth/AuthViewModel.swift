//
//  AuthViewModel.swift
//  MSA
//

import Foundation
import FirebaseMessaging

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var busy = false
    @Published var error: String?
    /// بيتملا بعد التسجيل — شاشة الكود بتستخدمه
    @Published var pendingPhone: String?
    @Published var done = false
    @Published var resendCooldown = 0

    private let session = AuthSession.shared

    func clearError() { error = nil }

    // MARK: التحقق المحلي — قبل ما نتعب السيرفر

    static func isValidPhone(_ value: String) -> Bool {
        value.range(of: "^01[0125][0-9]{8}$", options: .regularExpression) != nil
    }

    static func isValidEmail(_ value: String) -> Bool {
        value.range(of: "^[^@\\s]+@[^@\\s]+\\.[A-Za-z]{2,}$", options: .regularExpression) != nil
    }

    // MARK: العمليات

    func login(phone: String, password: String) {
        busy = true; error = nil
        Task {
            do {
                let response = try await AuthAPI.login(
                    phone: phone, password: password, fcmToken: await fcmToken())
                session.save(response)
                DeviceTokenSync.sync()
                busy = false
                done = true
            } catch let e as AuthAPIError {
                busy = false
                // 409 معناها الرقم لسه مش مفعّل والسيرفر بعت كود جديد،
                // فبنوديه لشاشة الكود بدل ما نعرض خطأ ونسيبه مقفول.
                if e.serverCode == "phone_not_verified" {
                    pendingPhone = phone
                }
                error = e.displayMessage
            } catch {
                busy = false
                self.error = AuthAPIError.network.displayMessage
            }
        }
    }

    func register(name: String, email: String, phone: String,
                  password: String, confirm: String) {
        busy = true; error = nil
        Task {
            do {
                _ = try await AuthAPI.register(
                    name: name, email: email, phone: phone,
                    password: password, confirm: confirm, fcmToken: await fcmToken())
                busy = false
                pendingPhone = phone
            } catch let e as AuthAPIError {
                busy = false
                error = e.displayMessage
            } catch {
                busy = false
                self.error = AuthAPIError.network.displayMessage
            }
        }
    }

    func verify(phone: String, code: String) {
        busy = true; error = nil
        Task {
            do {
                let response = try await AuthAPI.verifyOtp(phone: phone, code: code)
                session.save(response)
                /*
                 * `verify-otp` هو اللي بيرجّع توكن الدخول، والطلب ده
                 * مابيحملش `fcm_token` أصلاً. فأول حاجة بعد ما الجلسة
                 * تتحفظ: نبعت توكن الجهاز — من غير كده المستخدم الجديد
                 * ما يوصلوش أي إشعار موجّه لحد ما يعمل دخول تاني.
                 */
                DeviceTokenSync.sync()
                busy = false
                done = true
            } catch let e as AuthAPIError {
                busy = false
                error = e.displayMessage
            } catch {
                busy = false
                self.error = AuthAPIError.network.displayMessage
            }
        }
    }

    func resend(phone: String) {
        Task {
            do {
                _ = try await AuthAPI.resendOtp(phone: phone)
                resendCooldown = 60
                error = nil
            } catch let e as AuthAPIError {
                error = e.displayMessage
                if case .server(_, _, let cooldown) = e, let cooldown {
                    resendCooldown = cooldown
                }
            } catch {
                self.error = AuthAPIError.network.displayMessage
            }
        }
    }

    func tickCooldown() {
        if resendCooldown > 0 { resendCooldown -= 1 }
    }

    /// التوكن بيتبعت مع التسجيل والدخول عشان السيرفر يقدر يوجّه الإشعارات.
    private func fcmToken() async -> String? {
        try? await Messaging.messaging().token()
    }
}
