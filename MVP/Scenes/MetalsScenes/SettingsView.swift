//
//  SettingsView.swift
//  MSA
//
//  شاشة الإعدادات — تحكّم منفصل لكل نوع إشعار.
//  نفس الشاشة والترتيب في أندرويد (SettingsScreen.kt).
//

import SwiftUI

final class SettingsViewModel: ObservableObject {

    @Published var enabled: [NotificationCategory: Bool] = [:]

    init() {
        for category in NotificationCategory.allCases {
            enabled[category] = NotificationSettings.isEnabled(category)
        }
    }

    func binding(for category: NotificationCategory) -> Binding<Bool> {
        Binding(
            get: { self.enabled[category] ?? true },
            set: { newValue in
                self.enabled[category] = newValue
                NotificationSettings.setEnabled(newValue, for: category)
            }
        )
    }
}

struct SettingsView: View {

    @StateObject private var vm = SettingsViewModel()
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {

            headerView(title: "Settings".localized, isBackShow: true) {
                onBack?()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {

                    Text("notifications_section".localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("MainColor"))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ForEach(NotificationCategory.allCases, id: \.self) { category in
                        SettingSwitchRow(
                            title: category.title,
                            subtitle: category.subtitle,
                            isOn: vm.binding(for: category)
                        )
                        .padding(.horizontal, 16)
                    }

                    Text("notif_system_hint".localized)
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.65))
                        .padding(.horizontal, 22)
                        .padding(.top, 6)

                    Spacer(minLength: 90)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(BGSwiftUIView())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

private struct SettingSwitchRow: View {

    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.72))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("MainColor"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainColor").opacity(0.55), lineWidth: 1)
        )
    }
}
