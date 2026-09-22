//
//  AllCurrencyView.swift
//  MSA
//
//  Created by Mohab Mowafy on 24/05/2026.
//

import SwiftUI
import FirebaseFirestore

// MARK: MODEL

struct CurrencyBankModel: Identifiable {
    
    let id: String
    
    let bank: String
    
    let currency: String
    
    let buy: Double
    
    let sell: Double
    
    let logo: String
    
    let trend: String
    
    let bankUrl: String?
    
    let bankUpdatedAt: Date?
}

// MARK: VIEW MODEL

@MainActor
final class AllCurrencyViewModel:
ObservableObject {
    
    @Published var banks:
    [CurrencyBankModel] = []
    
    @Published var selectedCurrency =
    "USD"
    
    @Published var loading = false
    
    private var listener:
    ListenerRegistration?
    
    func fetchCurrency() {
        
        loading = true
        
        listener?.remove()
        
        listener =
        Firestore.firestore()
            .collection("currencies")
            .document(selectedCurrency)
            .collection("banks")
            .order(by: "buy", descending: true)
            .addSnapshotListener {
                snapshot,
                error in
                
                guard let docs =
                snapshot?.documents else {
                    return
                }
                
                self.banks =
                docs.compactMap {
                    doc in
                    
                    let data =
                    doc.data()
                    
                    return CurrencyBankModel(
                        
                        id: doc.documentID,
                        
                        bank:
                            data["name"]
                            as? String ?? "",
                        
                        currency:
                            data["currency"]
                            as? String ?? "",
                        
                        buy:
                            data["buy"]
                            as? Double ?? 0,
                        
                        sell:
                            data["sell"]
                            as? Double ?? 0,
                        
                        logo:
                            data["logo"]
                            as? String ?? "",
                        
                        trend:
                            data["trend"]
                        as? String ?? "same",
                        bankUrl: data["trend"]
                        as? String ?? "",
                        bankUpdatedAt: (data["bankUpdatedAt"] as? Timestamp)?.dateValue()
                    )
                }
                
                self.loading = false
            }
    }
    
    deinit {
        
        listener?.remove()
    }
}

// MARK: VIEW

struct AllCurrencyScreen: View {
    
    @StateObject private var vm =
    AllCurrencyViewModel()
    
    let currencies = [
        
        "USD",
        "EUR",
        "SAR",
        "AED",
        "KWD",
        "GBP"
    ]
    
    var body: some View {
        
        ZStack {
            
            background
            
            VStack(
                spacing: 20
            ) {
                
                header
                
                currencyTabs
                
                if vm.loading {
                    
                    Spacer()
                    
                    ProgressView()
                        .tint(goldColor)
                    
                    Spacer()
                    
                } else {
                    
                    banksList
                }
            }
        }
        .onAppear {
            
            vm.fetchCurrency()
        }
        .onChange(
            of: vm.selectedCurrency
        ) {
            
            vm.fetchCurrency()
        }
    }
}

// MARK: UI

extension AllCurrencyScreen {
    
    var background: some View {
        
        LinearGradient(
            colors: [
                .black,
                Color(
                    red: 0.12,
                    green: 0.09,
                    blue: 0.02
                )
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    var header: some View {
        
        VStack(
            spacing: 8
        ) {
            
            Text("أسعار العملات")
                .font(
                    .largeTitle.bold()
                )
                .foregroundColor(.white)
            
            Text("Live Bank Prices")
                .foregroundColor(
                    goldColor
                )
        }
        .padding(.top)
    }
    
    var currencyTabs: some View {
        
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            
            HStack(
                spacing: 12
            ) {
                
                ForEach(
                    currencies,
                    id: \.self
                ) { currency in
                    
                    Button {
                        
                        vm.selectedCurrency =
                        currency
                        
                    } label: {
                        
                        Text(currency)
                            .font(
                                .headline.bold()
                            )
                            .foregroundColor(
                                vm.selectedCurrency
                                == currency
                                ? .black
                                : goldColor
                            )
                            .padding(
                                .horizontal,
                                22
                            )
                            .padding(
                                .vertical,
                                12
                            )
                            .background(
                                vm.selectedCurrency
                                == currency
                                ? goldColor
                                : Color.white.opacity(0.05)
                            )
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var banksList: some View {
        
        ScrollView(
            showsIndicators: false
        ) {
            
            LazyVStack(
                spacing: 14
            ) {
                
                ForEach(vm.banks) {
                    bank in
                    
                    bankCard(bank)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
    
    func bankCard(
        _ item: CurrencyBankModel
    ) -> some View {
        
        HStack(
            spacing: 14
        ) {
            
            // LOGO
            
            AsyncImage(
                url: URL(
                    string: item.logo
                )
            ) { image in
                
                image
                    .resizable()
                    .scaledToFit()
                
            } placeholder: {
                
                ProgressView()
            }
            .frame(
                width: 55,
                height: 55
            )
            .clipShape(Circle())
            
            // INFO
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                
                Text(item.bank)
                    .font(
                        .headline.bold()
                    )
                    .foregroundColor(.white)
                
                HStack(
                    spacing: 6
                ) {
                    
                    Circle()
                        .fill(
                            trendColor(
                                item.trend
                            )
                        )
                        .frame(
                            width: 10,
                            height: 10
                        )
                    
                    Text(
                        trendText(
                            item.trend
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // PRICES
            
            VStack(
                alignment: .trailing,
                spacing: 10
            ) {
                
                VStack(
                    alignment: .trailing,
                    spacing: 2
                ) {
                    
                    Text("شراء")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(
                        String(
                            format: "%.2f",
                            item.buy
                        )
                    )
                    .font(
                        .headline.bold()
                    )
                    .foregroundColor(.green)
                }
                
                VStack(
                    alignment: .trailing,
                    spacing: 2
                ) {
                    
                    Text("بيع")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(
                        String(
                            format: "%.2f",
                            item.sell
                        )
                    )
                    .font(
                        .headline.bold()
                    )
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            Color.white.opacity(0.05)
        )
        .overlay {
            
            RoundedRectangle(
                cornerRadius: 20
            )
            .stroke(
                goldColor.opacity(0.2),
                lineWidth: 1
            )
        }
        .cornerRadius(20)
    }
    
    func trendColor(
        _ trend: String
    ) -> Color {
        
        switch trend {
            
        case "up":
            return .green
            
        case "down":
            return .red
            
        default:
            return .gray
        }
    }
    
    func trendText(
        _ trend: String
    ) -> String {
        
        switch trend {
            
        case "up":
            return "صاعد"
            
        case "down":
            return "هابط"
            
        default:
            return "ثابت"
        }
    }
    
    var goldColor: Color {
        
        Color(
            red: 0.88,
            green: 0.76,
            blue: 0.52
        )
    }
}

// MARK: PREVIEW

#Preview {
    
    CurrencyScreen()
}
