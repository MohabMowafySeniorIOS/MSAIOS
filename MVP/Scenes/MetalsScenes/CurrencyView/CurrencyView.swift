//
//  CurrencyView.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 20/03/2026.
//

import Foundation
import Foundation
import SwiftSoup

class CurrencyScreenVC: UIHostingController<CurrencyScreen> {

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: CurrencyScreen())
    }
}


struct CurrencyScreen: View {
    
    @StateObject var vm = CurrencyViewModel()
    
    var body: some View {
        VStack {
          //  headerView
            contentView
        }
        .task {
            fetchGoldPrice()
            fetchHTML()
        }

    }
    func fetchHTML()  {
      

        let url = URL(string: "https://egrates.com")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            if let html = String(data: data, encoding: .utf8) {
                do {
                    let doc = try SwiftSoup.parse(html)
                    let prices = try doc.select(".table tbody tr")
                    
                    for row in prices {
                        let bank = try row.select("td").get(0).text()
                        let price = try row.select("td").get(1).text()
                        print(bank, price)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func fetchGoldPrice() {
        let url = URL(string: "https://api.metals-api.com/v1/latest?access_key=KEY&symbols=XAU")!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let rates = json?["rates"] as? [String: Double]

            let gold = rates?["XAU"]
            print("Gold:", gold ?? 0)
        }.resume()
    }
    private var headerView: some View {
        VStack {
            ZStack {
                LinearGradient(
                    colors: [.black, .blue.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Image("logo")
                    .resizable()
                    .frame(width: 30,height: 30)
            }
           
        }.frame(height: 60)
    }
    private var contentView: some View {
        ZStack {
            
            // 🌈 Background
            LinearGradient(
                colors: [.black, .blue.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // 🟢 Header
                VStack(spacing: 8) {
                    Text("Base Currency")
                        .foregroundColor(.gray)
                    
                    Text(vm.baseCurrency)
                        .font(.msa(40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // 🔄 Converter Card
                VStack(spacing: 15) {
                    
                    TextField("Amount", text: $vm.amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    Picker("Base", selection: $vm.baseCurrency) {
                        ForEach(vm.rates.keys.sorted(), id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: vm.baseCurrency) { _ in
                        vm.fetchRates()
                    }
                    
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                
                // 🔍 Search
                TextField("Search currency...", text: $vm.searchText)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                
                // 📊 List العملات
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.filteredRates, id: \.0) { code, value in
                            
                            CurrencyRow(
                                code: code,
                                value: value,
                                amount: Double(vm.amount) ?? 1
                            )
                        }
                    }
                }
                
            }
            .padding()
        }
        .onAppear {
            vm.fetchRates()
        }
    }
}
struct CurrencyRow: View {
    
    let code: String
    let value: Double
    let amount: Double
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(code)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("1 \(code)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(value * amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}



import SwiftUI

struct LogoView: View {
    let uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: 160, maxHeight: 160)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// Usage:
// LogoView(uiImage: UIImage(contentsOfFile: "/Users/etisalat/Downloads/WhatsApp Image 2026-03-18 at 22.25.55.jpeg"))
#Preview {
    CurrencyScreen()
}
