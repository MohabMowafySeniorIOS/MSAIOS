//
//   Background.swift
//  MSA
//
//  Created by Mohab Mowafy on 03/06/2026.
//

import SwiftUI

// MARK: - Data

/// كل الأرقام اللي شاشة "الفجوة السعرية" محتاجاها، محسوبة زي ما هي بالظبط في
/// Android (PriceGapDetailsViewModel):
///
///   gaugeValue = (worldPerGramUsd * dollarBank) − gold24LocalEgp
///   gap24 = |gold24LocalEgp − (worldPerGramUsd * dollarBank)|
///   gap21 = |gold21LocalEgp − (worldPerGramUsd * 21/24 * dollarBank)|
struct PriceGapData {
    var worldPerGramUsd: Double = 0.0
    var gold24LocalEgp: Double = 0.0
    var dollarSagha: Double = 0.0
    var dollarBank: Double = 0.0
    var gaugeValue: Double = 0.0
    var gap24Abs: Double = 0.0
    var gap24IsNegative: Bool = false
    var gap21Abs: Double = 0.0
    var gap21IsNegative: Bool = false
}

// MARK: - Main View
struct PriceGapView: View {
    var data: PriceGapData
    /// بيتنادى لما المستخدم يدوس على زر الرجوع. الشاشة دي بتتعمللها push على
    /// UINavigationController من UIKit (مش NavigationStack)، فـ
    /// @Environment(\.dismiss) لوحده مش هيقفلها؛ من هنا onBack بيسمح لـ
    /// HomeVC إنها تعمل popViewController فعليًا. لو مفيش onBack بتستخدم
    /// dismiss() العادي كـ fallback.
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    var body: some View {

        VStack(spacing: 0) {
            // Header
            headerView(title: "Price gap".localized, isBackShow: true,onDismiss: {
                if let onBack {
                    onBack()
                } else {
                    dismiss()
                }
            })


            // Content
            ScrollView {
                VStack(spacing: 16) {
                    // Gauge Card
                    PriceGaugeView(value: data.gaugeValue)

                    // Price Details Card
                    PriceDetailsCard(data: data)

                    // Gap Details Card
                    GapDetailsCard(data: data)

                    // Info Text Card
                    InfoTextCard()

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }


        }
        .background(
            BGSwiftUIView()
        )
        .ignoresSafeArea(edges: .bottom)



    }
}



// MARK: - Custom Gauge
struct GaugeView: View {
    let value: Double
    
    // Gauge goes from -100 to 100, but needle can go beyond
    let minValue: Double = -100
    let maxValue: Double = 100
    
    var needleAngle: Double {
        // Map value to angle: -100 → -135°, 0 → 0°(top), 100 → +135°
        // But since value is 130.66 (beyond 100), clamp visually past 100
        let clampedValue = min(max(value, maxValue), minValue)
        let normalized = (clampedValue - 0) / (minValue - maxValue) * 2  // -1 to +1 range
        return (clampedValue / maxValue) * 135
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height * 1.8)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.88)
            let radius = size * 0.42
            
            ZStack {
                // Colored arc
                GaugeArc(center: center, radius: radius, lineWidth: 28)
                
                // Tick marks and labels
                GaugeLabels(center: center, radius: radius)
                
                // Center dot
                Circle()
                    .fill(Color(hex: "C9A84C"))
                    .frame(width: 18, height: 18)
                    .position(center)
                
                // Needle
                NeedleShape(angle: needleAngle, length: radius * 0.85)
                    .stroke(Color(hex: "C9A84C"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .position(center)
                
                // Top indicator triangle
                Triangle()
                    .fill(Color.green)
                    .frame(width: 12, height: 10)
                    .position(x: center.x, y: center.y - radius - 20)
            }
        }
    }
}

