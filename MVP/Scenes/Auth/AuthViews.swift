//
//  AuthViews.swift
//  MSA
//
//  شاشات الحساب — دخول، تسجيل، تأكيد الكود.
//

import SwiftUI

// MARK: - الدخول

struct LoginView: View {

    var onBack: (() -> Void)?
    var onFinished: (() -> Void)?
    var onGoRegister: (() -> Void)?
    var onNeedVerify: ((String) -> Void)?

    @StateObject private var vm = AuthViewModel()
    @State private var phone = ""
    @State private var password = ""
    @State private var touched = false

    private var phoneBad: Bool { !AuthViewModel.isValidPhone(phone) }
    private var passBad: Bool { password.count < 6 }

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: "auth_login_title".localized, isBackShow: true) {
                    onBack?()
                }

                ScrollView {
                    VStack(spacing: 16) {
                        Text("auth_login_hint".localized)
                            .font(.msa(13))
                            .foregroundColor(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                        AuthField(label: "auth_phone".localized,
                                  text: $phone, keyboard: .numberPad,
                                  forceLTR: true, error: touched && phoneBad)
                            .onChange(of: phone) { _ in
                                phone = String(phone.filter(\.isNumber).prefix(11))
                                vm.clearError()
                            }

                        AuthField(label: "auth_password".localized,
                                  text: $password, isPassword: true,
                                  forceLTR: true, error: touched && passBad)
                            .onChange(of: password) { _ in vm.clearError() }

                        if let error = vm.error {
                            AuthErrorBox(message: error)
                        }

                        AuthButton(title: "auth_login_action".localized, loading: vm.busy) {
                            touched = true
                            if !phoneBad && !passBad { vm.login(phone: phone, password: password) }
                        }
                        .padding(.top, 6)

                        AuthButton(title: "auth_go_register".localized, filled: false) {
                            onGoRegister?()
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 22)
                }
            }
        }
        .onChange(of: vm.done) { if $0 { onFinished?() } }
        .onChange(of: vm.pendingPhone) { if let p = $0 { onNeedVerify?(p) } }
    }
}

// MARK: - التسجيل

struct RegisterView: View {

    var onBack: (() -> Void)?
    var onCodeSent: ((String) -> Void)?
    var onGoLogin: (() -> Void)?

    @StateObject private var vm = AuthViewModel()
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var touched = false

    private var nameBad: Bool { name.trimmingCharacters(in: .whitespaces).count < 3 }
    private var emailBad: Bool { !AuthViewModel.isValidEmail(email) }
    private var phoneBad: Bool { !AuthViewModel.isValidPhone(phone) }
    private var passBad: Bool { password.count < 6 }
    private var confirmBad: Bool { confirm != password }

    private var localError: String? {
        guard touched else { return nil }
        if nameBad    { return "auth_err_name".localized }
        if emailBad   { return "auth_err_email".localized }
        if phoneBad   { return "auth_err_phone".localized }
        if passBad    { return "auth_err_password".localized }
        if confirmBad { return "auth_err_confirm".localized }
        return nil
    }

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: "auth_register_title".localized, isBackShow: true) {
                    onBack?()
                }

                ScrollView {
                    VStack(spacing: 14) {
                        Text("auth_register_hint".localized)
                            .font(.msa(13))
                            .foregroundColor(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 6)

                        AuthField(label: "auth_name".localized, text: $name,
                                  error: touched && nameBad)
                            .onChange(of: name) { _ in vm.clearError() }

                        AuthField(label: "auth_email".localized, text: $email,
                                  keyboard: .emailAddress, forceLTR: true,
                                  error: touched && emailBad)
                            .onChange(of: email) { _ in vm.clearError() }

                        AuthField(label: "auth_phone".localized, text: $phone,
                                  keyboard: .numberPad, forceLTR: true,
                                  error: touched && phoneBad)
                            .onChange(of: phone) { _ in
                                phone = String(phone.filter(\.isNumber).prefix(11))
                                vm.clearError()
                            }

                        AuthField(label: "auth_password".localized, text: $password,
                                  isPassword: true, forceLTR: true,
                                  error: touched && passBad)
                            .onChange(of: password) { _ in vm.clearError() }

                        AuthField(label: "auth_confirm_password".localized, text: $confirm,
                                  isPassword: true, forceLTR: true,
                                  error: touched && confirmBad)
                            .onChange(of: confirm) { _ in vm.clearError() }

                        if let message = vm.error ?? localError {
                            AuthErrorBox(message: message)
                        }

                        AuthButton(title: "auth_register_action".localized, loading: vm.busy) {
                            touched = true
                            if !nameBad && !emailBad && !phoneBad && !passBad && !confirmBad {
                                vm.register(name: name, email: email, phone: phone,
                                            password: password, confirm: confirm)
                            }
                        }
                        .padding(.top, 6)

                        AuthButton(title: "auth_go_login".localized, filled: false) {
                            onGoLogin?()
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 22)
                }
            }
        }
        .onChange(of: vm.pendingPhone) { if let p = $0 { onCodeSent?(p) } }
    }
}

