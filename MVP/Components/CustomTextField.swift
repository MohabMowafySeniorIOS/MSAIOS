//
//  CustomTextField.swift
//  Teck-En
//
//  Created by mohab mowafy on 20/12/2021.
//

import Foundation
import UIKit


enum ValidationOnText {
    case LettresOnlyWith50Num
    case LettersAndNumbersWith50char
    case IbanNumber
}


@IBDesignable class CustomTextField : UIView , UITextFieldDelegate {
    @IBOutlet weak var EmojiIcon: UIImageView!
    @IBOutlet weak var CurrencyLabel: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var CurrencyView: UIView!
    @IBOutlet weak var EmojyView: UIView!
    @IBOutlet weak var stackBGView: UIStackView!
    @IBOutlet weak var IconImageTrailing: NSLayoutConstraint!
    @IBOutlet weak var IconImg: UIImageView!
    @IBOutlet weak var BgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var NameTF: UITextField!
    @IBOutlet weak var SeeBtn: UIButton!
    @IBOutlet weak var ValidationStack: UIStackView!
    @IBOutlet weak var ValidationLabel: UILabel!
  
    var Press_Emoji : (()->())?
    
    var Validation_item : ValidationOnText? = nil
    
    
    @IBOutlet weak var clearBtn: UIButton!
    var Press_select : (()->())?
    var Press_See : (()->())?
    
    var ValidationString = ""
    
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
      
    }
    
    
    private func commonInit(){
        let bundle = Bundle.init(for: CustomTextField.self)
       
        if let viewToAd = bundle.loadNibNamed("CustomTextField", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
            NameTF.delegate = self
           
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if Validation_item == .LettresOnlyWith50Num {
            NameTF.text = NameTF.text?.arToEnDigits
            if textField == NameTF {
                if let text = textField.text , text.count > 50 {
        
                    let truncatedText = String(text.prefix(50))
                    NameTF.text = truncatedText
                }
            }
        }else if Validation_item == .LettersAndNumbersWith50char {
            NameTF.text = NameTF.text?.arToEnDigits
            if textField == NameTF {
                if let text = textField.text , text.count > 50 {
        
                    let truncatedText = String(text.prefix(50))
                    NameTF.text = truncatedText
                }
            }
        }else if Validation_item == .IbanNumber {
            if let text = textField.text , text.count > 25 {
    
                let truncatedText = String(text.prefix(25))
                NameTF.text = truncatedText
                
               
            }
            
            if let cleanedText = removeArabicCharacters(from: NameTF.text ?? "") {
                NameTF.text = cleanedText
            } else {
                print("Failed to remove Arabic characters.")
            }
            
           
        }
        
    }
    
    func removeArabicCharacters(from text: String) -> String? {
        // Define the pattern to match Arabic characters
        let pattern = "[\u{0600}-\u{06FF}]"
        
        do {
            // Create a regular expression with the pattern
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            // Replace all matches of the regex in the text with an empty string
            let range = NSRange(location: 0, length: text.utf16.count)
            let modifiedText = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
            
            return modifiedText
        } catch {
            print("Invalid regular expression: \(error.localizedDescription)")
            return nil
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           // Define the characters allowed (in this case, letters)
        if Validation_item == .LettresOnlyWith50Num {
            let allowedCharacters = CharacterSet.letters
            let characterSet = CharacterSet(charactersIn: string)
            
            // Check if the replacement string contains only the allowed characters
            if string == " " {
                return true
            }else {
                return allowedCharacters.isSuperset(of: characterSet)
            }
        }else if Validation_item == .IbanNumber {
            let allowedCharacters = CharacterSet.alphanumerics
                  // Check if string contains only allowed characters
                  let characterSet = CharacterSet(charactersIn: string)
                  return allowedCharacters.isSuperset(of: characterSet)
        }
         return true
       }
    
    
    @IBAction func SelectEmojiAction(_ sender: Any) {
        Press_Emoji?()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        NameTF.text = ""
    }
    
    func Configuration_text(title : String , placeHolder : String , img : UIImage? , ValidationString:String){
        titleLabel.attributedText = title.highlightKeyword()
        NameTF.placeholder = placeHolder
      
        self.ValidationString = ValidationString
        ValidationLabel.attributedText = ValidationString.highlightKeyword()
        
        
    }
    
    func Configuration_Password_text(title : String , placeHolder : String , img : UIImage? , ValidationString : String){
        titleLabel.attributedText = title.highlightKeyword()
        self.ValidationLabel.attributedText = ValidationString.highlightKeyword()
        self.ValidationString = ValidationString
        NameTF.placeholder = placeHolder
       
        NameTF.isSecureTextEntry = true
        SeeBtn.isHidden = false
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        stackBGView.borderColor = UIColor.MainColor
        ValidationStack.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            stackBGView.borderColor = UIColor.TextBorderColor
        }
    }
    
    func validate_Text(field:CustomTextField?) -> Bool {
        if field?.NameTF.text == "" {
            stackBGView.borderColor = UIColor.red
           
            ValidationStack.isHidden = false
            return false
        }else {
            stackBGView.borderColor = UIColor.MainColor
            ValidationStack.isHidden = true
            return true
        }
    }
    
    
  
    
    
    func validate_email(field:CustomTextField?) -> Bool {
        
        if field?.NameTF.text == "" {
            stackBGView.borderColor = UIColor.red
        //    ValidationLabel.attributedText = "Field Required *".localized
            ValidationStack.isHidden = false
            return false
        }else {
            
            
           if Validator.validate(email: field?.NameTF.text ?? "") {
               stackBGView.borderColor = UIColor.MainColor
               ValidationStack.isHidden = true
               return true
           }else {
              
               stackBGView.borderColor = UIColor.red
               ValidationLabel.attributedText = "please check email format".localized.highlightKeyword()
               ValidationStack.isHidden = false
               return false
           }
            
           
        }
    }
    
    
    func validate_Phone(field:CustomTextField?) -> Bool {
        
        if field?.NameTF.text == "" {
            stackBGView.borderColor = UIColor.red
            ValidationLabel.attributedText = "Phone Number Is Required".localized.highlightKeyword()
            ValidationStack.isHidden = false
            return false
        }else {
            
            
            
            
            if Validator.validate(phone: (field?.NameTF.text ?? "").arToEnDigits) {
               
               stackBGView.borderColor = UIColor.TextBorderColor
               ValidationStack.isHidden = true
               return true
           }else {
              
               stackBGView.borderColor = UIColor.red
               ValidationLabel.attributedText = "Phone Is Not Valid".localized.highlightKeyword()
               ValidationStack.isHidden = false
               return false
           }
            
           
        }
    }
   
    @IBAction func SeeAction(_ sender: Any) {
        self.IconImg.image = NameTF.isSecureTextEntry == true  ? UIImage(named: "security") : UIImage(named: "security (2)")
        NameTF.isSecureTextEntry = !NameTF.isSecureTextEntry
    }
    
    
    
    
    @IBAction func SelectAction(_ sender: Any) {
        Press_select?()
    }
}








