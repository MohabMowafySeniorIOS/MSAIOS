//
//  Font+MSA.swift
//  MSA
//
//  خطوط الواجهة في SwiftUI.
//
//  `AppFont` الموجودة بتشتغل مع UIKit (`UIFont`)، لكن شاشات SwiftUI
//  بتستخدم `Font` وكانت بتنده `.system(...)` يعني خط النظام.
//  الامتداد ده بيوحّد المصدر: كل النصوص على IBM Plex Sans Arabic،
//  والعناوين الكبيرة على Lafet خط الهوية.
//

import SwiftUI

extension Font {

    /// النص العادي
    static func msa(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black:      name = "\(FontfamilyName)-Bold"
        case .semibold, .medium:         name = "\(FontfamilyName)-Medium"
        default:                         name = "\(FontfamilyName)-Regular"
        }
        // لو الخط مش متسجّل لأي سبب نرجع لخط النظام بدل ما النص يختفي
        return UIFont(name: name, size: size) != nil
            ? .custom(name, size: size)
            : .system(size: size, weight: weight)
    }

    /// خط العناوين من الهوية — للعناوين الكبيرة بس
    static func msaDisplay(_ size: CGFloat) -> Font {
        let name = "\(DisplayFontFamilyName)-Bold"
        return UIFont(name: name, size: size) != nil
            ? .custom(name, size: size)
            : .msa(size, weight: .bold)
    }
}
