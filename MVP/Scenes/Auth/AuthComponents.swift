//
//  AuthComponents.swift
//  MSA
//
//  عناصر واجهة الحساب — بنفس ديزاين التطبيق: خلفية الهوية،
//  حقول بحدّ ذهبي، وزرار ذهبي.
//

import SwiftUI

/// حقل إدخال بعنوان — الحدّ بيبقى أحمر لو فيه خطأ.
struct AuthField: View {

    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isPassword = false
    /// الأرقام والإيميل وكلمات السر بتتكتب من الشمال لليمين حتى والواجهة عربي
    var forceLTR = false
    var error = false

    @State private var visible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.msa(13, weight: .bold))
                .foregroundColor(error ? Color(red: 0.88, green: 0.32, blue: 0.25)
                                       : Color(white: 0.78))

            HStack(spacing: 8) {
                Group {
                    if isPassword && !visible {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .font(.msa(15))
                .environment(\.layoutDirection, forceLTR ? .leftToRight : .rightToLeft)
                .multilineTextAlignment(forceLTR ? .leading : .trailing)

                if isPassword {
                    Button { visible.toggle() } label: {
                        Image(systemName: visible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color(white: 0.65))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 13)
            .background(Color.black.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error ? Color(red: 0.88, green: 0.32, blue: 0.25)
                                  : Color("MainColor").opacity(0.55),
                            lineWidth: error ? 2 : 1.5)
            )
        }
    }
}

/// زرار الحساب الأساسي — `filled = false` بيدي نسخة بحدّ بس.
struct AuthButton: View {

    let title: String
    var filled = true
    var loading = false
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if loading {
                    ProgressView().tint(filled ? .white : Color("MainColor"))
                }
                Text(title)
                    .font(.msa(filled ? 17 : 15, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, filled ? 15 : 12)
            .background(filled ? Color("MainColor") : Color.clear)
            .foregroundColor(filled ? .white : Color("MainColor"))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(filled ? Color.clear : Color("MainColor"), lineWidth: 1.5)
            )
        }
        .disabled(!enabled || loading)
        .opacity(enabled ? 1 : 0.5)
    }
}

/// رسالة خطأ فوق الزرار
struct AuthErrorBox: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.msa(13, weight: .semibold))
            .foregroundColor(Color(red: 0.88, green: 0.32, blue: 0.25))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(red: 0.88, green: 0.32, blue: 0.25).opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
