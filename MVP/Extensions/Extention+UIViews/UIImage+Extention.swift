//
//  UIImage+Extention.swift
//  zoud
//
//  Created by Mohab on 9/5/21.
//

import Foundation
import UIKit

import UIKit
class Leftarrow: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "arrow right")
    let checkedImage = #imageLiteral(resourceName: "Left arrow ")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}
class signOut: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "Frame 37127 (4)")
    let checkedImage = #imageLiteral(resourceName: "Frame 37127 (2)")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}

class buttonLanguage: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang {
            self.setImage(self.imageView?.image?.withHorizontallyFlippedOrientation(), for: .normal)
        
        }
       
    }
}

class imageLanguage: UIImageView {
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == englishLang {
            self.image = self.image?.withHorizontallyFlippedOrientation()
        }
        
    }
    
}