struct GaugeArc: View {
    let center: CGPoint
    let radius: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        Canvas { context, size in
            // Arc from -135° to +135° (270° total)
            let startAngle = Angle(degrees: 180 + 45) // 225°
            let endAngle = Angle(degrees: 360 - 45)   // 315° going the other way
            
            // Draw gradient arc in segments
            let segments = 100
            let totalAngle: Double = 270
            let startDeg: Double = 225
            
            for i in 0..<segments {
                let t = Double(i) / Double(segments)
                let t1 = Double(i + 1) / Double(segments)
                
                let a1 = startDeg + t * totalAngle
                let a2 = startDeg + t1 * totalAngle
                
                var path = Path()
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(a1),
                    endAngle: .degrees(a2),
                    clockwise: false
                )
                
                // Color: green (left) → yellow (center) → red (right)
                let color: Color
                if t < 0.5 {
                    // green to yellow
                    let blend = t * 2
                    color = Color(
                        red: blend * 0.9,
                        green: 0.85 - blend * 0.15,
                        blue: 0.0
                    )
                } else {
                    // yellow to red
                    let blend = (t - 0.5) * 2
                    color = Color(
                        red: 0.9,
                        green: 0.7 - blend * 0.7,
                        blue: 0.0
                    )
                }
                
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
            }
        }
    }
}

struct GaugeLabels: View {
    let center: CGPoint
    let radius: CGFloat
    
    let labels: [(value: String, position: Double)] = [
        ("-100", -135), ("-80", -108), ("-60", -81), ("-40", -54),
        ("-20", -27), ("0", 0), ("20", 27), ("40", 54),
        ("60", 81), ("80", 108), ("100", 135)
    ]
    
    var body: some View {
        Canvas { context, size in
            let labelRadius = radius * 1.22
            
            for item in labels {
                let angleDeg = item.position - 90  // rotate so 0 is at top
                let angleRad = angleDeg * .pi / 180
                
                let x = center.x + labelRadius * CGFloat(cos(angleRad))
                let y = center.y + labelRadius * CGFloat(sin(angleRad))
                
                // All labels use the same font size
                let fontSize: CGFloat = 10
                
                var attributedString = AttributedString(item.value)
                attributedString.font = .systemFont(ofSize: fontSize, weight: .medium)
                attributedString.foregroundColor = .white.opacity(0.85)
                
                context.draw(
                    Text(attributedString),
                    at: CGPoint(x: x, y: y)
                )
            }
            
            // Tick marks
            for item in labels {
                let angleDeg = item.position - 90
                let angleRad = angleDeg * .pi / 180
                
                let innerR = radius * 1.05
                let outerR = radius * 1.12
                
                let x1 = center.x + innerR * CGFloat(cos(angleRad))
                let y1 = center.y + innerR * CGFloat(sin(angleRad))
                let x2 = center.x + outerR * CGFloat(cos(angleRad))
                let y2 = center.y + outerR * CGFloat(sin(angleRad))
                
                var path = Path()
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y2))
                context.stroke(path, with: .color(.white.opacity(0.6)), lineWidth: 1.5)
            }
        }
    }
}

struct NeedleShape: Shape {
    let angle: Double
    let length: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radians = (angle - 90) * .pi / 180
        path.move(to: .zero)
        path.addLine(to: CGPoint(
            x: length * CGFloat(cos(radians)),
            y: length * CGFloat(sin(radians))
        ))
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Price Details Card
struct PriceDetailsCard: View {
    var data: PriceGapData

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("تفاصيل الأسعار")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "C9A84C"))
                .padding(.vertical, 10)

            Divider().background(Color(hex: "3A3A3A"))

            VStack(spacing: 0) {
                PriceRows(label: "سعر الجرام عيار 24 عالميا:", value: String(format: "%.2f USD", data.worldPerGramUsd), valueColor: .white)
                Divider().background(Color(hex: "3A3A3A")).padding(.horizontal, 16)
                PriceRows(label: "سعر الجرام عيار 24 محليا:", value: String(format: "%.0f جنيه", data.gold24LocalEgp), valueColor: .white)
                Divider().background(Color(hex: "3A3A3A")).padding(.horizontal, 16)
                PriceRows(label: "الذهب محسوب بسعر الدولار:", value: String(format: "%.2f جنيه", data.dollarSagha), valueColor: .white)
                Divider().background(Color(hex: "3A3A3A")).padding(.horizontal, 16)
                PriceRows(label: "سعر الدولار الرسمي:", value: String(format: "%.2f جنيه", data.dollarBank), valueColor: .white)
            }
        }
        .background(Color(hex: "2A2A2A"))
        .cornerRadius(12)
    }
}

