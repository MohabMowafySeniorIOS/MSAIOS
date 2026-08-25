//
//  GoldService.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 01/04/2026.
//

import Foundation
struct GoldResponse: Decodable {
    let rates: [String: Double]
}
class GoldService {
    
    private let apiKey = "J8HJ392G5QV1TJGN"
    
    func fetchGoldPrice() async throws -> Double {
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=XAUUSD&apikey=\(apiKey)"
           let url = URL(string: urlString)!
           
           let (data, _) = try await URLSession.shared.data(from: url)
           
           let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
           
           if let quote = json?["Global Quote"] as? [String: String],
              let priceString = quote["05. price"],
              let price = Double(priceString) {
               return price
           }
           
           return 0
    }
}
