//
//  PortfolioMetalsService.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

import Foundation
//
//  PortfolioMetalsService.swift
//  MSA
//
//  Mirrors Android: presentation/screens/portfolio/PortfolioViewModel.kt
//                   `computePrices(metals)` helper
//

import Foundation
import Combine
import FirebaseFirestore

/// Subscribes to the `metals` collection in Firestore and republishes parsed
/// per-karat gold + silver prices. Drop in as a stand-alone service so the
/// portfolio doesn't have to know about Firestore.
///
/// NOTE: if your app already exposes metals prices via an existing service or
/// repository, replace the Firestore listener below with whatever publisher
/// you already have — the `.gold` / `.silver` outputs are what the VM needs.
@MainActor
final class PortfolioMetalsService: ObservableObject {

    @Published private(set) var gold: GoldPrices?
    @Published private(set) var silver: SilverPrices?

    private var listener: ListenerRegistration?

    init() { startListening() }

    deinit { listener?.remove() }

    private func startListening() {
        listener = Firestore.firestore().collection("metals")
            .addSnapshotListener { [weak self] snap, error in
                guard let self else { return }
                if let error {
                    print("PortfolioMetals: snapshot error", error)
                    return
                }
                guard let docs = snap?.documents else { return }
                self.parse(docs: docs)
            }
    }

    /// Extracts the gold + silver base rows and turns them into per-karat grids.
    /// Document shape mirrors the iOS `MetalModel` struct used elsewhere:
    ///   { type: "gold"|"silver", buyPrice: "...", salePrice: "..." }
    private func parse(docs: [QueryDocumentSnapshot]) {
        let goldRow   = docs.first { ($0.get("type") as? String) == "gold" }
        let silverRow = docs.first { ($0.get("type") as? String) == "silver" }

        let goldBuy  = Self.doubleOf(goldRow?.get("buyPrice"))
        let goldSell = Self.doubleOf(goldRow?.get("salePrice"))
        let silvBuy  = Self.doubleOf(silverRow?.get("buyPrice"))
        let silvSell = Self.doubleOf(silverRow?.get("salePrice"))

        if goldBuy > 0 || goldSell > 0 {
            gold = GoldPrices.compute(base21Buy: goldBuy, base21Sell: goldSell)
        }
        if silvBuy > 0 || silvSell > 0 {
            silver = SilverPrices.compute(base999Buy: silvBuy, base999Sell: silvSell)
        }
    }

    /// Firestore stores these as strings in iOS too — tolerate both forms.
    private static func doubleOf(_ value: Any?) -> Double {
        if let d = value as? Double { return d }
        if let s = value as? String { return Double(s) ?? 0 }
        if let n = value as? NSNumber { return n.doubleValue }
        return 0
    }
}