extension CustomTextField {
    @IBInspectable var TitleLabelKey: String? {
        get { return nil }
        set(key) {
            titleLabel.text = key?.localized.capitalized
        }
    }
    
    @IBInspectable var TextLabelKey: String? {
        get { return nil }
        set(key) {
            NameTF.text = key?.localized.capitalized
        }
    }
    
    @IBInspectable var CurrencyLabelKey: String? {
        get { return nil }
        set(key) {
            CurrencyLabel.text = key?.localized.capitalized
            if key?.isEmpty == true {
                CurrencyLabel.isHidden = true
            }else {
                CurrencyLabel.isHidden = false
            }
        }
    }
    
    
    @IBInspectable var showClearBtnbelKey: String? {
        get { return nil }
        set(key) {
            if key == "1" {
                clearBtn.isHidden = false
            }else {
                clearBtn.isHidden = true
            }
            
        }
    }
    
    @IBInspectable var placeHolderKey: String? {
        get { return nil }
        set(key) {
            NameTF.placeholder = key?.localized.capitalized
        }
    }
    
    @IBInspectable var ErrorMessageKey: String? {
        get { return nil }
        set(key) {
            ValidationLabel.text = key?.localized.capitalized
        }
    }
    

    @IBInspectable var IconImge: UIImage? {
        get { return nil }
        set(key) {
           
        
                IconImg.image = key
           
          
        }
      }
    
    @IBInspectable var Icon_arrow_Imge: UIImage? {
        get { return nil }
        set(key) {
           
            if L102Language.currentAppleLanguage() == arabicLang {
                IconImg.image = UIImage(named: "arrow-left 2")
            }else {
                IconImg.image = UIImage(named: "arrow-right 2")
            }
          
        }
      }
}
