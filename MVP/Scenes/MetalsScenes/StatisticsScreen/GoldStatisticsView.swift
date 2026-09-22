//
//  SilverStatisticsView.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import SwiftUI
import Charts
import WebKit
import Combine

// MARK: - Model
struct GoldPricePoint: Identifiable {
    let id = UUID()
    let time: Date
    let value: Double
}

// MARK: - String Extension
extension String {
    var toDoubleSafe: Double? {
        let clean = self
            .replacingOccurrences(of: ",", with: "")
            .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
            .joined()
        
        return Double(clean)
    }
}

// MARK: - Scraper
class GoldStatisticsPriceScraper: NSObject, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private var completion: ((String?) -> Void)?
    
    private var isLoaded = false
    
    override init() {
        super.init()
        
        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0"
    }
    
    func fetchPrice(completion: @escaping (String?) -> Void) {
        self.completion = completion
        
        if !isLoaded {
            let url = URL(string: "https://www.investing.com/currencies/xau-usd")!
            webView.load(URLRequest(url: url))
            isLoaded = true
        } else {
            extractPrice()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.extractPrice()
        }
    }
    
    private func extractPrice() {
        webView.evaluateJavaScript("""
        document.querySelector('[data-test="instrument-price-last"]').innerText
        """) { result, _ in
            
            self.completion?(result as? String)
        }
    }
}

// MARK: - ViewModel
class GoldChartViewModel: ObservableObject {
    
    @Published var data: [GoldPricePoint] = []
    @Published var currentPrice: Double = 0
    @Published var isLoading = true
    
    private let scraper = GoldStatisticsPriceScraper()
    
    private var cancellable: AnyCancellable?
    private let timer = Timer.publish(every: 10, on: .main, in: .common)
    
    init() {
        start()
    }
    
    func start() {
        cancellable = timer
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetch()
            }
    }
    
    func stop() {
        cancellable?.cancel()
    }
    
    func fetch() {
        scraper.fetchPrice { price in
            
            guard let price = price,
                  let value = price.toDoubleSafe else {
                print("❌ Parsing failed:", price ?? "nil")
                return
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.currentPrice = value
                
                self.data.append(
                    GoldPricePoint(time: Date(), value: value)
                )
                print(self.data)
                // احتفظ بآخر 20 نقطة بس
                if self.data.count > 20 {
                    self.data.removeFirst()
                }
            }
        }
    }
}

// MARK: - View
struct GoldChartView: View {
    
    @StateObject var vm = GoldChartViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Live Gold Price")
                .font(.title)
                .foregroundColor(.white)
            
            if vm.isLoading {
                ProgressView()
            } else {
                Text(String(format: "%.2f", vm.currentPrice))
                    .font(.msa(36, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            if #available(iOS 16.0, *) {
                Chart(vm.data) { item in
                    
                    LineMark(
                        x: .value("Time", item.time),
                        y: .value("Price", item.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Time", item.time),
                        y: .value("Price", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 250) // مهم جدًا
                .chartYScale(domain: .automatic(includesZero: false))
                .animation(.easeInOut, value: vm.data.count)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onDisappear {
            vm.stop()
        }
    }
}
