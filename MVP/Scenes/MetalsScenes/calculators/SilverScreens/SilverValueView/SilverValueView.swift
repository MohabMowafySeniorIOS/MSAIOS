//
//  SilverValueView.swift
//  MSA
//
//  Created by Mohab Mowafy on 13/04/2026.
//

import SwiftUI

import SwiftUI




struct SilverCalculatorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = SilverViewModel()
    
    var body: some View {
       
            
            VStack(spacing: 20) {
                
                headerView(title: "Silver value calculator".localized, isBackShow: true) {
                    dismiss()
                }
                
                Text(String(format: "silver_price_info".localized, vm.basePrice))
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                
                // List
                ForEach($vm.items) { $item in
                    HStack {
                        
                        Text("Karat".localized + " \(item.karat)")
                            .foregroundColor(.white)
                        
                        
                        TextField("0.0", text: $item.weight)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                        
                        Text("Gram".localized)
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                    }
                    .padding(.horizontal)
                }
                
                
                GoldGradientButton(title: "Silver Calculator".localized) {
                    vm.calculate()
                }
                
                
                // Results
                VStack(spacing: 10) {
                    ForEach(vm.items) { item in
                        if item.result > 0 {
                            Text(String(format: "gold_result_format".localized,
                                        item.karat,
                                        item.result))
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
            
        }
            .background(BGSwiftUIView())
        .environment(\.layoutDirection, .rightToLeft)
    }
    
   
}
