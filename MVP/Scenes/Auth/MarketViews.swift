//
//  MarketViews.swift
//  MSA
//
//  المؤشرات والتحليل الفني — بيانات حيّة من تريدنج فيو.
//
//  قبل كده الشاشتين كانوا بيعرضوا أرقام مولّدة محلياً ومكتوبة ثابتة،
//  يعني مكانوش بيعبّروا عن السوق.
//

import SwiftUI

/// المؤشرات — رسم بياني حيّ
struct IndicatorsMarketView: View {

    var onBack: (() -> Void)?
    @State private var isGold = true

    var body: some View {
        MarketScaffold(
            titleKey: "indicators",
            noteKey: "market_global_note",
            widget: .chart,
            isGold: $isGold,
            onBack: onBack
        )
    }
}

/// التحليل الفني — تقييم حيّ (المتوسطات والمذبذبات)
struct TechnicalAnalysisMarketView: View {

    var onBack: (() -> Void)?
    @State private var isGold = true

    var body: some View {
        MarketScaffold(
            titleKey: "technical_analysis",
            noteKey: "ta_disclaimer",
            widget: .analysis,
            isGold: $isGold,
            onBack: onBack
        )
    }
}

/// الهيكل المشترك للشاشتين — نفس الترتيب في الأندرويد
private struct MarketScaffold: View {

    let titleKey: String
    let noteKey: String
    let widget: TVWidgetKind
    @Binding var isGold: Bool
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            BGSwiftUIView()

            VStack(spacing: 0) {
                headerView(title: titleKey.localized, isBackShow: true) { onBack?() }

                metalToggle
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                TradingViewPanel(
                    widget: widget,
                    symbol: isGold ? TVSymbol.gold : TVSymbol.silver
                )
                .padding(.top, 10)

                Text(noteKey.localized)
                    .font(.msa(11))
                    .foregroundColor(Color(white: 0.62))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var metalToggle: some View {
        HStack(spacing: 10) {
            toggleButton(title: "gold".localized, active: isGold) { isGold = true }
            toggleButton(title: "silver".localized, active: !isGold) { isGold = false }
        }
    }

    private func toggleButton(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.msa(16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(active ? Color("MainColor") : Color.black.opacity(0.35))
                .foregroundColor(active ? Color(red: 0.247, green: 0.176, blue: 0.173) : .white)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(active ? .clear : Color("MainColor").opacity(0.4), lineWidth: 1)
                )
        }
    }
}
