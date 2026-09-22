//
//  FAQViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Combine
import Foundation
import SwiftUI

/// الأسئلة الشائعة — من لوحة التحكم بدل Firestore.
///
/// السيرفر بيرجّع اللغتين مع بعض، والاختيار بيحصل في `APIFaq`،
/// فتغيير اللغة مبيحتاجش طلب جديد للشبكة.
class FAQViewModel: ObservableObject {

    @Published var ModelFAQ = [FAQModel]()

    init() {
        getFAQS()
    }

    func getFAQS() {
        Task { @MainActor in
            await ContentStore.shared.loadFaqs(force: true)
            ModelFAQ = ContentStore.shared.faqs.map {
                FAQModel(question: $0.question, answer: $0.answer)
            }
        }
    }
}
