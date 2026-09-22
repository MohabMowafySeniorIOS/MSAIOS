//
//  CustomTextFieldMobile.swift
//  Teck-En
//
//  Created by mohab mowafy on 22/12/2021.
//

import Foundation
import Foundation
import UIKit





@IBDesignable class CustomTextFieldMobile : UIView , UITextFieldDelegate {
    
    @IBOutlet weak var ValidationStack: UIStackView!
    @IBOutlet weak var CountryCode: UILabel!
    
    @IBOutlet weak var BgStackView: UIStackView!
    @IBOutlet weak var CountryFlag: UIImageView!
    
    @IBOutlet weak var BgView: UIView!
    
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var NameTF: UITextField!
    @IBOutlet weak var ValidationLabel: UILabel!
    var phone_length = 10
   
    var Select_press : (()->())?
    
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
        
        if let viewToAd = bundle.loadNibNamed("CustomTextFieldMobile", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
            self.NameTF.delegate = self
        }
    }
    
    func validate_Phone(field:CustomTextFieldMobile?) -> Bool {
        
        if field?.NameTF.text == ""  {
            BgStackView.borderColor = UIColor.red
            ValidationLabel.text = "Phone Number Is Required".localized
            ValidationStack.isHidden = false
            return false
        }else {
            
//            if field?.NameTF.text?.count != phone_length {
//                BgStackView.borderColor = UIColor.red
//                ValidationLabel.text = "Phone Is Not Valid".localized
//                ValidationStack.isHidden = false
//                return false
//            }else {
//                BgStackView.borderColor = UIColor.MainColor
//                ValidationStack.isHidden = true
//               return true
//            }
            
            
            if Validator.validate(phone: (field?.NameTF.text ?? "").arToEnDigits) {
                BgStackView.borderColor = UIColor.MainColor
                ValidationStack.isHidden = true
                return true
             
           }else {
              
               BgStackView.borderColor = UIColor.red
               ValidationLabel.text = "Phone Is Not Valid".localized
               ValidationStack.isHidden = false
               return false
           }
            
           
        }
    }
   
    func ConfigratioTextField(){
       
       
        BgStackView.semanticContentAttribute = .forceLeftToRight
        BgView.semanticContentAttribute = .forceLeftToRight
        let centeredParagraphStyle = NSMutableParagraphStyle()
       
        
        self.NameTF.delegate = self
        self.NameTF.placeholder = "enterPhoneNumber".localized
        self.ValidationLabel.text = "Field Requires *".localized
        self.ValidationLabel.isHidden = true
        
        
    }
    
    func validatePhone(field:CustomTextFieldMobile?) -> Bool {
        let phoneRegEx = "[05]{1}+[0-9]{8}"
                    let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)

        if field?.NameTF.text == "" {
            BgStackView.borderColor = UIColor.red
            ValidationLabel.text = "Field Requires *".localized
            ValidationStack.isHidden = false
            return false
        }else {
            
            if !phoneTest.evaluate(with: field?.NameTF?.text) {
                BgStackView.borderColor = UIColor.red
                ValidationLabel.text = "startFive".localized
                ValidationStack.isHidden = false
              return false
           }else {
               BgStackView.borderColor = UIColor.TextBorderColor
               ValidationStack.isHidden = true
               return true
           }
           
          
        }
        
        
    }
    
    func Configration_text(){
        
        BgStackView.semanticContentAttribute = .forceLeftToRight
        BgView.semanticContentAttribute = .forceLeftToRight
        let centeredParagraphStyle = NSMutableParagraphStyle()
       
        
        self.NameTF.delegate = self
        self.NameTF.placeholder = "enterPhoneNumber".localized
        self.ValidationLabel.text = "Field Requires *".localized
        self.ValidationLabel.isHidden = true
        
        titleLabel.textColor = UIColor.black
        NameTF.textColor = UIColor.black
        BgView.backgroundColor = UIColor.white
        BgView.borderColor = UIColor.TextBorderColor
     
        CountryCode.textColor = UIColor.black
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        BgStackView.borderColor = UIColor.MainColor
        ValidationStack.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            BgStackView.borderColor = UIColor.TextBorderColor
        }
        
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        NameTF.text = NameTF.text?.arToEnDigits
        if textField == NameTF {
            if let text = textField.text , text.count > phone_length {
    
                let truncatedText = String(text.prefix(phone_length))
                NameTF.text = truncatedText
            }
        }
    }

    @IBAction func SelectAction(_ sender: Any) {
        Select_press?()
    }
    
    
  
}



