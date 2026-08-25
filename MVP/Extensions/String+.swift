//
//  String+.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var replacedArabicDigitsWithEnglish: String {
        var string = self
        let map = ["٠": "0",
                   "١": "1",
                   "٢": "2",
                   "٣": "3",
                   "٤": "4",
                   "٥": "5",
                   "٦": "6",
                   "٧": "7",
                   "٨": "8",
                   "٩": "9"]
        map.forEach { string = string.replacingOccurrences(of: $0, with: $1) }
        return string
    }
    
    
}
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    
}
extension String {
    var localized: String {
        print(self,Bundle.main)
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension String {
    func trimAllSpace() -> String {
           return components(separatedBy: .whitespacesAndNewlines).joined()
      }
      
      func trimSpace() -> String {
          return self.trimmingCharacters(in: .whitespacesAndNewlines)
      }
}
extension String {
    func highlightKeyword() -> NSAttributedString {
        var currenccccy = "SAR"
        let attributed = NSMutableAttributedString(string: self)
//        if let range = self.range(of: currenccccy) {
//            let nsRange = NSRange(range, in: self)
//            attributed.addAttribute(.font, value: AppSARFont.Regular.size(20), range: nsRange)
//        }
        return attributed
    }
}
