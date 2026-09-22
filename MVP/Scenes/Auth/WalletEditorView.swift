//
//  WalletEditorView.swift
//  MSA
//
//  إضافة أو تعديل قطعة في المحفظة.
//

import SwiftUI

struct WalletEditorView: View {

    let existing: PortfolioItem?
    @ObservedObject var wallet: WalletViewModel

    @StateObject private var vm = WalletEditorViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var draft = PortfolioDraft()
    @State private var touched = false
    /// بيبقى true أول ما المستخدم يكتب الإجمالي بإيده، فنبطّل الحساب التلقائي
    @State private var totalEdited = false

    private var weightBad: Bool { (Double(draft.weight) ?? 0) <= 0 }
    private var priceBad: Bool { (Double(draft.gramPrice) ?? 0) <= 0 }

    private let gold = Color("MainColor")
    private let muted = Color(white: 0.70)

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(
                    title: (existing == nil ? "wallet_add" : "wallet_edit").localized,
                    isBackShow: true
                ) { dismiss() }

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        label("wallet_metal".localized)
                        chips(PortfolioMetal.allCases.map { ($0.rawValue, $0.titleKey.localized) },
                              selected: draft.metal.rawValue) { value in
                            draft.metal = PortfolioMetal(rawValue: value) ?? .gold
                            // لو العيار الحالي مش من عيارات المعدن الجديد نرجّعه لأول واحد
                            if !draft.metal.karats.contains(draft.karat) {
                                draft.karat = draft.metal.karats[0]
                            }
                            syncGramPrice()
                        }

                        label("wallet_karat".localized)
                        chips(draft.metal.karats.map {
                            ($0, String(format: "wallet_karat_chip".localized, $0))
                        }, selected: draft.karat) { value in
                            draft.karat = value
                            syncGramPrice()
                        }

                        label("wallet_type".localized)
                        chips(PortfolioItemType.allCases.map { ($0.rawValue, $0.titleKey.localized) },
                              selected: draft.type.rawValue) { value in
                            draft.type = PortfolioItemType(rawValue: value) ?? .bullion
                        }

                        HStack(spacing: 12) {
                            AuthField(label: "wallet_weight".localized,
                                      text: $draft.weight, keyboard: .decimalPad,
                                      forceLTR: true, error: touched && weightBad)
                            AuthField(label: "wallet_gram_price".localized,
                                      text: $draft.gramPrice, keyboard: .decimalPad,
                                      forceLTR: true, error: touched && priceBad)
                        }
                        .padding(.top, 4)

                        AuthField(label: "wallet_manufacturing".localized,
                                  text: $draft.manufacturing, keyboard: .decimalPad, forceLTR: true)

                        AuthField(label: "wallet_total_paid".localized,
                                  text: $draft.totalPaid, keyboard: .decimalPad, forceLTR: true)
                            .onChange(of: draft.totalPaid) { _ in totalEdited = true }
                        Text("wallet_total_hint".localized)
                            .font(.msa(11))
                            .foregroundColor(muted)

                        AuthField(label: "wallet_cashback_per_gram".localized,
                                  text: $draft.cashback, keyboard: .decimalPad, forceLTR: true)

                        AuthField(label: "wallet_note".localized, text: $draft.note)

                        if let error = vm.error {
                            AuthErrorBox(message: error)
                        }

                        AuthButton(title: "wallet_save".localized, loading: vm.busy) {
                            touched = true
                            if !weightBad && !priceBad {
                                vm.save(draft, existingId: existing?.id)
                            }
                        }
                        .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear(perform: prefill)
        .onChange(of: vm.saved) { if $0 { dismiss() } }
        // الإجمالي بيتحسب لحد ما المستخدم يكتبه بإيده
        .onChange(of: draft.weight) { _ in recomputeTotal() }
        .onChange(of: draft.gramPrice) { _ in recomputeTotal() }
        .onChange(of: draft.manufacturing) { _ in recomputeTotal() }
    }

    // MARK: المنطق

    private func prefill() {
        guard let item = existing else {
            syncGramPrice()
            return
        }
        draft.metal = item.metalKind
        draft.karat = item.karat
        draft.type = item.type
        draft.weight = String(item.weight)
        draft.gramPrice = String(item.gram_price)
        draft.manufacturing = item.manufacturing_per_gram > 0 ? String(item.manufacturing_per_gram) : ""
        draft.cashback = item.cashback_per_gram > 0 ? String(item.cashback_per_gram) : ""
        draft.totalPaid = String(item.total_paid)
        draft.note = item.note ?? ""
        totalEdited = true   // القيمة محفوظة، فمنغيّرهاش تلقائياً
    }

    /// سعر الجرام بيتحدّث مع تغيير العيار — للقطع الجديدة بس
    private func syncGramPrice() {
        guard existing == nil else { return }
        let market = wallet.currentGramPrice(metal: draft.metal, karat: draft.karat)
        if market > 0 { draft.gramPrice = String(format: "%.2f", market) }
    }

    private func recomputeTotal() {
        guard !totalEdited else { return }
        let w = Double(draft.weight) ?? 0
        let g = Double(draft.gramPrice) ?? 0
        let m = Double(draft.manufacturing) ?? 0
        if w > 0 && g > 0 {
            draft.totalPaid = String(format: "%.2f", w * g + w * m)
        }
    }

    // MARK: عناصر

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.msa(13, weight: .bold))
            .foregroundColor(Color(white: 0.78))
    }

    private func chips(_ options: [(String, String)],
                       selected: String,
                       onSelect: @escaping (String) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.0) { value, title in
                    let active = value == selected
                    Text(title)
                        .font(.msa(13, weight: active ? .bold : .regular))
                        .foregroundColor(active ? .white : Color(white: 0.7))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(active ? gold.opacity(0.22) : Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(active ? gold : gold.opacity(0.3), lineWidth: 1))
                        .onTapGesture { onSelect(value) }
                }
            }
        }
    }
}
