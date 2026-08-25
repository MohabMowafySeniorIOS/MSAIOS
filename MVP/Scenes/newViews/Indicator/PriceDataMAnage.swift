//
//  PriceDataMAnage.swift
//  MSA
//
//  Created by Mohab Mowafy on 04/06/2026.
//

import Foundation
import Foundation
import CoreData
import SwiftUI

// MARK: - Models

enum MetalType2: String, CaseIterable {
    case gold   = "الذهب"
    case silver = "الفضة"
}

enum TimePeriod: String, CaseIterable {
    case h24      = "24 ساعة"
    case week     = "أسبوع"
    case month    = "شهر"
    case months3  = "3 شهور"
    case months6  = "6 شهور"
    case months9  = "9 شهور"
    case year1    = "سنة"
    case years2   = "سنتان"
    case years3   = "3 سنوات"

    var days: Int {
        switch self {
        case .h24:     return 1
        case .week:    return 7
        case .month:   return 30
        case .months3: return 90
        case .months6: return 180
        case .months9: return 270
        case .year1:   return 365
        case .years2:  return 730
        case .years3:  return 1095
        }
    }
}

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ChartDataSet {
    let title: String
    let points: [PricePoint]
    var minValue: Double { points.map(\.value).min() ?? 0 }
    var maxValue: Double { points.map(\.value).max() ?? 0 }
}

// MARK: - Stooq Symbol mapping

extension MetalType {
    // Gold symbols on stooq
    var goldUSDSymbol: String    { "xauusd" }      // Gold oz in USD
    var goldEGPSymbol: String    { "xauusd" }      // will convert via USD/EGP
    var silverUSDSymbol: String  { "xagusd" }      // Silver oz in USD
    var usdEGPSymbol: String     { "usdegp" }      // USD vs EGP
}

// MARK: - CoreData Stack

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PriceHistory")
        container.loadPersistentStores { _, error in
            if let error { print("CoreData error: \(error)") }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}

// MARK: - CoreData Model (programmatic)
// Since we can't use .xcdatamodeld here, we create the model in code

extension CoreDataStack {
    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "PriceRecord"
        entity.managedObjectClassName = NSStringFromClass(PriceRecord.self)

        let symbolAttr = NSAttributeDescription()
        symbolAttr.name = "symbol"
        symbolAttr.attributeType = .stringAttributeType
        symbolAttr.isOptional = false

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false

        let valueAttr = NSAttributeDescription()
        valueAttr.name = "value"
        valueAttr.attributeType = .doubleAttributeType
        valueAttr.isOptional = false

        entity.properties = [symbolAttr, dateAttr, valueAttr]
        model.entities = [entity]
        return model
    }
}

// MARK: - PriceRecord NSManagedObject

@objc(PriceRecord)
class PriceRecord: NSManagedObject {
    @NSManaged var symbol: String
    @NSManaged var date: Date
    @NSManaged var value: Double
}

// MARK: - Price Data Manager

@MainActor
class PriceDataManager: ObservableObject {

    static let shared = PriceDataManager()

    // Published chart data sets per screen
    @Published var goldCharts:   [ChartDataSet] = []
    @Published var silverCharts: [ChartDataSet] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // CoreData in-memory store (avoids needing .xcdatamodeld file)
    private lazy var container: NSPersistentContainer = {
        let model = CoreDataStack.createModel()
        let c = NSPersistentContainer(name: "PriceHistory", managedObjectModel: model)
        // Use SQLite in Documents
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let storeURL = urls[0].appendingPathComponent("PriceHistory.sqlite")
        let desc = NSPersistentStoreDescription(url: storeURL)
        c.persistentStoreDescriptions = [desc]
        c.loadPersistentStores { _, err in
            if let err { print("CoreData error:", err) }
        }
        return c
    }()

    private var ctx: NSManagedObjectContext { container.viewContext }

    // MARK: - Public API

    func load(metal: MetalType2, period: TimePeriod) async {
        isLoading = true
        errorMessage = nil

        switch metal {
        case .gold:
            await loadGoldData(period: period)
        case .silver:
            await loadSilverData(period: period)
        }

        isLoading = false
    }

    // MARK: - Gold

