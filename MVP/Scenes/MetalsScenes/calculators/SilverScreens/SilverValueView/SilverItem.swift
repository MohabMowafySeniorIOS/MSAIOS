//
//  SilverItem.swift
//  MSA
//
//  Created by Mohab Mowafy on 17/04/2026.
//

import Foundation
// MARK: - Model
struct SilverItem: Identifiable {
    let id = UUID()
    let karat: Int
    var weight: String = ""
    var result: Double = 0
}
