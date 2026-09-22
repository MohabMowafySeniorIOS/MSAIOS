//
//  ZakatViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import Foundation
import SwiftUI

/// زكاة الفضة — نفس حساب أندرويد بالظبط (ZakatCalculator.silverZakat).
///
///  النقاء بمقياس الألف (millesimal): عيار 925 = 92.5% فضة خالصة،
///  يعني القسمة على 1000 مش على 999.
///  النصاب: 595 جرام فضة خالصة
///  الزكاة: 2.5% من الفضة الخالصة، وقيمتها = جرامات الزكاة × سعر جرام عيار 999
class ZakatViewModel: ObservableObject {

    @Published var items: [SilverItem] = [
        SilverItem(karat: 999),
        SilverItem(karat: 925),
        SilverItem(karat: 900),
        SilverItem(karat: 800),
        SilverItem(karat: 600)
    ]

    @Published var zakatAmount: Double = 0
    @Published var totalPureSilver: Double = 0
    /// قيمة الزكاة بالجنيه — كانت ناقصة خالص، الشاشة كانت بتعرض الجرامات بس
    @Published var zakatValue: Double = 0
    @Published var message: String = ""

    let nisab: Double = 595 // نصاب الفضة

    /// سعر جرام الفضة عيار 999 من Firestore
    var pricePerGram999: Double {
        Double(metalPriceValue.silverPrice?.salePrice ?? "") ?? 0
    }

    func calculate() {
        var total: Double = 0

        for item in items {
            let weight = Double(item.weight) ?? 0
            let purity = Double(item.karat) / 1000.0

            total += weight * purity
        }

        totalPureSilver = total

        if total >= nisab {
            zakatAmount = total * 0.025
            // تقريب مقبول: سعر عيار 999 كسعر للجرام الخالص (فرق 0.1%)
            zakatValue = zakatAmount * pricePerGram999
            message = "✅ الزكاة واجبة"
        } else {
            zakatAmount = 0
            zakatValue = 0
            message = "❌ لم تبلغ النصاب"
        }
    }
}
