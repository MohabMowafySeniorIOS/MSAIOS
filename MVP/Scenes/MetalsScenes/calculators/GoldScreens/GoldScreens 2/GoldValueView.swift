//
//  GoldValueView.swift
//  MSA
//
//  Created by Mohab Mowafy on 13/04/2026.
//

import SwiftUI

struct GoldItem: Identifiable {
    let id = UUID()
    let karat: Int
    var weight: String = ""
    var result: Double = 0
}
import SwiftUI

class GoldValueViewModel: ObservableObject {
    
    @Published var items: [GoldItem] = [
        GoldItem(karat: 24),
        GoldItem(karat: 22),
        GoldItem(karat: 21),
        GoldItem(karat: 18)
    ]
    
    let basePrice: Double = Double(metalPriceValue.goldPrice?.buyPrice ?? "0.0") ?? 0.0  // سعر عيار 21
    
    func calculate() {
        for i in items.indices {
            let weight = Double(items[i].weight) ?? 0
            let karat = Double(items[i].karat)
            
            let pricePerGram = (karat / 21.0) * basePrice
            let total = weight * pricePerGram
            
            items[i].result = total
        }
    }
}
struct GoldValueCalculatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = GoldValueViewModel()
    
    var body: some View {
       
            content
            .background( BGSwiftUIView())
        .environment(\.layoutDirection, .rightToLeft)
    }
    
   private var content : some View {
        VStack(spacing: 20) {
           
            headerView(title: "Gold value calculator".localized, isBackShow: true) {
                dismiss()
            }
            
            Text(String(format: "gold_price_info".localized, Int(vm.basePrice)))
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            // Inputs
            ForEach($vm.items) { $item in
                HStack {
                    
                    Text("\("Karat".localized) \(item.karat)")
                        .foregroundColor(.white)
                        
                    
                    TextField("0.0", text: $item.weight)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    Text("Gram".localized)
                        .foregroundColor(.white)
                        
                }
                .padding(.horizontal)
            }
            
            // Button
            GoldGradientButton(title: "Gold Calculator".localized) {
                vm.calculate()
            }
           
            // Results
            VStack(spacing: 10) {
                ForEach(vm.items) { item in
                    if item.result > 0 {
                        let formatted = String(format: "%.2f", item.result)
                        Text("\("Karat".localized) \(item.karat): \(formatted) \("Pound".localized)")
                            .foregroundColor(.white)
                    }
                }
            }
            
            Spacer()
           
        }
    }
    
}
