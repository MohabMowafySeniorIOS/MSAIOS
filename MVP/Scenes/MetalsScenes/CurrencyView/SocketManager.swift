//
//  SocketManager.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 20/03/2026.
//

import Foundation
class SocketManager {
    
    private var task: URLSessionWebSocketTask?
    
    func connect() {
        let url = URL(string: "wss://ws.finnhub.io?token=YOUR_API_KEY")!
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        
        subscribe()
        receive()
    }
    
    private func subscribe() {
        let message = """
        {"type":"subscribe","symbol":"OANDA:USDEGP"}
        """
        task?.send(.string(message)) { _ in }
    }
    
    private func receive() {
        task?.receive { [weak self] result in
            if case .success(let message) = result {
                if case .string(let text) = message {
                    print(text)
                }
                self?.receive()
            }
        }
    }
}
