//
//  GoldenScreen.swift
//  MSA
//
//  Created by Mohab Mowafy on 11/04/2026.
//

import Foundation
import SwiftUI

class BannerViewUIKit: UIHostingController<BannerAdView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: BannerAdView())
    }
}

class HostingGoldVC: UIHostingController<GoldScreen> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: GoldScreen())
    }
}
import SwiftUI

struct GoldScreen: View {
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Header
            HStack {
                Image("egypt_flag")
                    .resizable()
                    .frame(width: 40, height: 25)
                
                Spacer()
                
                Text("سوق الذهب")
                    .foregroundColor(.gold)
                    .font(.system(size: 22, weight: .bold))
                
                Spacer()
                
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Tabs
            HStack {
                Text("الفضة")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.darkGray)
                    .foregroundColor(.gray)
                    .cornerRadius(25)
                
                Text("الذهب 💎")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gold)
                    .foregroundColor(.black)
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            
            // Title
            VStack(spacing: 4) {
                Text("اسعار سوق الذهب المصري")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text("يخصم محل التجزئة عمولة عند شراء الكسر")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            // Table Header
            HStack {
                Text("عيار")
                Spacer()
                Text("شراء")
                Spacer()
                Text("بيع")
            }
            .foregroundColor(.gray)
            .padding(.horizontal)
            
            // Prices List
            VStack(spacing: 10) {
                PriceRow(title: "عيار 24", buy: "8148.57", sell: "8205.71")
                PriceRow(title: "عيار 21", buy: "7130.00", sell: "7180.00", highlight: true)
                PriceRow(title: "عيار 18", buy: "6111.43", sell: "6154.29")
                PriceRow(title: "عيار 14", buy: "4753.33", sell: "4786.67")
            }
            .padding(.horizontal)
            
            // Small Cards
            HStack(spacing: 10) {
                SmallCard(title: "جنيه الذهب", value: "57,440")
                SmallCard(title: "الاونصة", value: "255,198")
            }
            .padding(.horizontal)
            
            // Big Card
            HStack {
                Text("8,205,714 جنيه")
                    .font(.title2.bold())
                
                Spacer()
                
                Text("كيلو الذهب 24")
            }
            .padding()
            .background(Color.cardGray)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Bottom Cards
            HStack(spacing: 10) {
                SmallCard(title: "دولار الصاغة", value: "53.70")
                SmallCard(title: "د.دولار البنوك", value: "53.09")
                
                HStack {
                    Text("4751.50 ↑")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.greenUp)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.darkBg.ignoresSafeArea())
    }
}


struct PriceRow: View {
    var title: String
    var buy: String
    var sell: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Text(buy)
                .bold()
            
            Spacer()
            
            Text(sell)
                .bold()
        }
        .padding()
        .background(highlight ? Color.gold : Color.cardGray)
        .foregroundColor(highlight ? .black : .black)
        .cornerRadius(10)
    }
}

struct SmallCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(value)
                .bold()
                .font(.headline)
            
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardGray)
        .cornerRadius(10)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    static let gold = Color(hex: "#E8B138")
    static let darkBg = Color(hex: "#000000")
    static let cardGray = Color(hex: "#E5E5E5")
    static let darkGray = Color(hex: "#261B1A")
    static let greenUp = Color(hex: "#A5D6A7")
    static let unSelectedColor = Color(hex: "#F5F6F9")
    static let MainColor = Color(hex: "#A77F28")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}
