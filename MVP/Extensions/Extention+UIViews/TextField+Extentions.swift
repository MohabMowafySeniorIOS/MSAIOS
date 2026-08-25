//
//  TextField+Extentions.swift
//  Courses
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import UIKit


extension UITextField {
    
    
    func setPadding(left: CGFloat? = 4, right: CGFloat? = 4){
           if let left = left {
               let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
               self.leftView = paddingView
               self.leftViewMode = .always
           }
           
//           if let right = right {
//               let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
//               self.rightView = paddingView
//               self.rightViewMode = .always
//           }
       }
      @IBInspectable var padding: CGFloat {
          get {
              return self.padding
          }
          set {
              let view = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.height))
              self.leftView = view
              self.leftViewMode = .always
              self.rightView = view
              self.rightViewMode = .always
          }
      }
}

extension String {
public var arToEnDigits : String {
  let arabicNumbers = ["٠": "0","١": "1","٢": "2","٣": "3","٤": "4","٥": "5","٦": "6","٧": "7","٨": "8","٩": "9"]
  var txt = self
  arabicNumbers.map { txt = txt.replacingOccurrences(of: $0, with: $1)}
  return txt
} }

import UIKit
@IBDesignable
class DesignableUITextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
            
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
}
extension UITextField{
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
   
    
}