struct PriceRows: View {
    let label: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(valueColor)
            
            Spacer()
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "AAAAAA"))
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Gap Details Card
struct GapDetailsCard: View {
    var data: PriceGapData

    /// أخضر لما السعر المحلي أعلى من العالمي (فجوة موجبة)، أحمر لما يكون
    /// أقل (فجوة سالبة) - زي Android بالظبط.
    private func gapColor(isNegative: Bool) -> Color {
        isNegative ? Color(hex: "E53935") : Color(hex: "00C853")
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("تفاصيل الفجوة السعرية")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "C9A84C"))
                .padding(.vertical, 10)

            Divider().background(Color(hex: "3A3A3A"))

            VStack(spacing: 0) {
                PriceRows(
                    label: "الفجوة في عيار 24",
                    value: String(format: "%.0f جنيه مصري", data.gap24Abs),
                    valueColor: gapColor(isNegative: data.gap24IsNegative)
                )
                Divider().background(Color(hex: "3A3A3A")).padding(.horizontal, 16)
                PriceRows(
                    label: "الفجوة في عيار 21",
                    value: String(format: "%.0f جنيه مصري", data.gap21Abs),
                    valueColor: gapColor(isNegative: data.gap21IsNegative)
                )
            }
        }
        .background(Color(hex: "2A2A2A"))
        .cornerRadius(12)
    }
}

// MARK: - Info Text Card
struct InfoTextCard: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("الفجوة السعرية في سعر الذهب في مصر")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            
            Text("تشير إلى الفرق بين السعر المحلي (كما يُعلن في محلات الذهب أو الصاغة) والسعر العالمي المحوّل للجنيه المصري...")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "AAAAAA"))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color(hex: "2A2A2A"))
        .cornerRadius(12)
        .environment(\.layoutDirection, .rightToLeft)
    }
}



struct PriceGaugeView: View {
    var value: Double

    var body: some View {
        ZStack {
          //  Color(hex: "1C1C1E").ignoresSafeArea()

            VStack(spacing: 0) {
                GaugeDial(value: value)
                    .frame(width: 200, height: 200)
                    .padding(.top, 30)

                Text(String(format: "%.0f", value))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "E53935"))
                    .padding(.top, 8)

                Text("جنيه مصري")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "E53935"))
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Dial

struct GaugeDial: View {
    var value: Double

    private let minVal: Double = -100
    private let maxVal: Double = 100

    // total sweep: 240°, from 150° to 390° (clockwise)
    // 0 is at the top (270°). Reversed for our Arabic/RTL-only audience:
    // +100 sits at 150° (left) and -100 at 390° (right) — the mirror image
    // of a standard LTR gauge.
    private let startAngle: Double = 150
    private let endAngle:   Double = 390   // = 150 + 240
    private let totalSpan:  Double = 240

