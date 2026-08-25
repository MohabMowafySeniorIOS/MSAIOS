//
//  FAQModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Foundation
struct FAQModel {
    let question: String?
    let answer: String?
    var isExpanded: Bool = false
    
   mutating func togle() {
        isExpanded.toggle()
    }


}
