//
//  WalletViews.swift
//  MSA
//
//  المحفظة (المخزون) — بنفس ديزاين التطبيق.
//

import SwiftUI

private let goldColor = Color("MainColor")
private let greenColor = Color(red: 0.09, green: 0.66, blue: 0.34)
private let redColor = Color(red: 0.88, green: 0.32, blue: 0.25)
private let mutedColor = Color(white: 0.70)
private let cardBg = Color.black.opacity(0.35)

struct WalletView: View {

    var onBack: (() -> Void)?
    var onLogin: (() -> Void)?

    @StateObject private var vm = WalletViewModel()
    @State private var editing: PortfolioItem?
    @State private var adding = false
    @State private var zakatFor: PortfolioMetal?

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: "wallet_title".localized, isBackShow: true) { onBack?() }

                if !vm.isLoggedIn {
                    signInPrompt
                } else if vm.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
        }
        // شاشة الإضافة بتتفتح كـ sheet، فلما تتقفل بنعيد التحميل
        // عشان القطعة الجديدة تظهر من غير ما المستخدم يعمل حاجة.
        .sheet(isPresented: $adding, onDismiss: { vm.refresh() }) {
            WalletEditorView(existing: nil, wallet: vm)
        }
        .sheet(item: $editing, onDismiss: { vm.refresh() }) { item in
            WalletEditorView(existing: item, wallet: vm)
        }
        .sheet(item: $zakatFor) { metal in
            ZakatSheet(result: vm.zakat(for: metal))
        }
        .onAppear { syncPrices(); vm.refresh() }
    }

    /// الأسعار جاية من نفس المصدر اللي بتستخدمه باقي الشاشات
    private func syncPrices() {
        vm.gold21 = Double(metalPriceValue.goldPrice?.salePrice ?? "") ?? 0
        vm.silver999 = Double(metalPriceValue.silverPrice?.salePrice ?? "") ?? 0
    }

    // MARK: الحالات

    private var signInPrompt: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("wallet_login_title".localized)
                .font(.msa(20, weight: .bold))
                .foregroundColor(.white)
            Text("wallet_login_hint".localized)
                .font(.msa(14))
                .foregroundColor(mutedColor)
                .multilineTextAlignment(.center)
            AuthButton(title: "auth_login_action".localized) { onLogin?() }
                .padding(.top, 12)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("wallet_empty_title".localized)
                .font(.msa(20, weight: .bold))
                .foregroundColor(.white)
            Text("wallet_empty_hint".localized)
                .font(.msa(14))
                .foregroundColor(mutedColor)
                .multilineTextAlignment(.center)
            AuthButton(title: "wallet_add".localized) { adding = true }
                .padding(.top, 12)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 12) {
                summaryCard

                HStack(spacing: 12) {
                    metalCard(.gold)
                    metalCard(.silver)
                }

                zakatShortcut

                HStack {
                    Text(String(format: "wallet_items".localized, vm.summary.items_count))
                        .font(.msa(16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 4)

                ForEach(vm.items) { item in
                    itemRow(item)
                        .onTapGesture { editing = item }
                }

                AuthButton(title: "wallet_add".localized) { adding = true }
                    .padding(.top, 8)

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: الكروت

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("wallet_current_value".localized)
                .font(.msa(13))
                .foregroundColor(mutedColor)

            HStack(alignment: .bottom, spacing: 8) {
                Text(WalletFormat.money(vm.summary.current_value))
                    .font(.msa(31, weight: .bold))
                    .foregroundColor(.white)
                Text("egp".localized)
                    .font(.msa(14))
                    .foregroundColor(mutedColor)
                    .padding(.bottom, 5)
                Spacer()
                profitBadge(vm.summary.profit, vm.summary.profit_percent)
            }
            .padding(.top, 6)

            Rectangle()
                .fill(goldColor.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 14)

            HStack {
                stat("wallet_total_paid".localized, WalletFormat.money(vm.summary.total_paid))
                stat("wallet_total_weight".localized,
                     "\(WalletFormat.grams(vm.summary.total_weight)) \("gram".localized)")
            }
            HStack {
                stat("wallet_shop_price".localized, WalletFormat.money(vm.summary.shop_sell_value))
                stat("wallet_cashback".localized, WalletFormat.money(vm.summary.cashback_total))
            }
            .padding(.top, 12)
        }
        .padding(18)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(goldColor.opacity(0.6), lineWidth: 1))
    }

    private func profitBadge(_ profit: Double, _ percent: Double) -> some View {
        let positive = profit >= 0
        let color = positive ? greenColor : redColor
        let sign = positive ? "+" : ""

        return VStack(spacing: 1) {
            Text("\(sign)\(WalletFormat.grams(percent))%")
                .font(.msa(14, weight: .bold))
            Text("\(sign)\(WalletFormat.money(profit))")
                .font(.msa(11))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.msa(12)).foregroundColor(mutedColor)
            Text(value).font(.msa(15, weight: .bold)).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metalCard(_ metal: PortfolioMetal) -> some View {
        let data = vm.summary.forMetal(metal)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Circle()
                    .fill(metal == .gold ? goldColor : Color(white: 0.78))
                    .frame(width: 9, height: 9)
                Text(metal.titleKey.localized)
                    .font(.msa(14, weight: .bold))
                    .foregroundColor(.white)
            }

            if let data, data.items_count > 0 {
                Text(WalletFormat.money(data.current_value))
                    .font(.msa(20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                Text("\(WalletFormat.grams(data.total_weight)) \("gram".localized) · "
                     + String(format: "wallet_pieces".localized, data.items_count))
                    .font(.msa(12))
                    .foregroundColor(mutedColor)
                    .padding(.top, 4)

                Text("\(data.profit >= 0 ? "+" : "")\(WalletFormat.grams(data.profit_percent))%")
                    .font(.msa(13, weight: .bold))
                    .foregroundColor(data.profit >= 0 ? greenColor : redColor)
                    .padding(.top, 6)

                Text(String(format: "wallet_avg_buy".localized,
                            WalletFormat.money(data.avg_buy_price)))
                    .font(.msa(11))
                    .foregroundColor(mutedColor)
                    .padding(.top, 8)
            } else {
                Text("—").font(.msa(22, weight: .bold))
                    .foregroundColor(mutedColor).padding(.top, 10)
                Text("wallet_no_items".localized)
                    .font(.msa(12)).foregroundColor(mutedColor).padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(goldColor.opacity(0.35), lineWidth: 1))
    }

    private var zakatShortcut: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("wallet_zakat_title".localized)
                .font(.msa(15, weight: .bold))
                .foregroundColor(goldColor)
            Text("wallet_zakat_hint".localized)
                .font(.msa(12))
                .foregroundColor(mutedColor)
                .padding(.top, 3)

            HStack(spacing: 10) {
                AuthButton(title: "gold".localized, filled: false) { zakatFor = .gold }
                // زرار الفضة بيظهر بس لو عنده فضة فعلاً
                if (vm.summary.forMetal(.silver)?.items_count ?? 0) > 0 {
                    AuthButton(title: "silver".localized, filled: false) { zakatFor = .silver }
                }
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(goldColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(goldColor.opacity(0.5), lineWidth: 1))
    }

    private func itemRow(_ item: PortfolioItem) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(item.type.titleKey.localized)
                        .font(.msa(15, weight: .bold))
                        .foregroundColor(.white)
                    Text(String(format: "wallet_karat_chip".localized, item.karat))
                        .font(.msa(11, weight: .bold))
                        .foregroundColor(goldColor)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(goldColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                Text("\(WalletFormat.grams(item.weight)) \("gram".localized) · "
                     + String(format: "wallet_bought_at".localized,
                              WalletFormat.money(item.gram_price)))
                    .font(.msa(12))
                    .foregroundColor(mutedColor)

                if let note = item.note, !note.isEmpty {
                    Text(note).font(.msa(11))
                        .foregroundColor(mutedColor.opacity(0.75)).lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(WalletFormat.money(item.current_value))
                    .font(.msa(16, weight: .bold))
                    .foregroundColor(.white)
                Text("\(item.isProfit ? "+" : "")\(WalletFormat.grams(item.profitPercent))%")
                    .font(.msa(12, weight: .bold))
                    .foregroundColor(item.isProfit ? greenColor : redColor)
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(goldColor.opacity(0.25), lineWidth: 1))
        .contentShape(Rectangle())
    }
}

// MARK: - تنبيه الزكاة

/// PortfolioMetal لازم تبقى Identifiable عشان `.sheet(item:)`


struct ZakatSheet: View {

    let result: WalletZakat
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: String(format: "wallet_zakat_of".localized,
                                         result.metal.titleKey.localized),
                           isBackShow: true) { dismiss() }

                VStack(alignment: .leading, spacing: 0) {
                    row("wallet_zakat_pure".localized,
                        "\(WalletFormat.grams(result.pureGrams)) \("gram".localized)")
                    row("wallet_zakat_nisab".localized,
                        "\(WalletFormat.grams(result.nisab)) \("gram".localized)")

                    Rectangle().fill(Color("MainColor").opacity(0.25))
                        .frame(height: 1).padding(.vertical, 12)

                    if result.isDue {
                        row("wallet_zakat_grams".localized,
                            "\(WalletFormat.grams(result.zakatGrams)) \("gram".localized)")

                        Text("\(WalletFormat.money(result.zakatValue)) \("egp".localized)")
                            .font(.msa(24, weight: .bold))
                            .foregroundColor(Color("MainColor"))
                            .padding(.top, 10)

                        Text("wallet_zakat_due".localized)
                            .font(.msa(13, weight: .bold))
                            .foregroundColor(greenColor)
                            .padding(.top, 6)
                    } else {
                        Text("wallet_zakat_not_due".localized)
                            .font(.msa(14))
                            .foregroundColor(mutedColor)
                        Text(String(format: "wallet_zakat_remaining".localized,
                                    WalletFormat.grams(result.nisab - result.pureGrams)))
                            .font(.msa(12))
                            .foregroundColor(mutedColor)
                            .padding(.top, 6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("MainColor").opacity(0.5), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.msa(13)).foregroundColor(mutedColor)
            Spacer()
            Text(value).font(.msa(13, weight: .bold)).foregroundColor(.white)
        }
        .padding(.vertical, 3)
    }
}
