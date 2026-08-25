//
//  UIFOnt+Extention.swift
//  SIN
//
//  Created by Mohab Mowafy on 27/03/2024.
//

import Foundation
import UIKit


extension UILabel {
    
    @IBInspectable var FontRegularSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontBoldSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontsemiboldSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontExtraLightSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
   
    
    @IBInspectable var FontLightSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontMediumSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Medium.size(newValue + 2)
            }
           
        }
    }
    
  
    @IBInspectable var FontThinSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    
}

extension UITextField {
    @IBInspectable var FontRegularSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontBoldSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontsemiboldSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontExtraLightSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
   
    
    @IBInspectable var FontLightSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontMediumSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Medium.size(newValue + 2)
            }
           
        }
    }
    
  
    @IBInspectable var FontThinSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
}

extension UITextView {
    @IBInspectable var FontRegularSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontBoldSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontsemiboldSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontExtraLightSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
   
    
    @IBInspectable var FontLightSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontMediumSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Medium.size(newValue + 2)
            }
           
        }
    }
    
  
    @IBInspectable var FontThinSize: CGFloat {
        get {
            return self.font?.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
}


extension UIButton {
    @IBInspectable var FontRegularSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontBoldSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontsemiboldSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.bold.size(newValue + 2)
            }
           
        }
    }
    
    
    @IBInspectable var FontExtraLightSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
   
    
    @IBInspectable var FontLightSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
    
    @IBInspectable var FontMediumSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.Medium.size(newValue + 2)
            }
           
        }
    }
    
  
    @IBInspectable var FontThinSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 12
        }
        set {
            if newValue > 0 {
                self.titleLabel?.font = AppFont.Regular.size(newValue + 2)
            }
           
        }
    }
}
