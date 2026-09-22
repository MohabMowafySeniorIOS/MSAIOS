//
//  PortfolioScreen.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

//
//  PortfolioScreen.swift
//  MSA
//
//  Mirrors Android: presentation/screens/portfolio/PortfolioScreen.kt
//

import SwiftUI

// MARK: - Theme

private extension Color {
    static let goldAccent  = Color(red: 0.831, green: 0.686, blue: 0.357) // #D4B05A
    static let profitGreen = Color(red: 0.18,  green: 0.80,  blue: 0.44)
    static let lossRed     = Color(red: 0.91,  green: 0.30,  blue: 0.24)
    static let cardBG      = Color(white: 0.11).opacity(0.85)
    static let dividerGray = Color(white: 0.23)
}

// MARK: - Root

struct PortfolioScreen: View {
    @StateObject private var vm = PortfolioViewModel()
    @State private var showAdd = false
    @State private var pendingDelete: PortfolioItemWithValue?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            backgroundLayer
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                Group {
                    if vm.loading {
                        Spacer()
                        ProgressView().tint(.goldAccent)
                        Spacer()
                    } else if vm.items.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 0) {
                            summaryCard
                            list
                        }
                    }
                }
            }

            // FAB (BottomEnd = left in RTL)
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .frame(width: 56, height: 56)
                    .background(Color.goldAccent)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAdd) {
            NavigationView {
                AddPortfolioItemScreen(onDone: { showAdd = false })
            }
        }
        .alert("حذف العنصر", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("إلغاء", role: .cancel) { pendingDelete = nil }
            Button("حذف", role: .destructive) {
                if let id = pendingDelete?.id { vm.remove(id: id) }
                pendingDelete = nil
            }
        } message: {
            Text("هل تريد بالتأكيد حذف هذا العنصر من محفظتك؟")
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Pieces

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [Color(white: 0.05), Color(white: 0.10)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.right")  // RTL back
                    .foregroundColor(.white)
                    .font(.body.weight(.semibold))
            }
            Spacer()
            Text("محفظتي")
                .foregroundColor(.white)
                .font(.title3.weight(.bold))
            Spacer()
            // Spacer for symmetry with back button
            Image(systemName: "chevron.right").opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.goldAccent.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.msa(50, weight: .semibold))
                    .foregroundColor(.goldAccent)
            }
            Text("محفظتك فارغة")
                .foregroundColor(.white)
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            Text("سجل أول عملية شراء لذهب أو فضة وسيقوم التطبيق بحساب الربح والخسارة على الفور بناءً على الأسعار الحالية.")
                .foregroundColor(Color(white: 0.73))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 10)
            Button { showAdd = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("إضافة سبيكة جديدة").bold()
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.goldAccent)
                .clipShape(Capsule())
            }
            .padding(.top, 24)
            Spacer()
        }
    }

    private var summaryCard: some View {
        let profitColor = vm.summary.isProfit ? Color.profitGreen : Color.lossRed
        let profitIcon  = vm.summary.isProfit ? "arrow.up.right" : "arrow.down.right"
        let sign        = vm.summary.totalProfit >= 0 ? "+" : ""

        return VStack(alignment: .leading, spacing: 0) {
            Text("القيمة الحالية")
                .font(.caption)
                .foregroundColor(Color(white: 0.6))
            Text(formatEgp(vm.summary.totalCurrentValue))
                .font(.msa(28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)

            if vm.pricesReady {
                HStack(spacing: 4) {
                    Image(systemName: profitIcon)
                        .font(.caption.weight(.bold))
                    Text("\(sign)\(formatEgp(vm.summary.totalProfit))  " +
                         "(\(sign)\(String(format: "%.2f", vm.summary.totalProfitPercent))%)")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(profitColor)
                .padding(.top, 6)
            }

            Divider().background(Color.dividerGray).padding(.vertical, 14)

            HStack {
                stat(label: "مبلغ الاستثمار", value: formatEgp(vm.summary.totalInvested))
                Spacer()
                stat(label: "عدد العناصر", value: "\(vm.summary.itemCount)")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.goldAccent.opacity(0.35), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func stat(label: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label).font(.caption2).foregroundColor(Color(white: 0.53))
            Text(value).font(.subheadline.weight(.semibold)).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(vm.items) { item in
                    PortfolioItemCard(item: item) {
                        pendingDelete = item
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 96)
        }
    }
}

// MARK: - Per-item card

private struct PortfolioItemCard: View {
    let item: PortfolioItemWithValue
    let onDelete: () -> Void

    var body: some View {
        let profitColor = item.isProfit ? Color.profitGreen : Color.lossRed
        let sign        = item.profit >= 0 ? "+" : ""

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.item.type.displayAr)
                        .font(.body.weight(.bold))
                        .foregroundColor(.goldAccent)
                    Text("الكمية: \(formatQuantity(item.item.quantity, byWeight: item.item.type.measuredByWeight))")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.8))
                }
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.callout)
                        .foregroundColor(Color(white: 0.53))
                }
            }

            Divider().background(Color.dividerGray).padding(.vertical, 10)

            HStack {
                metric(label: "مبلغ الاستثمار", value: formatEgp(item.item.purchaseTotalPrice))
                Spacer()
                metric(label: "القيمة الحالية",
                       value: item.pricesAvailable ? formatEgp(item.currentValue) : "—")
            }

            if item.pricesAvailable {
                HStack(alignment: .center) {
                    Text("\(sign)\(formatEgp(item.profit))  " +
                         "(\(sign)\(String(format: "%.2f", item.profitPercent))%)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(profitColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(profitColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                    Text(dateString(item.item.purchaseDate))
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.53))
                }
                .padding(.top, 10)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.cardBG)
        )
    }

    private func metric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundColor(Color(white: 0.53))
            Text(value).font(.subheadline.weight(.semibold)).foregroundColor(.white)
        }
    }
}

// MARK: - Formatters

func formatEgp(_ value: Double) -> String {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.maximumFractionDigits = 2
    nf.minimumFractionDigits = 2
    nf.locale = Locale(identifier: "en_US")     // Latin digits, then we append ج.م
    let absStr = nf.string(from: NSNumber(value: abs(value))) ?? "0.00"
    return "\(value < 0 ? "-" : "")\(absStr) ج.م"
}

func formatQuantity(_ q: Double, byWeight: Bool) -> String {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.maximumFractionDigits = 3
    nf.minimumFractionDigits = 0
    nf.locale = Locale(identifier: "en_US")
    let str = nf.string(from: NSNumber(value: q)) ?? "0"
    return byWeight ? "\(str) جم" : str
}

private func dateString(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy/MM/dd"
    return df.string(from: date)
}
