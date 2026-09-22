//
//  PortfolioItemWithValue.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//



import Foundation

// MARK: - AssetType

enum AssetType: String, CaseIterable, Codable, Identifiable {
    case gold24K, gold21K, gold18K, goldPound, goldKilo
    case silver999, silver925, silver800, silverKilo

    var id: String { rawValue }

    var displayAr: String {
        switch self {
        case .gold24K:    return "ذهب عيار 24"
        case .gold21K:    return "ذهب عيار 21"
        case .gold18K:    return "ذهب عيار 18"
        case .goldPound:  return "جنيه ذهب"
        case .goldKilo:   return "كيلو ذهب"
        case .silver999:  return "فضة عيار 999"
        case .silver925:  return "فضة عيار 925"
        case .silver800:  return "فضة عيار 800"
        case .silverKilo: return "كيلو فضة"
        }
    }

    var displayEn: String {
        switch self {
        case .gold24K:    return "Gold 24K"
        case .gold21K:    return "Gold 21K"
        case .gold18K:    return "Gold 18K"
        case .goldPound:  return "Gold Pound"
        case .goldKilo:   return "Gold Kilo"
        case .silver999:  return "Silver 999"
        case .silver925:  return "Silver 925"
        case .silver800:  return "Silver 800"
        case .silverKilo: return "Silver Kilo"
        }
    }

    var isGold: Bool {
        switch self {
        case .gold24K, .gold21K, .gold18K, .goldPound, .goldKilo: return true
        default: return false
        }
    }

    /// True = quantity is grams; false = quantity is a unit count (pounds/kilos).
    var measuredByWeight: Bool {
        switch self {
        case .goldPound, .goldKilo, .silverKilo: return false
        default: return true
        }
    }
}

// MARK: - PortfolioItem

/// One holding the user has recorded.
/// `quantity` is grams for weight-based assets, or a unit count for pounds/kilos.
/// We store the TOTAL price paid (not per-unit) because that's what users remember.
struct PortfolioItem2: Identifiable, Codable, Hashable {
    let id: String
    var type: AssetType
    var quantity: Double
    var purchaseTotalPrice: Double      // EGP
    var purchaseDate: Date
    var notes: String?

    var purchasePricePerUnit: Double {
        quantity > 0 ? purchaseTotalPrice / quantity : 0
    }
}

// MARK: - Computed wrappers

/// [PortfolioItem] paired with its current value at today's prices.
/// `pricesAvailable` = false during initial load — the UI shows "—" instead of misleading "0".
struct PortfolioItemWithValue: Identifiable {
    let item: PortfolioItem2
    let currentValue: Double
    let pricesAvailable: Bool

    var id: String { item.id }
    var profit: Double { currentValue - item.purchaseTotalPrice }
    var profitPercent: Double {
        item.purchaseTotalPrice > 0 ? profit / item.purchaseTotalPrice * 100.0 : 0
    }
    var isProfit: Bool { profit >= 0 }
}

/// Aggregate stats for the summary card.
struct PortfolioSummary2 {
    let itemCount: Int
    let totalInvested: Double
    let totalCurrentValue: Double

    var totalProfit: Double { totalCurrentValue - totalInvested }
    var totalProfitPercent: Double {
        totalInvested > 0 ? totalProfit / totalInvested * 100.0 : 0
    }
    var isProfit: Bool { totalProfit >= 0 }
}

// MARK: - Price snapshots (mirror Android GoldPrices/SilverPrices)

struct GoldPrices {
    let karat24Buy, karat24Sell: Double
    let karat21Buy, karat21Sell: Double
    let karat18Buy, karat18Sell: Double
    let goldPoundBuy, goldPoundSell: Double
    let goldKiloBuy, goldKiloSell: Double

    /// Same formula the Android `PriceCalculator.computeGold` uses, which itself
    /// mirrors the iOS gold-price math elsewhere in the app.
    static func compute(base21Buy: Double, base21Sell: Double) -> GoldPrices {
        GoldPrices(
            karat24Buy:    base21Buy  * (24.0 / 21.0),
            karat24Sell:   base21Sell * (24.0 / 21.0),
            karat21Buy:    base21Buy,
            karat21Sell:   base21Sell,
            karat18Buy:    base21Buy  * (18.0 / 21.0),
            karat18Sell:   base21Sell * (18.0 / 21.0),
            goldPoundBuy:  base21Buy  * 8.0,
            goldPoundSell: base21Sell * 8.0,
            goldKiloBuy:   base21Buy  * 1000.0,
            goldKiloSell:  base21Sell * 1000.0
        )
    }
}

struct SilverPrices {
    let karat999Buy, karat999Sell: Double
    let karat925Buy, karat925Sell: Double
    let karat800Buy, karat800Sell: Double
    let silverKiloBuy, silverKiloSell: Double

    static func compute(base999Buy: Double, base999Sell: Double) -> SilverPrices {
        SilverPrices(
            karat999Buy:    base999Buy,
            karat999Sell:   base999Sell,
            karat925Buy:    base999Buy  * (925.0 / 999.0),
            karat925Sell:   base999Sell * (925.0 / 999.0),
            karat800Buy:    base999Buy  * (800.0 / 999.0),
            karat800Sell:   base999Sell * (800.0 / 999.0),
            silverKiloBuy:  base999Buy  * 1000.0,
            silverKiloSell: base999Sell * 1000.0
        )
    }
}
