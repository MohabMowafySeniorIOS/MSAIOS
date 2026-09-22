//
//  SilverViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import Foundation
// MARK: - ViewModel
class SilverViewModel: ObservableObject {
    
    @Published var items: [SilverItem] = [
        SilverItem(karat: 999),
        SilverItem(karat: 925),
        SilverItem(karat: 900),
        SilverItem(karat: 800),
        SilverItem(karat: 600)
    ]
    
    let basePrice: Double = 102.5 // سعر عيار 800
    
    func calculate() {
        for i in items.indices {
            let weight = Double(items[i].weight) ?? 0
            let karat = Double(items[i].karat)
            
            let pricePerGram = (karat / 800.0) * basePrice
            let total = weight * pricePerGram
            
            items[i].result = total
        }
    }
}