    private var needleAngle: Double {
        let clamped = min(max(value, minVal), maxVal)
        let t = (clamped - minVal) / (maxVal - minVal)
        return startAngle + (1 - t) * totalSpan
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width  / 2
            let cy = geo.size.height * 0.82
            let R  = min(geo.size.width, geo.size.height) * 0.72

            ZStack {
                // ── 1. Colored arc (gradient segments) ──────────────────
                ForEach(0..<240, id: \.self) { i in
                    let t = Double(i) / 240.0
                    let angle = startAngle + Double(i)
                    ArcSegment(
                        center: CGPoint(x: cx, y: cy),
                        radius: R,
                        lineWidth: 26,
                        startDeg: angle,
                        endDeg: angle + 1.1
                    )
                    .stroke(arcColor(t: 1 - t), lineWidth: 26)      // reversed for RTL
                }

                // ── 2. Tick marks + labels ───────────────────────────────
                let tickValues: [(val: Double, label: String)] = [
                    (-100, "-100"), (-80, "-80"), (-60, "-60"),
                    (-40, "-40"),  (-20, "-20"), (0, "0"),
                    (20, "20"),   (40, "40"),   (60, "60"),
                    (80, "80"),   (100, "100")
                ]

                ForEach(tickValues, id: \.val) { item in
                    let t      = (item.val - minVal) / (maxVal - minVal)
                    let deg    = startAngle + (1 - t) * totalSpan     // reversed for RTL
                    let radInner = (R + 16) * CGFloat(1)
                    let radOuter = (R + 26) * CGFloat(1)
                    let radLabel = (R + 42) * CGFloat(1)

                    // tick
                    let ix = cx + radInner * CGFloat(cos(deg * .pi / 180))
                    let iy = cy + radInner * CGFloat(sin(deg * .pi / 180))
                    let ox = cx + radOuter * CGFloat(cos(deg * .pi / 180))
                    let oy = cy + radOuter * CGFloat(sin(deg * .pi / 180))
                    Path { p in
                        p.move(to: CGPoint(x: ix, y: iy))
                        p.addLine(to: CGPoint(x: ox, y: oy))
                    }
                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)

                    // label
                    let lx = cx + radLabel * CGFloat(cos(deg * .pi / 180))
                    let ly = cy + radLabel * CGFloat(sin(deg * .pi / 180))
                    Text(item.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .position(x: lx, y: ly)
                }

                // ── 3. Needle ────────────────────────────────────────────
                let nRad = needleAngle * .pi / 180
                let tipX = cx + (R - 14) * CGFloat(cos(nRad))
                let tipY = cy + (R - 14) * CGFloat(sin(nRad))

                // needle body
                Path { p in
                    p.move(to: CGPoint(x: cx, y: cy))
                    p.addLine(to: CGPoint(x: tipX, y: tipY))
                }
                .stroke(
                    Color(hex: "C9A84C"),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )

                // center pivot
                Circle()
                    .fill(Color(hex: "C9A84C"))
                    .frame(width: 16, height: 16)
                    .position(x: cx, y: cy)

                // ── 4. Top indicator triangle ─────────────────────────────
                // at angle = 270° (top of arc = value 0)
                let zeroT   = (0.0 - minVal) / (maxVal - minVal)
                let zeroDeg = startAngle + zeroT * totalSpan   // 270
                let triRad  = R - 3
                let triX    = cx + triRad * CGFloat(cos(zeroDeg * .pi / 180))
                let triY    = cy + triRad * CGFloat(sin(zeroDeg * .pi / 180))

                TriangleShape()
                    .fill(Color.green)
                    .frame(width: 12, height: 10)
                    .rotationEffect(.degrees(zeroDeg + 90))
                    .position(x: triX, y: triY)
            }
        }
    }

    // Green → Yellow → Red across the arc
    private func arcColor(t: Double) -> Color {
        if t < 0.5 {
            let b = t * 2          // 0→1
            return Color(red: b * 0.92, green: 0.85, blue: 0.08 * (1 - b))
        } else {
            let b = (t - 0.5) * 2  // 0→1
            return Color(red: 0.92, green: 0.85 * (1 - b), blue: 0)
        }
    }
}

// MARK: - Triangle

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Arc Segment Shape

struct ArcSegment: Shape {
    var center: CGPoint
    var radius: CGFloat
    var lineWidth: CGFloat
    var startDeg: Double
    var endDeg: Double

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startDeg),
            endAngle: .degrees(endDeg),
            clockwise: false
        )
        return p
    }
}