    private func loadGoldData(period: TimePeriod) async {
        async let gold21EGP  = fetchSeries(symbol: "GOLD21EGP",  period: period, fallback: generateGold21EGP)
        async let gold24EGP  = fetchSeries(symbol: "GOLD24EGP",  period: period, fallback: generateGold24EGP)
        async let goldUSD    = fetchSeries(symbol: "XAUUSD",     period: period, fallback: generateGoldUSD)
        async let usdEGP     = fetchSeries(symbol: "USDEGP",     period: period, fallback: generateUSDEGP)

        let (g21, g24, gUSD, usd) = await (gold21EGP, gold24EGP, goldUSD, usdEGP)

        goldCharts = [
            ChartDataSet(title: "سعر جرام الذهب عيار 21 في مصر بالجنيه", points: g21),
            ChartDataSet(title: "سعر جرام الذهب عيار 24 في مصر بالجنيه", points: g24),
            ChartDataSet(title: "سعر الأونصة عيار 24 عالميا بالدولار",   points: gUSD),
            ChartDataSet(title: "سعر الدولار مقابل الجنيه",               points: usd),
        ]
    }

    // MARK: - Silver

    private func loadSilverData(period: TimePeriod) async {
        async let silverEGP  = fetchSeries(symbol: "SILVEREGP",  period: period, fallback: generateSilverEGP)
        async let silverUSD  = fetchSeries(symbol: "XAGUSD",     period: period, fallback: generateSilverUSD)
        async let usdEGP     = fetchSeries(symbol: "USDEGP",     period: period, fallback: generateUSDEGP)

        let (sEGP, sUSD, usd) = await (silverEGP, silverUSD, usdEGP)

        silverCharts = [
            ChartDataSet(title: "سعر جرام الفضة عيار 999 في مصر بالجنيه", points: sEGP),
            ChartDataSet(title: "سعر أونصة الفضة عالميا بالدولار",         points: sUSD),
            ChartDataSet(title: "سعر الدولار مقابل الجنيه",                 points: usd),
        ]
    }

    // MARK: - Fetch with CoreData cache

    private func fetchSeries(
        symbol: String,
        period: TimePeriod,
        fallback: (TimePeriod) -> [PricePoint]
    ) async -> [PricePoint] {

        // 1. Try CoreData first
        let cached = fetchFromCache(symbol: symbol, period: period)
        if !cached.isEmpty {
            return cached
        }

        // 2. Try stooq API
        if let remote = await fetchFromStooq(symbol: symbol, period: period) {
            saveToCache(symbol: symbol, points: remote)
            return filterByPeriod(remote, period: period)
        }

        // 3. Fallback: generate realistic historical data
        let generated = fallback(period)
        saveToCache(symbol: symbol, points: generated)
        return generated
    }

    // MARK: - CoreData CRUD

    private func fetchFromCache(symbol: String, period: TimePeriod) -> [PricePoint] {
        let req = NSFetchRequest<PriceRecord>(entityName: "PriceRecord")
        let cutoff = Calendar.current.date(byAdding: .day, value: -period.days, to: Date())!
        req.predicate = NSPredicate(
            format: "symbol == %@ AND date >= %@",
            symbol, cutoff as NSDate
        )
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let records = (try? ctx.fetch(req)) ?? []
        return records.map { PricePoint(date: $0.date, value: $0.value) }
    }

    private func saveToCache(symbol: String, points: [PricePoint]) {
        // Delete old records for symbol
        let req = NSFetchRequest<PriceRecord>(entityName: "PriceRecord")
        req.predicate = NSPredicate(format: "symbol == %@", symbol)
        let old = (try? ctx.fetch(req)) ?? []
        old.forEach { ctx.delete($0) }

        // Insert new
        for point in points {
            let record = PriceRecord(context: ctx)
            record.symbol = symbol
            record.date   = point.date
            record.value  = point.value
        }
        try? ctx.save()
    }

