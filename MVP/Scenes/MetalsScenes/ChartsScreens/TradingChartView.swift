//
//  TradingChartView.swift
//  MSA
//
//  Created by Mohab Mowafy on 22/05/2026.
//

import SwiftUI
import LightweightCharts

// MARK: MODEL

struct GoldPriceResponse: Codable {
    
    let price: Double
}

// MARK: VIEW

struct TradingChartView: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> LightweightCharts {
        
        let chart = LightweightCharts()
        
        chart.backgroundColor = .black
        
        // MARK: SERIES
        
        let areaSeries = chart.addAreaSeries(options: nil)
        
        context.coordinator.series = areaSeries
        
        // MARK: FETCH
        
        fetchGoldData(series: areaSeries)
        
        return chart
    }
    
    func updateUIView(
        _ uiView: LightweightCharts,
        context: Context
    ) {
        
    }
}

// MARK: API

extension TradingChartView {
    
    func fetchGoldData(
        series: AreaSeries
    ) {
        
        // API
        
        let url = URL(
            string: "https://www.goldapi.io/api/XAU/USD"
        )!
        
        var request = URLRequest(url: url)
        
        // TOKEN
        
        request.addValue(
            "goldapi-d18f6ce79e0d32039421dffa90e23b6e-io",
            forHTTPHeaderField: "x-access-token"
        )
        
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            
            guard let data = data else {
                return
            }
            
            do {
                
                let decoded = try JSONDecoder().decode(
                    GoldPriceResponse.self,
                    from: data
                )
                
                let currentPrice = decoded.price
                
                DispatchQueue.main.async {
                    
                    // CREATE FAKE HISTORY
                    
                    var chartData: [AreaData] = []
                    
                    for index in 0..<24 {
                        
                        let randomValue =
                        currentPrice +
                        Double.random(in: -50...50)
                        
                        let hour =
                        String(format: "%02d:00", index)
                        
                        chartData.append(
                            AreaData(
                                time: .string(hour),
                                value: randomValue
                            )
                        )
                    }
                    
                    print(chartData)
                    
                    // SET DATA
                    
                    series.setData(data: chartData)
                }
                
            } catch {
                
                print(error)
            }
        }
        .resume()
    }
}

// MARK: COORDINATOR

extension TradingChartView {
    
    class Coordinator {
        
        var series: AreaSeries?
    }
}
struct TrendingView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            TradingChartView()
                .frame(height: 350)
                .padding()
        }
    }
}
