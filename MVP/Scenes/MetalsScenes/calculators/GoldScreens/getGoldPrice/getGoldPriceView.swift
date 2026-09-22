//
//  getGoldPriceView.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 01/04/2026.
//

import SwiftUI

struct Metal: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var price: Double
}

struct AddMetalView: View {
    
    @State private var selectedMetal = "ذهب"
    @State private var priceText = ""
    @State private var metals: [Metal] = []
    
    let metalsList = ["ذهب", "فضة", "بلاتين"]
    
    var viewModel =  getGoldPriceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Title
            Text("إضافة / تحديث سعر معدن")
                .font(.title2.bold())
            
            // MARK: - Card
            VStack(spacing: 16) {
                
                // Picker
                Picker("المعدن", selection: $selectedMetal) {
                    ForEach(metalsList, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                
                // Price Field
                TextField("ادخل السعر", text: $priceText)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                // Info Label
                if isExistingMetal {
                    Text("سيتم تحديث السعر")
                        .foregroundColor(.orange)
                        .font(.caption)
                } else {
                    Text("سيتم إضافة معدن جديد")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                // Button
                Button(action: saveMetal) {
                    Text("حفظ")
                        .frame(maxWidth: .infinity)
                        .padding()
                    //    .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
           .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding()
            
            // MARK: - List
            List {
                ForEach(metals) { metal in
                    HStack {
                        Text(metal.name)
                            .foregroundColor(.white)
                    
                        Spacer()
                        Text("\(metal.price, specifier: "%.2f")")
                            .bold()
                    }
                }
            }
        }
       .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Logic
    
    var isExistingMetal: Bool {
        metals.contains { $0.name == selectedMetal }
    }
    
    func saveMetal() {
        guard let price = Double(priceText) else { return }
        
        if let index = metals.firstIndex(where: { $0.name == selectedMetal }) {
            // update
            metals[index].price = price
        } else {
            // add
            metals.append(Metal(name: selectedMetal, price: price))
        }
        
        priceText = ""
    }
}
