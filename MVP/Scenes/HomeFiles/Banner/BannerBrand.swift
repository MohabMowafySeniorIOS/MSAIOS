//
//  BannerBrand.swift
//  MSA
//
//  ألوان البراند المستخدمة في البانر — مأخوذة من Brand Assets / Colors.ai.
//
//  معرّفة هنا محلياً عشان فولدر البانر يشتغل من غير ما يعتمد على أي حاجة
//  تانية في المشروع. لما تنقل ألوان البراند للـ asset catalog، امسح
//  الملف ده وبدّل الأسماء بالمقابل بتاعها.
//

import UIKit

enum BannerBrand {

    /// الذهبي الأساسي — #E8B138
    static let gold = UIColor(red: 0.910, green: 0.694, blue: 0.220, alpha: 1)

    /// الكريمي — بداية التدرج الذهبي — #FEFBF4
    static let cream = UIColor(red: 0.996, green: 0.984, blue: 0.957, alpha: 1)

    /// الحبر — النص فوق أي خلفية ذهبية — #150F0E
    static let ink = UIColor(red: 0.082, green: 0.059, blue: 0.055, alpha: 1)

    /// خلفية الكارت قبل ما الميديا تحمّل — #1A1211
    static let placeholder = UIColor(red: 0.102, green: 0.071, blue: 0.067, alpha: 1)

    /// التدرج الذهبي: كريمي ← ذهبي. بيتستخدم في زرار "اعرف أكثر".
    static var goldGradientColors: [CGColor] {
        [cream.cgColor, gold.cgColor]
    }
}
