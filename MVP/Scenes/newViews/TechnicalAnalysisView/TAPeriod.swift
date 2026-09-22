//
//  TAPeriod.swift
//  MSA
//
//  Created by Mohab Mowafy on 04/06/2026.
//

import Foundation

// MARK: - Period

enum TAPeriod: String, CaseIterable {
    case yesterday = "أمس"
    case week      = "أسبوع"
    case month     = "شهر"
    case year      = "سنة"
}

// MARK: - Price Snapshot

struct PriceSnapshot {
    let open:  Double
    let close: Double

    var change: Double    { close - open }
    var changePct: Double { open == 0 ? 0 : (close - open) / open * 100 }
    var isPositive: Bool  { change >= 0 }
}

// MARK: - Full Analysis Result

struct TechnicalAnalysisData {
    let period: TAPeriod
    let startDate: Date
    let endDate: Date

    let gold21:     PriceSnapshot
    let gold24:     PriceSnapshot
    let goldUSD:    PriceSnapshot
    let jewelryUSD: PriceSnapshot
    let silver:     PriceSnapshot
    let bankUSD:    PriceSnapshot
    let priceGap:   PriceSnapshot

    var highPrice: Double
    var lowPrice:  Double

    var goldMarketUp:   Bool { gold24.isPositive }
    var dollarMarketUp: Bool { bankUSD.isPositive }
}

// MARK: - Data Provider

class TechnicalAnalysisProvider: ObservableObject {
    @Published var data: TechnicalAnalysisData?
    @Published var isLoading = false

    static let shared = TechnicalAnalysisProvider()

    func load(period: TAPeriod) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.data = Self.buildData(for: period)
            self.isLoading = false
        }
    }

    static func buildData(for period: TAPeriod) -> TechnicalAnalysisData {
        let cal = Calendar.current
        let now = Date()

        let (startDate, endDate): (Date, Date) = {
            switch period {
            case .yesterday:
                let y = cal.date(byAdding: .day, value: -1, to: now)!
                return (cal.startOfDay(for: y),
                        cal.date(byAdding: .second, value: 86399, to: cal.startOfDay(for: y))!)
            case .week:
                return (cal.date(byAdding: .day, value: -7, to: now)!, now)
            case .month:
                return (cal.date(byAdding: .month, value: -1, to: now)!, now)
            case .year:
                return (cal.date(byAdding: .year, value: -1, to: now)!, now)
            }
        }()

        switch period {
        case .yesterday:
            return TechnicalAnalysisData(
                period: period, startDate: startDate, endDate: endDate,
                gold21:     PriceSnapshot(open: 6655,   close: 6600),
                gold24:     PriceSnapshot(open: 7606,   close: 7543),
                goldUSD:    PriceSnapshot(open: 4488,   close: 4431.8),
                jewelryUSD: PriceSnapshot(open: 52.71,  close: 52.93),
                silver:     PriceSnapshot(open: 131,    close: 129),
                bankUSD:    PriceSnapshot(open: 51.83,  close: 51.88),
                priceGap:   PriceSnapshot(open: 126.48, close: 150.02),
                highPrice: 7606, lowPrice: 7537
            )
        case .week:
            return TechnicalAnalysisData(
                period: period, startDate: startDate, endDate: endDate,
                gold21:     PriceSnapshot(open: 6710,   close: 6610),
                gold24:     PriceSnapshot(open: 7669,   close: 7554),
                goldUSD:    PriceSnapshot(open: 4393.6, close: 4470.6),
                jewelryUSD: PriceSnapshot(open: 54.28,  close: 52.55),
                silver:     PriceSnapshot(open: 132,    close: 129),
                bankUSD:    PriceSnapshot(open: 52.23,  close: 51.88),
                priceGap:   PriceSnapshot(open: 290.29, close: 96.29),
                highPrice: 7766, lowPrice: 7537
            )
        case .month:
            return TechnicalAnalysisData(
                period: period, startDate: startDate, endDate: endDate,
                gold21:     PriceSnapshot(open: 6905,   close: 6610),
                gold24:     PriceSnapshot(open: 7891,   close: 7554),
                goldUSD:    PriceSnapshot(open: 4556.6, close: 4470.6),
                jewelryUSD: PriceSnapshot(open: 53.86,  close: 52.55),
                silver:     PriceSnapshot(open: 127,    close: 129),
                bankUSD:    PriceSnapshot(open: 53.75,  close: 51.88),
                priceGap:   PriceSnapshot(open: 15.85,  close: 96.29),
                highPrice: 8057, lowPrice: 7537
            )
        case .year:
            return TechnicalAnalysisData(
                period: period, startDate: startDate, endDate: endDate,
                gold21:     PriceSnapshot(open: 4705,   close: 6615),
                gold24:     PriceSnapshot(open: 5377,   close: 7560),
                goldUSD:    PriceSnapshot(open: 3363,   close: 4470.6),
                jewelryUSD: PriceSnapshot(open: 49.72,  close: 52.59),
                silver:     PriceSnapshot(open: 58.1,   close: 129),
                bankUSD:    PriceSnapshot(open: 49.73,  close: 51.94),
                priceGap:   PriceSnapshot(open: -0.56,  close: 93.67),
                highPrice: 8686, lowPrice: 5160
            )
        }
    }
}

// MARK: - Formatters

extension Double {
    func formatPrice(decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    func formatPct() -> String {
        let sign = self >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, self)
    }
}

extension Date {
    func toDisplayString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df.string(from: self)
    }
}
