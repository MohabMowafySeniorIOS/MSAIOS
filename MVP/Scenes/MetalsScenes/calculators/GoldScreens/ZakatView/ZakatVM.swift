//
//  ZakatVM.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import Foundation
class ZakatVM: ObservableObject {
    
    @Published var price24: Double = 8200 // تقدر تجيبه من Firebase
    
    @Published var w24 = ""
    @Published var w22 = ""
    @Published var w21 = ""
    @Published var w18 = ""
    
    @Published var zakat: Double = 0
    @Published var showAlert = false
    
    func calculate() {
        let g24 = Double(w24) ?? 0
        let g22 = Double(w22) ?? 0
        let g21 = Double(w21) ?? 0
        let g18 = Double(w18) ?? 0
        
        // تحويل لعيار 24
        let total24 =
        g24 +
        (g22 * 22/24) +
        (g21 * 21/24) +
        (g18 * 18/24)
        
        // تحقق من النصاب
        if total24 < 85 {
            zakat = 0
            showAlert = true
            return
        }
        
        let totalValue = total24 * price24
        zakat = totalValue * 0.025
    }
}
