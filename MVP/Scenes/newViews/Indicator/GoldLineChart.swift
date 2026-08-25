//
//  GoldLineChart.swift
//  MSA
//
//  Created by Mohab Mowafy on 04/06/2026.
//

import SwiftUI

// MARK: - Gold Line Chart (matches eDahab style exactly)

struct GoldLineChart: View {
    let dataSet: ChartDataSet
    @State private var touchX: CGFloat? = nil
    @State private var touchPoint: PricePoint? = nil

    private let lineColor   = Color(hex: "E8D5A0")    // cream/gold line
    private let gridColor   = Color.white.opacity(0.07)
    private let labelColor  = Color(hex: "C9A84C")
    private let bgColor     = Color(hex: "1A1A1A")

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Title
            Text(dataSet.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "E8D5A0"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let pts = dataSet.points
                guard pts.count > 1 else { return AnyView(EmptyView()) }

                let minV = dataSet.minValue
                let maxV = dataSet.maxValue
                let range = maxV - minV == 0 ? 1 : maxV - minV

                // Y-axis labels (left side)
                let yLabels = makeYLabels(min: minV, max: maxV, count: 7)
                let leftPad: CGFloat  = 50
                let rightPad: CGFloat = 8
                let topPad: CGFloat   = 8
                let botPad: CGFloat   = 28

                let chartW = w - leftPad - rightPad
                let chartH = h - topPad - botPad

                return AnyView(
                    ZStack(alignment: .topLeading) {
                        // Background
                        bgColor

                        // Grid lines + Y labels
                        ForEach(yLabels, id: \.self) { label in
                            let yFrac = CGFloat((label - minV) / range)
                            let y = topPad + chartH - (yFrac * chartH)

                            // Grid line
                            Path { p in
                                p.move(to: CGPoint(x: leftPad, y: y))
                                p.addLine(to: CGPoint(x: w - rightPad, y: y))
                            }
                            .stroke(gridColor, lineWidth: 0.5)

                            // Y label
                            Text(formatLabel(label))
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: leftPad - 4, alignment: .trailing)
                                .position(x: (leftPad - 4) / 2, y: y)
                        }

                        // X-axis labels
                        let xLabels = makeXLabels(points: pts, count: 7)
                        ForEach(xLabels.indices, id: \.self) { i in
                            let (date, idx) = xLabels[i]
                            let xFrac = CGFloat(idx) / CGFloat(pts.count - 1)
                            let x = leftPad + xFrac * chartW
                            Text(formatDate(date, period: guessPeriod(pts)))
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: 40, alignment: .center)
                                .position(x: x, y: h - botPad / 2 - 4)
                        }

                        // Chart line
                        Path { path in
                            for (i, pt) in pts.enumerated() {
                                let xFrac = CGFloat(i) / CGFloat(pts.count - 1)
                                let yFrac = CGFloat((pt.value - minV) / range)
                                let x = leftPad + xFrac * chartW
                                let y = topPad + chartH - yFrac * chartH
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else       { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(lineColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                        .clipShape(Rectangle().offset(x: leftPad).size(width: chartW + 1, height: h))

                        // Touch indicator
                        if let tx = touchX, let tp = touchPoint {
                            let i = pts.firstIndex(where: { $0.id == tp.id }) ?? 0
                            let xFrac = CGFloat(i) / CGFloat(pts.count - 1)
                            let yFrac = CGFloat((tp.value - minV) / range)
                            let x = leftPad + xFrac * chartW
                            let y = topPad + chartH - yFrac * chartH

                            // Vertical line
                            Path { p in
                                p.move(to: CGPoint(x: x, y: topPad))
                                p.addLine(to: CGPoint(x: x, y: h - botPad))
                            }
                            .stroke(Color(hex: "C9A84C").opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                            // Dot
                            Circle()
                                .fill(Color(hex: "C9A84C"))
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)

                            // Value bubble
                            Text(formatValue(tp.value))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "C9A84C"))
                                .cornerRadius(6)
                                .position(x: min(max(x, 60), w - 60), y: y - 22)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { val in
                                let leftPad: CGFloat = 50
                                let rightPad: CGFloat = 8
                                let chartW = geo.size.width - leftPad - rightPad
                                let relX = val.location.x - leftPad
                                let t = max(0, min(1, relX / chartW))
                                let idx = Int(t * CGFloat(pts.count - 1))
                                touchX = val.location.x
                                touchPoint = pts[idx]
                            }
                            .onEnded { _ in
                                touchX = nil
                                touchPoint = nil
                            }
                    )
                )
            }
            .frame(height: 220)
        }
        .background(Color(hex: "222222"))
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func makeYLabels(min: Double, max: Double, count: Int) -> [Double] {
        let step = (max - min) / Double(count - 1)
        return (0..<count).map { min + step * Double($0) }
    }

    private func makeXLabels(points: [PricePoint], count: Int) -> [(Date, Int)] {
        guard points.count > 1 else { return [] }
        let step = max(1, points.count / count)
        return stride(from: 0, to: points.count, by: step).map { (points[$0].date, $0) }
    }

    private func guessPeriod(_ pts: [PricePoint]) -> TimePeriod {
        guard pts.count > 1 else { return .h24 }
        let span = pts.last!.date.timeIntervalSince(pts.first!.date) / 86400
        switch span {
        case ..<2:    return .h24
        case ..<8:    return .week
        case ..<32:   return .month
        case ..<92:   return .months3
        case ..<182:  return .months6
        case ..<270:  return .months9
        case ..<400:  return .year1
        case ..<740:  return .years2
        default:      return .years3
        }
    }

    private func formatDate(_ date: Date, period: TimePeriod) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ar_EG")
        switch period {
        case .h24:              df.dateFormat = "HH:mm"
        case .week, .month:     df.dateFormat = "d/M"
        case .months3, .months6, .months9, .year1: df.dateFormat = "MMM"
        case .years2, .years3:  df.dateFormat = "yyyy"
        }
        return df.string(from: date)
    }

    private func formatLabel(_ val: Double) -> String {
        if val >= 1000 { return String(format: "%.0f", val) }
        if val >= 100  { return String(format: "%.1f", val) }
        return String(format: "%.2f", val)
    }

    private func formatValue(_ val: Double) -> String {
        if val >= 1000 { return String(format: "%.0f", val) }
        return String(format: "%.2f", val)
    }
}
