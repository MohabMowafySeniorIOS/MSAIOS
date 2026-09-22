//
//  UIbuttons+Extentions.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import Foundation

import UIKit



class BackButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.setImage(UIImage(named: "arrow-right 3"), for: .normal)
           // self.setImage(#imageLiteral(resourceName: "arrow-right 3").withRenderingMode(.alwaysOriginal), for: .normal)
            
        }else {
            self.setImage(UIImage(named: "arrow-left 3"), for: .normal)
          //  self.setImage(#imageLiteral(resourceName: "arrow-left 3").withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
    }
}



class RightButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.setImage(#imageLiteral(resourceName: "arrow 2"), for: .normal)
            
            
        }else {
            self.setImage(#imageLiteral(resourceName: "arrow 1"), for: .normal)
            
        }
    }
}


class RightBackButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.setImage(#imageLiteral(resourceName: "LeftIcon"), for: .normal)
            
        }else {
            self.setImage(#imageLiteral(resourceName: "sendIcon"), for: .normal)
           
            
        }
    }
}





class BlueArrowButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.setImage(#imageLiteral(resourceName: "BlueLeftIcon"), for: .normal)
        }else {
            self.setImage(#imageLiteral(resourceName: "BlueLeftIcon"), for: .normal)
        }
    }
}
class GreenArrowButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.setImage(#imageLiteral(resourceName: "RightBack"), for: .normal)
            
        }else {
            self.setImage(#imageLiteral(resourceName: "LeftBack"), for: .normal)
            
        }
    }
}

class RefArrowButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.setImage(#imageLiteral(resourceName: "RightBack"), for: .normal)
            
        }else {
            self.setImage(#imageLiteral(resourceName: "LeftBack"), for: .normal)
            
        }
    }
}

class BlackBackLeftArrow: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang {
            self.setImage(#imageLiteral(resourceName: "Icon ionic-ios-arrow-back_left"), for: .normal)
        }else {
            self.setImage(#imageLiteral(resourceName: "Icon ionic-ios-arrow-back"), for: .normal)
        }
    }
}

class BlackBackRightArrow: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == englishLang {
            self.setImage(#imageLiteral(resourceName: "Icon ionic-ios-arrow-back_left"), for: .normal)
        }else {
            self.setImage(#imageLiteral(resourceName: "Icon ionic-ios-arrow-back"), for: .normal)
        }
    }
}


class CheckBox: UIButton {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "UnCheckIcon")
    let checkedImage = #imageLiteral(resourceName: "Icon awesome-check-circle")
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}

class LeftGreenarrow: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "Right_next")
    let checkedImage = #imageLiteral(resourceName: "Left_next")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}


class LeftGreenImage: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "lines_right")
    let checkedImage = #imageLiteral(resourceName: "lines_left")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == englishLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}

class ArrowImage: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "arrow-right 2")
    let checkedImage = #imageLiteral(resourceName: "arrow-left 2")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == englishLang {
            self.image = uncheckedImage
        }else {
            self.image = checkedImage
        }
        
    }
    
}

class SearchArrowImage: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "search_arrow-right")
    let checkedImage = #imageLiteral(resourceName: "search_arrow-left")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang {
            self.image = uncheckedImage
        }else {
            self.image = checkedImage
        }
        
    }
    
}






class LocationArrowImage: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "svgexport-18 1")
    let checkedImage = #imageLiteral(resourceName: "svgexport-18 1")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == englishLang {
            self.image = uncheckedImage
        }else {
            self.image = checkedImage
        }
        
    }
    
}

class RigtGreenImage: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "lines_right")
    let checkedImage = #imageLiteral(resourceName: "lines_left")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}


class LeftOrangeImage: UIImageView {
    // Images
    
    
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "lines_right_orange")
    let checkedImage = #imageLiteral(resourceName: "lines_left_orange")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == englishLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}
class RigtOrangeImage: UIImageView {
    // Images
    let uncheckedImage  : UIImage = #imageLiteral(resourceName: "lines_right_orange")
    let checkedImage = #imageLiteral(resourceName: "lines_left_orange")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if L102Language.currentAppleLanguage() == arabicLang || L102Language.currentAppleLanguage() == urdoLang {
            self.image = checkedImage
            
        }else {
            self.image = uncheckedImage
        }
        
    }
    
}




class eyeButton: UIButton {
    // Images
    let checkedImage = UIImage(named: "visibility")! as UIImage
    let uncheckedImage = UIImage(named: "visibility_off_black_24dp")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
