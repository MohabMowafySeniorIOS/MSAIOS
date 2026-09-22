//
//  CurrencyViewModel.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 20/03/2026.
//

import Foundation
import Combine
import SwiftUI
struct BankRate: Identifiable, Codable {
    let id = UUID()
    let name: String
    let buy: String
    let sell: String
    let logo: String
    let date: String
    var trend: Trend?
}


class CurrencyViewModel: ObservableObject {
    
    @Published var baseCurrency: String = "USD"
    @Published var amount: String = "1"
    @Published var rates: [String: Double] = [:]
    @Published var searchText: String = ""
    
    private var refreshCancellable: AnyCancellable?
    
    init() {
        // Start automatic refresh every 3 seconds
        refreshCancellable = Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchRates()
            }
    }
    
    var filteredRates: [(String, Double)] {
        rates
            .filter { searchText.isEmpty || $0.key.lowercased().contains(searchText.lowercased()) }
            .sorted { lhs, rhs in
                let lhsIsEGP = lhs.key == "EGP"
                let rhsIsEGP = rhs.key == "EGP"
                if lhsIsEGP && !rhsIsEGP { return true }
                if rhsIsEGP && !lhsIsEGP { return false }
                return lhs.key < rhs.key
            }
    }
    
    func fetchRates() {
        let apiKey = "fb1fd8f3dcfdf460c201a2fd"
        let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(baseCurrency)")!
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(CurrencyResponse.self, from: data)
            else { return }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.rates = decoded.conversion_rates
                    print(self.rates)
                }
            }
        }.resume()
    }
    
    deinit {
        refreshCancellable?.cancel()
    }
}
struct CurrencyResponse: Codable {
    let conversion_rates: [String: Double]
}
