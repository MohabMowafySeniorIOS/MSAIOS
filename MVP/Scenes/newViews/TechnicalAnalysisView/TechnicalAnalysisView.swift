//
//  TechnicalAnalysisView.swift
//  MSA
//
//  Created by Mohab Mowafy on 04/06/2026.
//

import SwiftUI

// MARK: - Technical Analysis Screen (شاشة التحليل الفني)

struct TechnicalAnalysisView: View {
    @StateObject private var provider = TechnicalAnalysisProvider.shared
    @State private var selectedPeriod: TAPeriod = .yesterday
    @State private var showDatePicker = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
        BGSwiftUIView()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────
                headerView(title: "الفنية الإرشادات", isBackShow: true,onDismiss: {
                    dismiss()
                })

                // ── Period Tabs ──────────────────────────────────────────
                PeriodTabBar(selected: $selectedPeriod)
                    .onChange(of: selectedPeriod) { p in
                        provider.load(period: p)
                    }

                // ── Content ──────────────────────────────────────────────
                if provider.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .MainColor))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let d = provider.data {
                    ScrollView {
                        VStack(spacing: 12) {
                            // Period date card
                            PeriodDateCard(
                                startDate: d.startDate,
                                endDate:   d.endDate,
                                onCalendarTap: { showDatePicker.toggle() }
                            )

                            // ── 2x2 Grid: gold21 / gold24 ──────────────
                            HStack(spacing: 10) {
                                InstrumentCard(
                                    title: "سعر الذهب عيار 21",
                                    snapshot: d.gold21,
                                    unit: "جنيه",
                                    decimals: 0
                                )
                                InstrumentCard(
                                    title: "سعر الذهب عيار 24",
                                    snapshot: d.gold24,
                                    unit: "جنيه",
                                    decimals: 0
                                )
                            }

                            // ── دولار الصاغة / سعر الأوقية ─────────────
                            HStack(spacing: 10) {
                                InstrumentCard(
                                    title: "دولار الصاغة",
                                    snapshot: d.jewelryUSD,
                                    unit: "جنيه",
                                    decimals: 2
                                )
                                InstrumentCard(
                                    title: "سعر الأوقية عالميا",
                                    snapshot: d.goldUSD,
                                    unit: "دولار",
                                    decimals: 1
                                )
                            }

                            // ── سعر الفضة / الدولار البنكي ──────────────
                            HStack(spacing: 10) {
                                InstrumentCard(
                                    title: "سعر الفضة",
                                    snapshot: d.silver,
                                    unit: "جنيه",
                                    decimals: 0
                                )
                                InstrumentCard(
                                    title: "الدولار البنكي",
                                    snapshot: d.bankUSD,
                                    unit: "جنيه",
                                    decimals: 2
                                )
                            }

                            // ── فجوة السعر (full width) ─────────────────
                            PriceGapCard(snapshot: d.priceGap)

                            // ── نسبة التغيير / قيمة التغيير ─────────────
                            HStack(spacing: 10) {
                                StatCard(
                                    title: "قيمة التغيير",
                                    value: "\(d.gold24.change >= 0 ? "" : "-")\(abs(d.gold24.change).formatPrice(decimals: 0)) جنيه",
                                    valueColor: d.gold24.isPositive ? .white : .white
                                )
                                StatCard(
                                    title: "نسبة التغيير",
                                    value: d.gold24.changePct.formatPct(),
                                    valueColor: d.gold24.isPositive ? Color(hex: "2ECC71") : Color(hex: "E74C3C")
                                )
                            }

                            // ── أعلى سعر / أقل سعر ──────────────────────
                            HStack(spacing: 10) {
                                StatCard(
                                    title: "أعلى سعر",
                                    value: "\(d.highPrice.formatPrice()) جنيه",
                                    valueColor: .white
                                )
                                StatCard(
                                    title: "أقل سعر",
                                    value: "\(d.lowPrice.formatPrice()) جنيه",
                                    valueColor: .white
                                )
                            }

                            // ── Market Status Buttons ────────────────────
                            VStack(spacing: 10) {
                                MarketStatusButton(
                                    title: "حالة سوق الذهب",
                                    isUp: d.goldMarketUp,
                                    action: {}
                                )
                                MarketStatusButton(
                                    title: "حالة سوق الدولار",
                                    isUp: d.dollarMarketUp,
                                    action: {}
                                )
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task { provider.load(period: selectedPeriod) }
    }
}



struct TACircleIcon: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 20))
            //.foregroundColor(.black)
            .frame(width: 36, height: 36)
           // .background(Color.black.opacity(0.15))
            .clipShape(Circle())
    }
}

// MARK: - Period Tab Bar

struct PeriodTabBar: View {
    @Binding var selected: TAPeriod

    // Note: eDahab shows أمس on the RIGHT (RTL order)
    // CaseIterable gives: yesterday, week, month, year → RTL renders right→left
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TAPeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) { selected = period }
                }) {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selected == period ? .black : Color(hex: "B0AAAA"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            selected == period
                                ? Capsule().fill(Color(hex: "EFC874"))
                                : Capsule().fill(Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color(hex: "231918"))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color(hex: "E8B138").opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(25)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(hex: "181111"))
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Corner Radius extension

extension View {
    func cornerRadius(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Preview

#Preview {
    TechnicalAnalysisView()
}
