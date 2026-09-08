//
//  ZakatVM.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import Foundation

/// زكاة الذهب — نفس حساب أندرويد بالظبط (ZakatCalculator.goldZakat).
///
///  التحويل لعيار 24:  g24 + g22×22/24 + g21×21/24 + g18×18/24
///  النصاب: 85 جرام ذهب خالص
///  الزكاة: 2.5% من الذهب الخالص، وقيمتها = جرامات الزكاة × سعر جرام عيار 24
class ZakatVM: ObservableObject {

    /// سعر جرام عيار 24 — محسوب من سعر عيار 21 الجاي من Firestore.
    /// كان مكتوب بقيمة ثابتة 8200 وميتحدّثش أبداً، فكل النتايج كانت غلط.
    var price24: Double {
        let base21 = Double(metalPriceValue.goldPrice?.salePrice ?? "") ?? 0
        return base21 * (24.0 / 21.0)
    }

    @Published var w24 = ""
    @Published var w22 = ""
    @Published var w21 = ""
    @Published var w18 = ""

    /// إجمالي الذهب الخالص بالجرام (مكافئ عيار 24)
    @Published var totalPureGold: Double = 0
    /// مقدار الزكاة بالجرام
    @Published var zakatGrams: Double = 0
    /// قيمة الزكاة بالجنيه
    @Published var zakat: Double = 0
    @Published var showAlert = false

    let nisab: Double = 85

    func calculate() {
        let g24 = Double(w24) ?? 0
        let g22 = Double(w22) ?? 0
        let g21 = Double(w21) ?? 0
        let g18 = Double(w18) ?? 0

        // تحويل لعيار 24
        let total24 =
        g24 +
        (g22 * 22/24) +
        (g21 * 21/24) +
        (g18 * 18/24)

        totalPureGold = total24

        // تحقق من النصاب
        if total24 < nisab {
            zakatGrams = 0
            zakat = 0
            showAlert = true
            return
        }

        zakatGrams = total24 * 0.025
        zakat = zakatGrams * price24
    }
}
