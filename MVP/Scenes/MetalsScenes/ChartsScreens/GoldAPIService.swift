//
//  GoldAPIService.swift
//  MSA
//
//  Created by Mohab Mowafy on 22/05/2026.
//

import Foundation
import Foundation

final class GoldAPIService {
    
    static let shared = GoldAPIService()
    
    private init() {}
    
    private let apiKey = "goldapi-d18f6ce79e0d32039421dffa90e23b6e-io"
    
    func fetchGoldPrice() async throws -> Double {
        
        let url = URL(string: "https://www.goldapi.io/api/XAU/USD")!
        
        var request = URLRequest(url: url)
        
        request.addValue(apiKey, forHTTPHeaderField: "x-access-token")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try JSONDecoder().decode(
            GoldAPIResponse.self,
            from: data
        )
        
        return response.price
    }
}
