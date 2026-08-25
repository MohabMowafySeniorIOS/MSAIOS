//
//  ContactUsView.swift
//  MSA
//
//  Created by Mohab Mowafy on 29/06/2026.
//

import Foundation
import SwiftUI

import SwiftUI

struct ContactUsView: View {

    @Environment(\.dismiss) private var dismiss

    private let email = "support@msagold.com"
    private let phone = "+201070000538‎"
    private let website = "https://msagold.com"

    var body: some View {


            VStack {
                headerView(title: "تواصل معنا", isBackShow: true) {
                    dismiss()
                }
                
                ScrollView(showsIndicators: false) {

                    VStack(spacing: 28) {

                        headerSection

                        contactSection

                      //  aboutSection


                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom,30)
                }
            }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarHidden(true)
        .background(BGSwiftUIView())
    }
}

// MARK: Header

private extension ContactUsView {

    var headerSection: some View {

        VStack(spacing: 18) {


            Text("إذا كان لديك أي استفسار أو اقتراح أو واجهت أي مشكلة أثناء استخدام التطبيق، يمكنك التواصل معنا من خلال وسائل الاتصال التالية، وسنكون سعداء بالرد عليك في أقرب وقت ممكن.")
                .font(.system(size: 16))
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal,8)

        }
    }

}

// MARK: Contact

private extension ContactUsView {

    var contactSection: some View {

        VStack(spacing: 18) {

            ContactRow(
                icon: "globe",
                title: "الموقع الإلكتروني",
                value: website
            ) {
                openWebsite()
            }

            ContactRow(
                icon: "envelope.fill",
                title: "البريد الإلكتروني",
                value: email
            ) {
                sendEmail()
            }

            ContactRow(
                icon: "phone.fill",
                title: "رقم الهاتف",
                value: phone
            ) {
                callPhone()
            }

        }
    }

}

// MARK: About

private extension ContactUsView {

    var aboutSection: some View {

        VStack(alignment: .trailing, spacing: 16) {

            HStack {
                HStack(spacing: 8) {

                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.MainColor)
                        .font(.title2)

                    Text("عن التطبيق")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.MainColor)
                }
                Spacer()
            }

            Text("""
يوفر تطبيق MSA Gold أسعار الذهب والفضة وأسعار صرف العملات، بالإضافة إلى الأخبار الاقتصادية ومعلومات الأسواق المالية.

يتم تحديث البيانات بشكل دوري لضمان عرض أحدث الأسعار والمعلومات للمستخدمين.
""")
            .font(.system(size: 15))
            .foregroundColor(.white.opacity(0.9))
            .lineSpacing(7)

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.MainColor.opacity(0.45), lineWidth: 1)
        )
    }

}



// MARK: Actions

private extension ContactUsView {

    func openWebsite() {

        guard let url = URL(string: website) else { return }

        UIApplication.shared.open(url)
    }

    func sendEmail() {

        guard let url = URL(string: "mailto:\(email)") else { return }

        UIApplication.shared.open(url)
    }

    func callPhone() {

        let number = phone.replacingOccurrences(of: " ", with: "")

        guard let url = URL(string: "tel://\(number)") else { return }

        UIApplication.shared.open(url)
    }

}

#Preview {

    NavigationStack {

        ContactUsView()

    }

}

#Preview {
    NavigationStack {
        ContactUsView()
    }
}
import SwiftUI

struct ContactRow: View {

    let icon: String
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: 16) {

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 35)

                VStack(alignment: .leading, spacing: 4) {

                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.black.opacity(0.3)))
            .cornerRadius(20)
            .overlay {
                RoundedRectangle(
                    cornerRadius: 20
                )
                .stroke(
                    Color.MainColor,
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContactRow(
        icon: "phone.fill",
        title: "رقم الهاتف",
        value: "+201037000079"
    ) {}
}
