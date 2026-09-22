//
//  AddPortfolioItemScreen.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

//
//  AddPortfolioItemScreen.swift
//  MSA
//
//  Mirrors Android: presentation/screens/portfolio/AddPortfolioItemScreen.kt
//

import SwiftUI

struct AddPortfolioItemScreen: View {
    @StateObject private var vm = AddPortfolioItemViewModel()
    @Environment(\.dismiss) private var dismiss
    let onDone: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.05), Color(white: 0.10)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // ── Asset type ───────────────────────────
                    fieldLabel("نوع الأصل")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AssetType.allCases) { type in
                                assetChip(type: type)
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    // ── Quantity ──────────────────────────
                    fieldLabel(vm.type.measuredByWeight ? "الكمية بالجرامات" : "عدد الوحدات")
                    numberField(
                        text: $vm.quantityText,
                        placeholder: vm.type.measuredByWeight ? "10.5" : "2"
                    )

                    // ── Total price ───────────────────────
                    fieldLabel("إجمالي سعر الشراء (ج.م)")
                    numberField(text: $vm.totalPriceText, placeholder: "10000")

                    // Per-unit hint
                    if let per = vm.perUnitPrice {
                        let unit = vm.type.measuredByWeight ? "جم" : "وحدة"
                        Text("≈ \(String(format: "%,.2f", per)) ج.م / \(unit)")
                            .font(.caption)
                            .foregroundColor(.goldAccent)
                            .fontWeight(.medium)
                    }

                    // ── Date ──────────────────────────────
                    fieldLabel("تاريخ الشراء")
                    DatePicker(
                        "",
                        selection: $vm.purchaseDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .accentColor(.goldAccent)
                    .colorScheme(.dark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cardBG)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.goldAccent.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // ── Notes ─────────────────────────────
                    fieldLabel("ملاحظات (اختيارية)")
                    notesField()

                    if let err = vm.error {
                        Text(err).foregroundColor(.lossRed).font(.caption)
                    }

                    // ── Save ──────────────────────────────
                    Button {
                        vm.save()
                    } label: {
                        Group {
                            if vm.saving {
                                ProgressView().tint(.black)
                            } else {
                                Text("حفظ")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.isValid && !vm.saving ? Color.goldAccent : Color(white: 0.33))
                        )
                    }
                    .disabled(!vm.isValid || vm.saving)
                    .padding(.top, 8)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("إضافة سبيكة جديدة")
                    .foregroundColor(.white).font(.headline)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("إلغاء") { onDone() }.foregroundColor(.goldAccent)
            }
        }
        .toolbarBackground(Color(white: 0.07), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: vm.saved) { saved in
            if saved { onDone() }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Pieces

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundColor(Color(white: 0.8))
    }

    private func assetChip(type: AssetType) -> some View {
        let selected = vm.type == type
        return Text(type.displayAr)
            .font(.footnote)
            .fontWeight(selected ? .bold : .medium)
            .foregroundColor(selected ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selected ? Color.goldAccent : Color.cardBG)
                    if !selected {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.goldAccent.opacity(0.4), lineWidth: 1)
                    }
                }
            )
            .onTapGesture { vm.type = type }
    }

    private func numberField(text: Binding<String>, placeholder: String) -> some View {
        TextField("", text: text)
            .placeholder(when: text.wrappedValue.isEmpty) {
                Text(placeholder).foregroundColor(Color(white: 0.47))
            }
            .foregroundColor(.white)
            .keyboardType(.decimalPad)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(white: 0.33), lineWidth: 1)
                    )
            )
    }

    private func notesField() -> some View {
        TextField("", text: $vm.notes, axis: .vertical)
            .placeholder(when: vm.notes.isEmpty) {
                Text("مثلاً: من محل الذهب الفلاني")
                    .foregroundColor(Color(white: 0.47))
            }
            .foregroundColor(.white)
            .lineLimit(2...4)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(white: 0.33), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Theme shortcuts for this file

private extension Color {
    static let goldAccent = Color(red: 0.831, green: 0.686, blue: 0.357)
    static let lossRed    = Color(red: 0.91, green: 0.30, blue: 0.24)
    static let cardBG     = Color(white: 0.11).opacity(0.85)
}

// MARK: - Placeholder helper

extension View {
    @ViewBuilder
    func placeholder<P: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> P
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
