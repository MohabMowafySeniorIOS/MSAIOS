//
//  KaratGoldPricesView.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 02/04/2026.
//

import Foundation
import SwiftUI
import Combine
struct GoldPrice: Identifiable {
    let id = UUID()
    let karat: Int
    let price: Double
}
class GoldViewModel: ObservableObject {
    @Published var prices: [GoldPrice] = []
    
    func update(price21: Double) {
        prices = calculateGoldList(price21: price21) // ✅ مهم
    }
    
    private func calculateGoldList(price21: Double) -> [GoldPrice] {
        let price24 = price21 / 0.875
        
        return [
            GoldPrice(karat: 24, price: price24),
            GoldPrice(karat: 21, price: price21),
            GoldPrice(karat: 18, price: price24 * 0.75),
            GoldPrice(karat: 14, price: price24 * 0.585)
        ].sorted { $0.karat > $1.karat }
    }
}
struct GoldCardView: View {
    let item: GoldPrice
    
    var body: some View {
        HStack {
            Text("Karat".localized + " \(item.karat)")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(Int(item.price)) " + "Pound".localized)
                .bold()
                .foregroundColor(.yellow)
        }
        .padding()
        //.background(Color.black)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
struct GoldPriceView: View {
    
    @StateObject var viewModel = GoldViewModel()
    @State private var input = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            TextField("ادخل سعر عيار 21", text: $input)
                .keyboardType(.numberPad)
                .padding()
              .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            
            Button("احسب") {
                if let value = Double(input) {
                    viewModel.update(price21: value)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
           .background(Color.yellow)
            .cornerRadius(12)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.prices) { item in
                        GoldCardView(item: item)
                    }
                }
            }
        }
        .padding()
       .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
