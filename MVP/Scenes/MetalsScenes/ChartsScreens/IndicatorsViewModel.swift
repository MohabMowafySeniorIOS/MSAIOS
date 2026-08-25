//
//  IndicatorsViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 22/05/2026.
//

import Foundation
import Foundation
import SwiftUI

@MainActor
final class IndicatorsViewModel: ObservableObject {
    
    @Published var chartData: [ChartPoint] = []
    
    @Published var prices: [ChartGoldPrice] = []
    
    @Published var selectedPeriod: ChartPeriod = .day
    
    @Published var selectedValue: Double?
    
    @Published var loading = false
    
    func fetchData() async {
        
        loading = true
        
        do {
            
            let globalPrice = try await GoldAPIService
                .shared
                .fetchGoldPrice()
            
            let egyptPrice21 = globalPrice * 2.15
            let egyptPrice24 = globalPrice * 2.45
            let egyptPrice18 = globalPrice * 1.85
            
            prices = [
                ChartGoldPrice(
                    karat: "24",
                    buy: egyptPrice24,
                    sell: egyptPrice24 + 20
                ),
                ChartGoldPrice(
                    karat: "21",
                    buy: egyptPrice21,
                    sell: egyptPrice21 + 20
                ),
                ChartGoldPrice(
                    karat: "18",
                    buy: egyptPrice18,
                    sell: egyptPrice18 + 20
                )
            ]
            
            generateFakeChart()
            
        } catch {
            
            print(error)
        }
        
        loading = false
    }
    
    func generateFakeChart() {
        
        chartData = []
        
        for hour in 0..<24 {
            
            let value = Double.random(in: 6750...6850)
            
            chartData.append(
                ChartPoint(
                    date: Calendar.current.date(
                        byAdding: .hour,
                        value: hour,
                        to: .now
                    ) ?? Date(),
                    value: value
                )
            )
        }
    }
}
