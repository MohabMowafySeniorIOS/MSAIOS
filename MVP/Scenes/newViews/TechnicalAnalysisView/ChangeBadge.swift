//
//  ChangeBadge.swift
//  MSA
//
//  Created by Mohab Mowafy on 04/06/2026.
//

import SwiftUI



// MARK: - Change Badge (the green/red pill with %)

struct ChangeBadge: View {
    let pct: Double
    let fontSize: CGFloat

    private var isPositive: Bool { pct >= 0 }
    private var bgColor: Color   { isPositive ? .green : .red }
    private var fgColor: Color   { isPositive ? .green  : .red }

    var body: some View {
        Text(pct.formatPct())
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(fgColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(bgColor)
            .cornerRadius(20)
    }
}

// MARK: - Instrument Card (ذهب 21، ذهب 24، etc.)

struct InstrumentCard: View {
    let title:    String
    let snapshot: PriceSnapshot
    let unit:     String   // "جنيه" or "دولار"
    let decimals: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.MainColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider().background(Color(hex: "3A3A3A"))

            HStack {
                Text("\(snapshot.open.formatPrice(decimals: decimals)) \(unit)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("افتتاح")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
            }

            HStack {
                Text("\(snapshot.close.formatPrice(decimals: decimals)) \(unit)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("إغلاق")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
            }

            ChangeBadge(pct: snapshot.changePct, fontSize: 13)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)
        }
        .padding(12)
        .background(BGSwiftUIView())
        .cornerRadius(12)
    }
}

// MARK: - Gap Card (فجوة السعر)

struct PriceGapCard: View {
    let snapshot: PriceSnapshot

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("فجوة السعر")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.MainColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider().background(Color(hex: "3A3A3A"))

            HStack {
                Text("\(snapshot.open.formatPrice(decimals: 2)) جنيه")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("افتتاح")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
            }

            HStack {
                Text("\(snapshot.close.formatPrice(decimals: 2)) جنيه")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("إغلاق")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
            }

            ChangeBadge(pct: snapshot.changePct, fontSize: 13)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)
        }
        .padding(12)
        .background(BGSwiftUIView())
        .cornerRadius(12)
    }
}

// MARK: - Stat Card (نسبة التغيير / قيمة التغيير / أعلى سعر / أقل سعر)

struct StatCard: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "AAAAAA"))
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(valueColor)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(BGSwiftUIView())
        .cornerRadius(12)
    }
}

// MARK: - Market Status Button (حالة سوق الذهب / الدولار)

struct MarketStatusButton: View {
    let title: String
    let isUp: Bool
    let action: () -> Void

    private var borderColor: Color { isUp ? Color(hex: "1E7A3E") : Color(hex: "8B1A1A") }
    private var iconColor:   Color { isUp ? Color(hex: "2ECC71")  : Color(hex: "E74C3C") }
    private var arrowIcon:   String { isUp ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis" }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: arrowIcon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(hex: "1A1A1A"))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .cornerRadius(25)
        }
    }
}

// MARK: - Period Date Card

struct PeriodDateCard: View {
    let startDate: Date
    let endDate:   Date
    let onCalendarTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(Color.MainColor)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("الفترة")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.MainColor)

                Text("\(endDate.toDisplayString()) - \(startDate.toDisplayString())")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(BGSwiftUIView())
        .cornerRadius(12)
    }
}

// MARK: - Simple Close-Only Card (for the top 2 cards - silver & bankUSD in compact view)

struct SimpleCloseCard: View {
    let closeValue: String
    let pct: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(closeValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("إغلاق")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
            }
            ChangeBadge(pct: pct, fontSize: 13)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .background(BGSwiftUIView())
        .cornerRadius(12)
    }
}


