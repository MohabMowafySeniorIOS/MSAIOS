//
//  FAQViewModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI
class FAQViewModel: ObservableObject {
   
    @Published var ModelFAQ = [FAQModel]()
    
    init() {
        getFAQS()
    }
    
    
    func getFAQS() {
        let db = Firestore.firestore()
        
        db.collection("FAQ").addSnapshotListener {[weak self] snapshot, error in
            guard let self = self else { return }
            guard let documents = snapshot?.documents else { return }
            
            ModelFAQ.removeAll()
            for doc in documents {
                var type = doc.documentID as? String
                let data = doc.data()
                var question = L102Language.currentAppleLanguage() == "ar" ? data["qestion_ar"] as? String : data["qestion_en"] as? String
                let answer  =  L102Language.currentAppleLanguage() == "ar" ? data["answer_ar"] as? String : data["answer_en"] as? String
             
                ModelFAQ.append(FAQModel(question: question, answer: answer))
            }
            
        }
    }
   
}