// MARK: - تأكيد الكود

struct VerifyOtpView: View {

    let phone: String
    var onBack: (() -> Void)?
    var onVerified: (() -> Void)?

    @StateObject private var vm = AuthViewModel()
    @State private var code = ""
    @FocusState private var focused: Bool

    private let length = 6
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: "auth_verify_title".localized, isBackShow: true) {
                    onBack?()
                }

                ScrollView {
                    VStack(spacing: 18) {
                        Text(String(format: "auth_verify_hint".localized, phone))
                            .font(.msa(13))
                            .foregroundColor(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 26)
                            .padding(.top, 14)

                        codeBoxes

                        if let error = vm.error {
                            AuthErrorBox(message: error)
                        }

                        AuthButton(title: "auth_verify_action".localized,
                                   loading: vm.busy,
                                   enabled: code.count == length) {
                            vm.verify(phone: phone, code: code)
                        }

                        Button {
                            vm.resend(phone: phone)
                        } label: {
                            Text(vm.resendCooldown > 0
                                 ? String(format: "auth_resend_in".localized, vm.resendCooldown)
                                 : "auth_resend".localized)
                                .font(.msa(14, weight: .bold))
                                .foregroundColor(vm.resendCooldown > 0
                                                 ? Color(white: 0.55) : Color("MainColor"))
                        }
                        .disabled(vm.resendCooldown > 0 || vm.busy)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 22)
                }
            }
        }
        .onAppear { focused = true }
        .onReceive(timer) { _ in vm.tickCooldown() }
        .onChange(of: vm.done) { if $0 { onVerified?() } }
        // لما يكمل الكود بنتحقق تلقائياً — أسرع من إنه يدوس زرار
        .onChange(of: code) { value in
            if value.count == length && !vm.busy { vm.verify(phone: phone, code: value) }
        }
    }

    /// حقل واحد مخفي بيتحكم في ستة مربعات معروضة — أثبت من ستة
    /// حقول منفصلة بتتنطّط بينهم.
    private var codeBoxes: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .focused($focused)
                .foregroundColor(.clear)
                .accentColor(.clear)
                .frame(width: 280, height: 56)
                .onChange(of: code) { _ in
                    code = String(code.filter(\.isNumber).prefix(length))
                    vm.clearError()
                }

            HStack(spacing: 9) {
                ForEach(0..<length, id: \.self) { index in
                    let char = index < code.count
                        ? String(Array(code)[index]) : ""
                    let active = index == code.count

                    Text(char)
                        .font(.msa(22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 54)
                        .background(Color.black.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .stroke(vm.error != nil
                                        ? Color(red: 0.88, green: 0.32, blue: 0.25)
                                        : (active ? Color("MainColor")
                                                  : Color("MainColor").opacity(0.45)),
                                        lineWidth: active ? 2 : 1.5)
                        )
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }
}
