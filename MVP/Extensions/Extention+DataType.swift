//
//  Extention+DataType.swift
//  SIN
//
//  Created by Mohab Mowafy on 18/04/2024.
//

import Foundation

extension Int? {
    func ToString()->String{
        return "\(self ?? 0)"
    }
    
    
    func ToDouble()->Double{
        return Double(self ?? 0)
    }

}
