//
//  ZakatViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import Foundation
import SwiftUI

class ZakatViewModel: ObservableObject {
    
    @Published var items: [SilverItem] = [
        SilverItem(karat: 999),
        SilverItem(karat: 925),
        SilverItem(karat: 900),
        SilverItem(karat: 800),
        SilverItem(karat: 600)
    ]
    
    @Published var zakatAmount: Double = 0
    @Published var totalPureSilver: Double = 0
    @Published var message: String = ""
    
    let nisab: Double = 595 // نصاب الفضة
    
    func calculate() {
        var total: Double = 0
        
        for item in items {
            let weight = Double(item.weight) ?? 0
            let purity = Double(item.karat) / 1000.0
            
            total += weight * purity
        }
        
        totalPureSilver = total
        
        if total >= nisab {
            zakatAmount = total * 0.025
            message = "✅ الزكاة واجبة"
        } else {
            zakatAmount = 0
            message = "❌ لم تبلغ النصاب"
        }
    }
}
