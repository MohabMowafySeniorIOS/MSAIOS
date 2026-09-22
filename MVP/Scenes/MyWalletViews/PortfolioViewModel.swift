//
//  PortfolioViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

import Foundation
//
//  PortfolioViewModel.swift
//  MSA
//
//  Mirrors Android:
//   presentation/screens/portfolio/PortfolioViewModel.kt
//   presentation/screens/portfolio/AddPortfolioItemViewModel.kt
//

import Foundation
import Combine
import SwiftUI

// MARK: - List VM

@MainActor
final class PortfolioViewModel: ObservableObject {

    @Published private(set) var items: [PortfolioItemWithValue] = []
    @Published private(set) var summary = PortfolioSummary2(itemCount: 0, totalInvested: 0, totalCurrentValue: 0)
    @Published private(set) var loading = true
    @Published private(set) var pricesReady = false

    private let storage = PortfolioStorage.shared
    private let metals = PortfolioMetalsService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Recompute whenever either the user's holdings or live prices change.
        Publishers.CombineLatest3(
            storage.$items,
            metals.$gold,
            metals.$silver
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] raw, gold, silver in
            self?.rebuild(raw: raw, gold: gold, silver: silver)
        }
        .store(in: &cancellables)
    }

    func remove(id: String) {
        storage.remove(id: id)
    }

    private func rebuild(raw: [PortfolioItem2], gold: GoldPrices?, silver: SilverPrices?) {
        let valued = raw.map {
            PortfolioValueCalculator.calculate(item: $0, gold: gold, silver: silver)
        }
        // Newest purchases first — what every banking app does.
        let sorted = valued.sorted { $0.item.purchaseDate > $1.item.purchaseDate }

        items = sorted
        summary = PortfolioSummary2(
            itemCount: sorted.count,
            totalInvested: sorted.reduce(0) { $0 + $1.item.purchaseTotalPrice },
            totalCurrentValue: sorted.reduce(0) { $0 + $1.currentValue }
        )
        loading = false
        pricesReady = gold != nil || silver != nil
    }
}

// MARK: - Add-item VM

@MainActor
final class AddPortfolioItemViewModel: ObservableObject {

    @Published var type: AssetType = .gold21K
    @Published var quantityText = ""
    @Published var totalPriceText = ""
    @Published var purchaseDate = Date()
    @Published var notes = ""
    @Published private(set) var saving = false
    @Published private(set) var saved = false
    @Published private(set) var error: String?

    var quantity: Double {
        Double(quantityText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var totalPrice: Double {
        Double(totalPriceText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var isValid: Bool { quantity > 0 && totalPrice > 0 }

    /// Convenience for the per-unit hint shown under the price field.
    var perUnitPrice: Double? {
        guard quantity > 0, totalPrice > 0 else { return nil }
        return totalPrice / quantity
    }

    func save() {
        guard isValid, !saving else { return }
        saving = true
        error = nil

        let item = PortfolioItem2(
            id: UUID().uuidString,
            type: type,
            quantity: quantity,
            purchaseTotalPrice: totalPrice,
            purchaseDate: purchaseDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        PortfolioStorage.shared.add(item)

        saving = false
        saved = true
    }
}
