//
//  CalculatorHomeView.swift
//  MSA
//
//  Created by Mohab Mowafy on 25/04/2026.
//

import Foundation

import SwiftUI
import UIKit
class CalculatorHomeVC: UIHostingController<bullionsScreenView> {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: bullionsScreenView())
    }

    /*
     مفيش `bindScreenMaintenance` هنا عن قصد.

     الغطا بتاع UIKit بيتحط كـsubview على `view`، و`view` هنا
     `_UIHostingView` — شجرة SwiftUI بتملكها وبتعيد بناءها مع كل
     تحديث حالة. أي عنصر بتضيفه SwiftUI بعد كده بيتحط **فوق** الغطا،
     فالكارت بيختفي ورا المحتوى من غير سبب واضح.

     الجيت متحط جوّه `bullionsScreenView` نفسها بـ
     `ScreenMaintenanceObserver` — نفس اللي شاشة الفيدرالي بتعمله.
     */
}


struct CalculatorHomeSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    let items = [
        ("Gold Calculator", "bitcoinsign.circle"),
        ("Zakat Gold", "dollarsign.circle"),
        ("Silver Calculator", "circle.grid.2x2"),
        ("Zakat Silver", "percent")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        
        ZStack {
            BGSwiftUIView()
            content
        }
           
               
       
        
    }
    
    
    var content: some View {
       VStack(spacing: 24) {
           headerView(title: "Calculator".localized, isBackShow: true) {
               dismiss()
           } .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
              
               
           
            LazyVStack(spacing: 16) {
//                PremiumCard(title: "Bullions".localized, icon: "ingots", onTap: {
//                    let destination: AnyView = AnyView(bullionsScreenView())
//                    let hostingController = UIHostingController(rootView: destination)
//                    if let topVC = UIApplication.shared.connectedScenes
//                        .compactMap({ $0 as? UIWindowScene })
//                        .flatMap({ $0.windows })
//                        .first(where: { $0.isKeyWindow })?
//                        .rootViewController?.topMostViewController() {
//                        topVC.tabBarController?.tabBar.isHidden = true
//                        if let nav = topVC.navigationController {
//                            nav.pushViewController(hostingController, animated: true)
//                        } else {
//                            topVC.present(hostingController, animated: true)
//                        }
//                    }
//                })
                
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items, id: \.0) { item in
                        PremiumCard(title: item.0.localized, icon: item.1, onTap: {
                            let destination: AnyView
                            switch item.0 {
                           
                            case "Gold Calculator":
                                destination = AnyView(GoldValueCalculatorView())
                            case "Zakat Gold":
                                destination = AnyView(ZakatView())
                            case "Silver Calculator":
                                destination = AnyView(SilverCalculatorView())
                            case "Zakat Silver":
                                destination = AnyView(SilverZakatView())
                            default:
                                destination = AnyView(GoldValueCalculatorView())
                            }
                            
                            let hostingController = UIHostingController(rootView: destination)
                            if let topVC = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .flatMap({ $0.windows })
                                .first(where: { $0.isKeyWindow })?
                                .rootViewController?.topMostViewController() {
                                topVC.tabBarController?.tabBar.isHidden = true
                                if let nav = topVC.navigationController {
                                    nav.pushViewController(hostingController, animated: true)
                                } else {
                                    topVC.present(hostingController, animated: true)
                                }
                            }
                        })
                        
                    }
                }
                
            }
            
            .padding(.horizontal)
                .onAppear {
                   
                    if let topVC = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?
                        .rootViewController?.topMostViewController() {
                       
                       
                    }
                       
                }
            
        
            
            Spacer()
           
        }
    }
    
    var header: some View {
        headerView(title: "Calculator".localized, isBackShow: true, onDismiss: {
            dismiss()
        },isShowLogo: true)
            
    }
}

struct headerView: View {
    var title: String
    var isBackShow: Bool
    var onDismiss: (() -> Void)?
    var isShowLogo: Bool = true
    
    @State private var showShare = false

      let appleId = "6767865490"
    var body: some View {
        ZStack {
            if isBackShow {
                HStack {
                    
                    Button {
                        onDismiss?()
                    } label: {
                        Image(L102Language.currentAppleLanguage() == "ar" ? "arrow-right 3" : "arrow-left 3")
                           
                    }
                    Spacer()
                }
            }
           
           
            HStack {

              
                Spacer()
                VStack(spacing: 6) {
                    HStack {
//                        if isShowLogo ?? false {
//                            Image("MSALogo")
//                                .resizable()
//                                .frame(width: 70,height: 60)
//                                .scaledToFit()
//                        }
                        Text(title.localized)
                            .font(.msa(24, weight: .bold))
                            .foregroundColor(.white)
                        
                    }
                   
                    
                }
                
                Spacer()
                if !isBackShow {
                    Image("shared")
                        .resizable()
                        .frame(width: 24,height: 24)
                        .onTapGesture {
                            showShare = true
                           
                        }
                        .sheet(isPresented: $showShare) {

                                    ActivityView(

                                        items: [

                                            URL(

                                                string: "https://apps.apple.com/app/id\(appleId)"

                                            )!

                                        ]

                                    ).presentationDetents([.medium])

                                }
                }
                
            }

           
        }
        .padding(.horizontal)
        .padding(.top, 20)

    }
    
//    func shareApp(){
//        var AppleId = "6767865490"
//        ShareLink(
//            item: URL(string: "https://apps.apple.com/app/id/\(AppleId)")!
//        ) {
//            Label(
//                "مشاركة التطبيق",
//                systemImage: "square.and.arrow.up"
//            )
//        }
//       
//      
//    }
}

import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {

    let items: [Any]

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {

        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
//////////////////////////////////////////////////////////////
// MARK: - CARD (NEW DESIGN)
//////////////////////////////////////////////////////////////

struct PremiumCard: View {
    
    var title: String
    var icon: String
    var onTap: (() -> Void)
    
    @State private var pressed = false
    
    var body: some View {
        VStack(spacing: 14) {
            if icon == "ingots" {
                Image(icon)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .font(.msa(36))
                    .foregroundColor(Color(hexString: "#F2D28C"))
            }else {
                Image(systemName: icon)
                    .font(.msa(36))
                    .foregroundColor(Color(hexString: "#F2D28C"))
            }
           
            
            Text(title)
                .font(.msa(16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
        .onTapGesture {
            onTap()
        }
        
        // 💎 Border دهبي subtle
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hexString: "#F2D28C"),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        
        // Shadow خفيف (مش glow مبالغ فيه)
        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 6)
        
        // ✨ Press effect
        .scaleEffect(pressed ? 0.96 : 1)
        .animation(.easeInOut(duration: 0.15), value: pressed)
        
        .onTapGesture {
            pressed = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                pressed = false
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - HEX
//////////////////////////////////////////////////////////////

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        self.init(
            .sRGB,
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255,
            opacity: 1
        )
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}

