//
//  Validator.swift
//  Sin
//
//  Created by Mohab Mowafy on 19/03/2024.
//

import Foundation
import Foundation

class Validator {
    class func validate(email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
    
    class func validate(phone: String) -> Bool {

        let phoneRegEx = "[0]{1}+[5]{1}+[0-9]{8}"
        let phoneRegEx1 = "[5]{1}+[0-9]{8}"
        
                    let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        
        if NSPredicate(format:"SELF MATCHES %@", phoneRegEx).evaluate(with: phone) {
            return true
        }else if NSPredicate(format:"SELF MATCHES %@", phoneRegEx1).evaluate(with: phone) {
            return true
        }else {
            return false
        }
      
       
    }
    
    class func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    class func isValidPassword(password: String) -> Bool {
        let urlRegEx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*/-]).{6,}$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: password)
        return result
    }
}
