//
//  GoogleAds.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/06/2026.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {

    func makeUIView(context: Context) -> BannerView {

        let bannerView = BannerView(adSize: AdSizeBanner)

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }

        bannerView.load(Request())

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
