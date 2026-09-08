//
//  BGSwiftUIView.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Foundation
import SwiftUI

/// خلفية كل شاشات التطبيق — نفس `MSABackground` في أندرويد بالظبط.
///
/// الخلفية بقت صورة واحدة جاهزة بأشكال الهوية بدل ثلاث طبقات:
///   • قبل: تدرّج + لمعة ذهب + نقشة بشفافية 15%
///   • دلوقتي: لون أساس + الصورة كاملة الوضوح
///
/// الصورة نفسها فيها التدرّج والأشكال، فاللمعة الذهبية اتشالت — كانت
/// هتغيّر ألوان التصميم لو فضلت فوقه. اللون الأساس تحتها بلون الصورة
/// الغالب عشان لو الشاشة أطول من نسبة الصورة، الفراغ يبقى بنفس اللون.
struct BGSwiftUIView: View {

    var body: some View {
        ZStack {

            // MARK: - Base Color
            // #2E2020 — اللون الغالب في صورة الخلفية
            Color(red: 0.180, green: 0.125, blue: 0.125)

            // MARK: - Brand Background
            Image("BGImage")
                .resizable()
                .scaledToFill()
        }
        .ignoresSafeArea() // يملأ الشاشة كلها
    }
}
