//
//  extention+image.swift
//  Dar Driving
//
//  Created by Mohab on 10/21/21.
//

import Foundation
import UIKit
extension UIImageView {
    @IBInspectable var imageColor: UIColor? {
        get { return nil }
        set(key) {
            self.image = self.image?.withTintColor(UIColor.MainColor ?? UIColor.blue)
        }
    }
}


extension UIImageView {
    @IBInspectable var imageSecondayColor: UIColor? {
        get { return nil }
        set(key) {
            self.image = self.image?.withTintColor(UIColor.SecondarColor ?? UIColor.blue)
        }
    }
}
