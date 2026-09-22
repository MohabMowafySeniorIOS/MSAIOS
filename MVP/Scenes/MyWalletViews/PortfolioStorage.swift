//
//  PortfolioStorage.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

import Foundation
//
//  PortfolioStorage.swift
//  MSA
//
//  Mirrors Android: data/source/local/PortfolioPreferences.kt
//

import Foundation
import Combine

/// Persists the portfolio as a JSON-encoded list under a single UserDefaults key.
/// We pick UserDefaults + Codable rather than CoreData because the portfolio is
/// realistically a handful of items loaded together at every read — a serialized
/// blob is simpler than a schema and avoids a new dependency.
@MainActor
final class PortfolioStorage: ObservableObject {
    static let shared = PortfolioStorage()

    @Published private(set) var items: [PortfolioItem2] = []

    private let key = "msa_portfolio_items_v1"
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .millisecondsSince1970
        decoder.dateDecodingStrategy = .millisecondsSince1970
        load()
    }

    // MARK: - CRUD

    func add(_ item: PortfolioItem2) {
        items.append(item)
        save()
    }

    func update(_ item: PortfolioItem2) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[i] = item
        save()
    }

    func remove(id: String) {
        items.removeAll { $0.id == id }
        save()
    }

    func clearAll() {
        items = []
        defaults.removeObject(forKey: key)
    }

    // MARK: - Codec

    private func load() {
        guard let data = defaults.data(forKey: key) else { return }
        items = (try? decoder.decode([PortfolioItem2].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? encoder.encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
