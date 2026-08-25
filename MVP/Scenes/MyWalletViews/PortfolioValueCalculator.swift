//
//  PortfolioValueCalculator.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

import Foundation
//
//  PortfolioValueCalculator.swift
//  MSA
//
//  Mirrors Android: domain/usecase/CalculatePortfolioValue.kt
//

import Foundation

/// Computes today's value of a portfolio holding by multiplying the user's
/// quantity by the current market BUY price for that asset.
///
/// Why buy not sell? In the Egyptian gold market the dealer's *buy* price
/// (سعر الشراء) is what the customer would receive if they liquidated now,
/// so it's the honest "if I sold today" number. Using sell would overstate
/// gains since the spread is the dealer's margin, not yours.
enum PortfolioValueCalculator {

    static func calculate(
        item: PortfolioItem,
        gold: GoldPrices?,
        silver: SilverPrices?
    ) -> PortfolioItemWithValue {

        let pricesReady = (item.type.isGold && gold != nil) ||
                          (!item.type.isGold && silver != nil)
        let unit = unitBuyPrice(type: item.type, gold: gold, silver: silver)

        return PortfolioItemWithValue(
            item: item,
            currentValue: unit * item.quantity,
            pricesAvailable: pricesReady
        )
    }

    private static func unitBuyPrice(
        type: AssetType,
        gold: GoldPrices?,
        silver: SilverPrices?
    ) -> Double {
        switch type {
        case .gold24K:    return gold?.karat24Buy    ?? 0
        case .gold21K:    return gold?.karat21Buy    ?? 0
        case .gold18K:    return gold?.karat18Buy    ?? 0
        case .goldPound:  return gold?.goldPoundBuy  ?? 0
        case .goldKilo:   return gold?.goldKiloBuy   ?? 0
        case .silver999:  return silver?.karat999Buy  ?? 0
        case .silver925:  return silver?.karat925Buy  ?? 0
        case .silver800:  return silver?.karat800Buy  ?? 0
        case .silverKilo: return silver?.silverKiloBuy ?? 0
        }
    }
}
