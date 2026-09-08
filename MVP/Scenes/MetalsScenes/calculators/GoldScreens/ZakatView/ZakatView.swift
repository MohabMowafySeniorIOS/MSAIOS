//
//  ZakatView.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 02/04/2026.
//

import Foundation
import SwiftUI
import Combine




struct ZakatView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = ZakatVM()
    
    var body: some View {
        
            VStack {
                headerView(title: "Calculate Zakat on gold".localized, isBackShow: true) {
                    dismiss()
                }
                contentView
                Spacer()
            }.background( BGSwiftUIView())
            .environment(\.layoutDirection, .rightToLeft)
    }
    
    var contentView: some View {
        VStack(spacing: 20) {
           
           
            // Description
            VStack(spacing: 8) {
                Text("zakat_input_title".localized)
                Text("zakat_info_1".localized)
                Text("zakat_info_2".localized)
                Text("zakat_info_3".localized)
                Text("zakat_info_4".localized)
            }
            .font(.footnote)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
         
            // Inputs
            inputRow(title: "Karat 24".localized, binding: $vm.w24)
            inputRow(title: "Karat 22".localized, binding: $vm.w22)
            inputRow(title: "Karat 21".localized, binding: $vm.w21)
            inputRow(title: "Karat 18".localized, binding: $vm.w18)
            
            // Button
            GoldGradientButton(title: "Calculate Zakat".localized) {
                vm.calculate()
            }
            
            // Result
            if vm.zakat > 0 {
                Text(String(format: "zakat_amount".localized, format(vm.zakat)))
                    .foregroundColor(.white)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
       
        .alert("zakat_not_reached_nisab".localized, isPresented: $vm.showAlert) {
            Button("Done".localized, role: .cancel) {}
        } message: {
            Text("zakat_below_nisab_message".localized)
        }

    }
    
   
    
    // MARK: - Row
    func inputRow(title: String, binding: Binding<String>) -> some View {
        HStack {
            
            Text("Gram".localized)
                .foregroundColor(.white)
            
            TextField("0.0", text: binding)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 2)
            
            Text(title)
                //.frame(width: 80, alignment: .trailing)
                .foregroundColor(.white)
             //   .bold()
        }
    }
    
    // MARK: - Format
    func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
struct GoldGradientButton: View {
    
    var title: String = ""
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#EFC874"), // light gold
                            Color(hex: "#E8B138"), // main gold
                            Color(hex: "#906E23")  // darker gold
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.25),
                        radius: 10,
                        x: 0,
                        y: 6)
        }
        .padding(.horizontal)
    }
}