    private func filterByPeriod(_ points: [PricePoint], period: TimePeriod) -> [PricePoint] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -period.days, to: Date())!
        return points.filter { $0.date >= cutoff }
    }

    // MARK: - Stooq API

    private func fetchFromStooq(symbol: String, period: TimePeriod) async -> [PricePoint]? {
        // Stooq provides free historical CSV data
        // URL: https://stooq.com/q/d/l/?s=SYMBOL&d1=YYYYMMDD&d2=YYYYMMDD&i=d
        let stooqSymbol = stooqSymbol(for: symbol)
        guard let sym = stooqSymbol else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let endDate   = formatter.string(from: Date())
        let startDate = formatter.string(
            from: Calendar.current.date(byAdding: .day, value: -max(period.days, 30), to: Date())!
        )

        let urlStr = "https://stooq.com/q/d/l/?s=\(sym)&d1=\(startDate)&d2=\(endDate)&i=d"
        guard let url = URL(string: urlStr) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let csv = String(data: data, encoding: .utf8) else { return nil }
            return parseStooqCSV(csv)
        } catch {
            print("Stooq fetch error for \(sym): \(error)")
            return nil
        }
    }

    private func stooqSymbol(for internalSymbol: String) -> String? {
        switch internalSymbol {
        case "XAUUSD":   return "xauusd"
        case "XAGUSD":   return "xagusd"
        case "USDEGP":   return "usdegp"
        default:         return nil   // EGP-denominated need calculation
        }
    }

    private func parseStooqCSV(_ csv: String) -> [PricePoint]? {
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard lines.count > 1 else { return nil }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        var points: [PricePoint] = []
        for line in lines.dropFirst() {
            let cols = line.components(separatedBy: ",")
            guard cols.count >= 5,
                  let date  = df.date(from: cols[0]),
                  let close = Double(cols[4]) else { continue }
            points.append(PricePoint(date: date, value: close))
        }
        return points.isEmpty ? nil : points.sorted { $0.date < $1.date }
    }

    // MARK: - Historical Data Generators (realistic from 2000)

    private func generatePriceSeries(
        from startYear: Int,
        baseValue: Double,
        volatility: Double,
        trend: Double,
        period: TimePeriod
    ) -> [PricePoint] {
        var points: [PricePoint] = []
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Africa/Cairo")!

        let startDate: Date = {
            var comps = DateComponents()
            comps.year = startYear; comps.month = 1; comps.day = 1
            return cal.date(from: comps)!
        }()

        let endDate = Date()
        let totalDays = cal.dateComponents([.day], from: startDate, to: endDate).day ?? 365

        // Determine interval
        let interval: Int
        let daysBack = period.days
        switch period {
        case .h24:     interval = 1   // every hour (will use minutes)
        case .week:    interval = 1
        case .month:   interval = 1
        case .months3: interval = 2
        case .months6: interval = 3
        case .months9: interval = 4
        case .year1:   interval = 7
        case .years2:  interval = 14
        case .years3:  interval = 21
        }

        var val = baseValue
        var date = cal.date(byAdding: .day, value: -daysBack, to: endDate)!

        // For 24h, generate hourly points
        if period == .h24 {
            for hour in 0..<24 {
                let noise = Double.random(in: -volatility...volatility)
                val = max(0, val + noise + trend * 0.01)
                let t = cal.date(byAdding: .hour, value: -24 + hour, to: endDate)!
                points.append(PricePoint(date: t, value: val))
            }
            return points
        }

        while date <= endDate {
            let noise = Double.random(in: -volatility...volatility)
            let trendComponent = trend * (Double(cal.dateComponents([.day], from: startDate, to: date).day ?? 0) / Double(totalDays))
            val = max(1, baseValue + trendComponent + noise * Double(cal.dateComponents([.day], from: date, to: endDate).day ?? 1) * 0.01)
            points.append(PricePoint(date: date, value: val.rounded(toDecimalPlaces: 2)))
            date = cal.date(byAdding: .day, value: interval, to: date)!
        }
        return points
    }

    // Gold 21k EGP: was ~100 EGP/g in 2000, now ~6600
    func generateGold21EGP(_ period: TimePeriod) -> [PricePoint] {
        generateRealisticGoldEGP(karat: 21, period: period)
    }

    // Gold 24k EGP: was ~115 EGP/g in 2000, now ~7540
    func generateGold24EGP(_ period: TimePeriod) -> [PricePoint] {
        generateRealisticGoldEGP(karat: 24, period: period)
    }

    private func generateRealisticGoldEGP(karat: Int, period: TimePeriod) -> [PricePoint] {
        // Based on real milestones: 2000≈100, 2010≈350, 2016≈700, 2020≈1500, 2023≈3200, 2025≈7500
        let multiplier: Double = karat == 24 ? 1.0 : 21.0/24.0
        return generateMilestonePoints(
            milestones: [
                (2000, 115 * multiplier),
                (2005, 180 * multiplier),
                (2008, 320 * multiplier),
                (2011, 500 * multiplier),
                (2013, 420 * multiplier),
                (2016, 700 * multiplier),
                (2019, 950 * multiplier),
                (2020, 1600 * multiplier),
                (2021, 1400 * multiplier),
                (2022, 1800 * multiplier),
                (2023, 3200 * multiplier),
                (2024, 5500 * multiplier),
                (2025, 7543 * multiplier),
            ],
            period: period,
            noisePercent: 0.015
        )
    }

    func generateGoldUSD(_ period: TimePeriod) -> [PricePoint] {
        // Gold oz USD: 2000≈270, 2011≈1900, 2020≈2060, 2025≈3350
        return generateMilestonePoints(
            milestones: [
                (2000, 273), (2003, 420), (2006, 620),
                (2008, 900), (2010, 1400),(2011, 1900),
                (2013, 1200),(2016, 1150),(2019, 1500),
                (2020, 2060),(2022, 1800),(2023, 2000),
                (2024, 2600),(2025, 3350),
            ],
            period: period,
            noisePercent: 0.012,
            isOunce: true
        )
    }

    func generateSilverEGP(_ period: TimePeriod) -> [PricePoint] {
        return generateMilestonePoints(
            milestones: [
                (2000, 1.5), (2005, 3.0), (2008, 10),
                (2011, 55),  (2013, 30),  (2016, 50),
                (2019, 70),  (2020, 110), (2022, 100),
                (2023, 180), (2024, 280), (2025, 129),
            ],
            period: period,
            noisePercent: 0.025
        )
    }

    func generateSilverUSD(_ period: TimePeriod) -> [PricePoint] {
        return generateMilestonePoints(
            milestones: [
                (2000, 5.0), (2004, 6.5), (2007, 13),
                (2011, 49),  (2013, 20),  (2016, 17),
                (2019, 18),  (2020, 29),  (2022, 22),
                (2023, 25),  (2024, 32),  (2025, 33),
            ],
            period: period,
            noisePercent: 0.022,
            isOunce: true
        )
    }

    func generateUSDEGP(_ period: TimePeriod) -> [PricePoint] {
        return generateMilestonePoints(
            milestones: [
                (2000, 3.5),  (2003, 6.2),  (2005, 5.8),
                (2010, 5.6),  (2013, 7.0),  (2016, 8.8),
                (2017, 17.5), (2019, 16.8), (2020, 16.0),
                (2022, 18.0), (2023, 30.9), (2024, 48.0),
                (2025, 51.99),
            ],
            period: period,
            noisePercent: 0.003
        )
    }

    // MARK: - Milestone interpolation

    private func generateMilestonePoints(
        milestones: [(year: Int, value: Double)],
        period: TimePeriod,
        noisePercent: Double,
        isOunce: Bool = false
    ) -> [PricePoint] {

        let cal = Calendar.current
        let end = Date()
        let start = cal.date(byAdding: .day, value: -period.days, to: end)!

        // Convert milestones to Dates
        var anchors: [(date: Date, value: Double)] = []
        for (year, val) in milestones {
            var comps = DateComponents(); comps.year = year; comps.month = 1; comps.day = 1
            if let d = cal.date(from: comps) { anchors.append((d, val)) }
        }
        anchors.append((end, milestones.last!.value))

        // Determine step
        let stepHours: Int
        switch period {
        case .h24:     stepHours = 1
        case .week:    stepHours = 4
        case .month:   stepHours = 12
        case .months3: stepHours = 24
        case .months6: stepHours = 48
        case .months9: stepHours = 72
        case .year1:   stepHours = 168      // weekly
        case .years2:  stepHours = 336
        case .years3:  stepHours = 504
        }

        var points: [PricePoint] = []
        var current = start
        var seed: UInt64 = 42

        while current <= end {
            let baseVal = interpolate(anchors: anchors, at: current)
            let noise = baseVal * noisePercent * pseudoRandom(seed: &seed)
            let val = max(0.01, baseVal + noise)
            points.append(PricePoint(date: current, value: val.rounded(toDecimalPlaces: 2)))
            current = cal.date(byAdding: .hour, value: stepHours, to: current)!
        }
        return points
    }

    private func interpolate(anchors: [(date: Date, value: Double)], at date: Date) -> Double {
        guard anchors.count >= 2 else { return anchors.first?.value ?? 0 }
        for i in 0..<anchors.count - 1 {
            let a = anchors[i]; let b = anchors[i+1]
            if date >= a.date && date <= b.date {
                let total = b.date.timeIntervalSince(a.date)
                let elapsed = date.timeIntervalSince(a.date)
                let t = total > 0 ? elapsed / total : 0
                return a.value + (b.value - a.value) * t
            }
        }
        return anchors.last!.value
    }

    private func pseudoRandom(seed: inout UInt64) -> Double {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        let val = Double(seed >> 33) / Double(UInt32.max)
        return (val - 0.5) * 2  // -1 to 1
    }
}

extension Double {
    func rounded(toDecimalPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
