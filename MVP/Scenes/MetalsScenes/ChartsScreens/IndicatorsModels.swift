//
//  IndicatorsModels.swift
//  MSA
//
//  Created by Mohab Mowafy on 22/05/2026.
//

import Foundation


struct ChartGoldPrice: Codable, Identifiable {
    
    let id = UUID()
    
    let karat: String
    let buy: Double
    let sell: Double
}

struct ChartPoint: Identifiable {
    
    let id = UUID()
    let date: Date
    let value: Double
}

struct GoldAPIResponse: Codable {
    
    let price: Double
    let timestamp: Double
}
