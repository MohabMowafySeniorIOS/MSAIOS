//
//  Extention+Date.swift
//  SIN
//
//  Created by Mohab Mowafy on 30/03/2024.
//

import Foundation
extension Date {
    
    func toString(withFormat format: String = "E, d MMM yyyy HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
    func toStandardString(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
        let dateFormatter = DateFormatter()
        if L102Language.currentAppleLanguage() == arabicLang {
            if format == "hh:mm a" {
                dateFormatter.locale = Locale(identifier: "ar")
            }else {
                dateFormatter.locale = Locale(identifier: "en_US")
            }
           
        }else {
            dateFormatter.locale = Locale(identifier: "en_US")
       }
       
        dateFormatter.dateFormat = format
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
}
