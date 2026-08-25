//
//  SilverStatisticsView.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

//import Foundation
//import SwiftUI
//import WebKit
//
//struct PricePointSilver: Identifiable {
//    let id = UUID()
//    let time: Date
//    let value: Double
//}
//
//
//class ChartViewModel: ObservableObject {
//    
//    @Published var data: [PricePointSilver] = []
//    
//    let scraper = GoldPriceScraper() // أو Silver
//    
//    func startFetching() {
//        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
//            
//            self.scraper.fetchPrice { price in
//                guard let price = price,
//                      let value = Double(price.replacingOccurrences(of: ",", with: "")) else { return }
//                
//                DispatchQueue.main.async {
//                    self.data.append(
//                        PricePointSilver(time: Date(), value: value)
//                    )
//                    
//                    // خليه يحتفظ بآخر 20 نقطة بس
//                    if self.data.count > 20 {
//                        self.data.removeFirst()
//                    }
//                }
//            }
//        }
//    }
//}
//import SwiftUI
//import Charts
//
//struct GoldChartView: View {
//    
//    @StateObject var vm = ChartViewModel()
//    
//    var body: some View {
//        VStack {
//            
//            Text("Live Gold Price")
//                .font(.title)
//            
//            if #available(iOS 16.0, *) {
//                Chart(vm.data) { item in
//                    LineMark(
//                        x: .value("Time", item.time),
//                        y: .value("Price", item.value)
//                    )
//                    .interpolationMethod(.catmullRom)
//                    .foregroundStyle(.yellow)
//                    
//                    AreaMark(
//                        x: .value("Time", item.time),
//                        y: .value("Price", item.value)
//                    )
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.yellow.opacity(0.4), .clear],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//                }
//                
//            } else {
//                // Fallback on earlier versions
//            }
//            
//        }
//        .padding()
//        .background(Color.black)
//        .onAppear {
//            vm.startFetching()
//        }
//    }
//}
