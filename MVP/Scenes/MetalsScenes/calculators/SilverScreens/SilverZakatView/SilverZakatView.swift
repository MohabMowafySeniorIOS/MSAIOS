//
//  SilverZakatView.swift
//  MSA
//
//  Created by Mohab Mowafy on 13/04/2026.
//

import SwiftUI



struct SilverZakatView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = ZakatViewModel()
    
    var body: some View {
        
            VStack(spacing: 20) {
                
                headerView(title: "Calculate Zakat On Silver".localized, isBackShow: true) {
                    dismiss()
                }
                
                VStack(spacing: 6) {
                    Text("zakat_assets_input_title".localized)
                        .foregroundColor(.white)
                    Text("silver_nisab_info".localized)
                        .foregroundColor(.white)
                    Text("silver_zakat_condition".localized)
                        .foregroundColor(.white)
                    Text("zakat_haul_condition".localized)
                        .foregroundColor(.white)
                }
                .font(.subheadline)
                .multilineTextAlignment(.center)
                
                // Inputs
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
                        
                    }
                    .padding(.horizontal)
                }
                
                // Button
                GoldGradientButton(title: "calculate_silver_zakat".localized) {
                    vm.calculate()
                }
                
                
                // Result
                VStack(spacing: 10) {
                    
                    Text(String(format:"total_pure_silver".localized,
                                String(format: "%.2f", vm.totalPureSilver)))
                    .foregroundColor(.white)
                    
                    Text(vm.message)
                        .foregroundColor(vm.totalPureSilver >= vm.nisab ? .green : .red)
                    
                    if vm.zakatAmount > 0 {
                        Text(String(format: "zakat_weight".localized,
                                    String(format: "%.2f", vm.zakatAmount)))
                        .foregroundColor(.white)
                        .bold()
                    }
                }
                
                Spacer()
            }.background( BGSwiftUIView())
            
        .environment(\.layoutDirection, .rightToLeft)
    }
    
  
}
