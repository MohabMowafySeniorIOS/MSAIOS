//
//  BGSwiftUIView.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Foundation
import SwiftUI

struct BGSwiftUIView: View {
    
    var body: some View {
        ZStack {
            
            // MARK: - Base Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.07, blue: 0.07),
                    Color(red: 0.12, green: 0.12, blue: 0.12),
                    Color(red: 0.18, green: 0.18, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // MARK: - Light Effect
            LinearGradient(
                colors: [
                    Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.4),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: UnitPoint(x: 0.7, y: 0.7)
            )
           
            // MARK: - Texture
            Image("BGImage")
                .resizable()
                .scaledToFill()
                .opacity(0.15)
        }
        .ignoresSafeArea() // لو عايزه يملأ الشاشة كلها
    }
}

