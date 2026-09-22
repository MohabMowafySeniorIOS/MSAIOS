//
//  ProfileView.swift
//  MSA
//
//  البروفايل — تعديل البيانات، تغيير كلمة السر، الخروج، وحذف الحساب.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var loading = true
    @Published var busy = false
    @Published var error: String?
    @Published var saved = false
    @Published var signedOut = false

    @Published var name = ""
    @Published var email = ""
    @Published private(set) var phone = ""

    func load() {
        Task {
            loading = true
            error = nil
            do {
                let user = try await PortfolioAPI.profile()
                name = user.name
                email = user.email ?? ""
                phone = user.phone
            } catch let e as AuthAPIError {
                error = e.displayMessage
            } catch {
                self.error = AuthAPIError.network.displayMessage
            }
            loading = false
        }
    }

    func save() {
        Task {
            busy = true; error = nil; saved = false
            do {
                let user = try await PortfolioAPI.updateProfile(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: email.trimmingCharacters(in: .whitespaces))
                name = user.name
                email = user.email ?? ""
                saved = true
            } catch let e as AuthAPIError {
                error = e.displayMessage
            } catch {
                self.error = AuthAPIError.network.displayMessage
            }
            busy = false
        }
    }

    func changePassword(current: String, new: String, confirm: String,
                        onDone: @escaping (String?) -> Void) {
        Task {
            busy = true
            do {
                try await PortfolioAPI.changePassword(current: current, new: new, confirm: confirm)
                busy = false
                onDone(nil)
            } catch let e as AuthAPIError {
                busy = false
                onDone(e.displayMessage)
            } catch {
                busy = false
                onDone(AuthAPIError.network.displayMessage)
            }
        }
    }

    func logout() {
        AuthSession.shared.logout()
        signedOut = true
    }

    func deleteAccount() {
        guard let token = AuthSession.shared.token else { signedOut = true; return }
        Task {
            busy = true; error = nil
            do {
                _ = try await AuthAPI.deleteAccount(token: token)
                AuthSession.shared.logout()
                signedOut = true
            } catch let e as AuthAPIError {
                error = e.displayMessage
            } catch {
                self.error = AuthAPIError.network.displayMessage
            }
            busy = false
        }
    }
}

struct ProfileView: View {

    var onBack: (() -> Void)?
    var onSignedOut: (() -> Void)?

    @StateObject private var vm = ProfileViewModel()
    @State private var showPassword = false
    @State private var confirmLogout = false
    @State private var confirmDelete = false

    private let gold = Color("MainColor")
    private let muted = Color(white: 0.70)
    private let red = Color(red: 0.88, green: 0.32, blue: 0.25)

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: "profile_title".localized, isBackShow: true) { onBack?() }

                if vm.loading {
                    Spacer()
                    ProgressView().tint(gold)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            detailsCard
                            passwordCard
                            dangerCard
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear { vm.load() }
        .onChange(of: vm.signedOut) { if $0 { onSignedOut?() } }
        .sheet(isPresented: $showPassword) {
            ChangePasswordSheet(vm: vm)
        }
        .alert("auth_logout".localized, isPresented: $confirmLogout) {
            Button("cancel".localized, role: .cancel) {}
            Button("auth_logout".localized, role: .destructive) { vm.logout() }
        } message: {
            Text("profile_logout_confirm".localized)
        }
        .alert("profile_delete_account".localized, isPresented: $confirmDelete) {
            Button("cancel".localized, role: .cancel) {}
            Button("profile_delete_account".localized, role: .destructive) { vm.deleteAccount() }
        } message: {
            Text("profile_delete_confirm".localized)
        }
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            AuthField(label: "auth_name".localized, text: $vm.name)
            AuthField(label: "auth_email".localized, text: $vm.email,
                      keyboard: .emailAddress, forceLTR: true)

            // الموبايل مقفول: مربوط بتفعيل بكود، فتغييره لازم يعدي
            // على نفس مسار التأكيد.
            VStack(alignment: .leading, spacing: 6) {
                Text("auth_phone".localized)
                    .font(.msa(13, weight: .bold))
                    .foregroundColor(muted)
                Text(vm.phone)
                    .font(.msa(15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12).padding(.vertical, 14)
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text("profile_phone_locked".localized)
                    .font(.msa(11))
                    .foregroundColor(muted)
            }

            if let error = vm.error { AuthErrorBox(message: error) }
            if vm.saved {
                Text("profile_saved".localized)
                    .font(.msa(13, weight: .bold))
                    .foregroundColor(Color(red: 0.09, green: 0.66, blue: 0.34))
            }

            AuthButton(title: "profile_save".localized, loading: vm.busy) { vm.save() }
        }
        .padding(16)
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.5), lineWidth: 1))
    }

    private var passwordCard: some View {
        AuthButton(title: "profile_change_password".localized, filled: false) {
            showPassword = true
        }
        .padding(16)
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.5), lineWidth: 1))
    }

    private var dangerCard: some View {
        VStack(spacing: 12) {
            AuthButton(title: "auth_logout".localized, filled: false) { confirmLogout = true }

            Button { confirmDelete = true } label: {
                Text("profile_delete_account".localized)
                    .font(.msa(14, weight: .bold))
                    .foregroundColor(red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(Capsule().stroke(red.opacity(0.6), lineWidth: 1.5))
            }

            Text("profile_delete_hint".localized)
                .font(.msa(11))
                .foregroundColor(muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.5), lineWidth: 1))
    }
}

private struct ChangePasswordSheet: View {

    @ObservedObject var vm: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var current = ""
    @State private var new = ""
    @State private var confirm = ""
    @State private var error: String?

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: "profile_change_password".localized,
                           isBackShow: true) { dismiss() }

                VStack(spacing: 14) {
                    AuthField(label: "profile_current_password".localized,
                              text: $current, isPassword: true, forceLTR: true)
                    AuthField(label: "profile_new_password".localized,
                              text: $new, isPassword: true, forceLTR: true)
                    AuthField(label: "auth_confirm_password".localized,
                              text: $confirm, isPassword: true, forceLTR: true)

                    if let error { AuthErrorBox(message: error) }

                    AuthButton(title: "wallet_save".localized, loading: vm.busy) {
                        // نتحقق محلياً الأول عشان ما نتعبش السيرفر
                        if new.count < 6 {
                            error = "auth_err_password".localized
                        } else if new != confirm {
                            error = "auth_err_confirm".localized
                        } else {
                            vm.changePassword(current: current, new: new, confirm: confirm) { message in
                                if message == nil { dismiss() } else { error = message }
                            }
                        }
                    }
                    .padding(.top, 4)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
