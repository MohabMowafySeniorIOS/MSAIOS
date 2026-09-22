//
//  getGoldPriceViewModel.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 01/04/2026.
//

import Foundation
import Combine


class getGoldPriceViewModel {
    
    @Published var price: Double = 0.0
    private let service = GoldService()
    private var timer: Timer?
    
    init() {
        startFetching()
    }
    
    func startFetching() {
        Task {
            await self.fetch()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task {
                await self.fetch()
            }
        }
    }
    
    func fetch() async {
        do {
            let value = try await service.fetchGoldPrice()
            
            DispatchQueue.main.async {
                self.price = value
                print(value)
            }
            
        } catch {
            print(error)
        }
    }
}
