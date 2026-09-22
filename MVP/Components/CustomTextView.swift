//
//  CustomTextView.swift
//  Driving
//
//  Created by mohab mowafy on 10/12/2021.
//

import Foundation
import UIKit



enum TextViewStatus {
    case Message
    case Order_des
    case Offer_Details
    case Work_Details
    case Notes
   
}

@IBDesignable class CustomTextView : UIView , UITextViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var MessageTV: UITextView!
   
    @IBOutlet weak var BgView: UIView!
    @IBOutlet weak var ValidationLabel: UILabel!
    
    
    var textViewPlaceHolder = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
       
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
       
    }
    
    
    private func commonInit(){
        let bundle = Bundle.init(for: CustomTextView.self)
        
        if let viewToAd = bundle.loadNibNamed("CustomTextView", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        }
        
        MessageTV.delegate = self
        
        if L102Language.currentAppleLanguage() == "ar" {
            MessageTV.textAlignment = .right
        }else {
            MessageTV.textAlignment = .left
        }
       
    }
    

   
    
    func validate_Text(field:CustomTextView?) -> Bool {
        
        if field?.MessageTV.text == "" ||  field?.MessageTV.text == textViewPlaceHolder{
            BgView.borderColor = UIColor.red
           // ValidationLabel.text = "Field Requires *".localized
            ValidationLabel.isHidden = false
            return false
        }else {
            BgView.borderColor = UIColor.MainColor
            ValidationLabel.isHidden = true
            return true
        }
    }
  
   
}



// MARK: TextViewDelegate
extension CustomTextView {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        BgView.borderColor = UIColor.MainColor
        ValidationLabel.isHidden = true
        if MessageTV.text == textViewPlaceHolder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
       
       
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //300 chars restriction
        return textView.text.count + (text.count - range.length) <= 500
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == textViewPlaceHolder {
            BgView.borderColor = UIColor.TextBorderColor
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
}



//MARK: Validation TextView


// MARK: Validation All textfiled


extension CustomTextView {
    
    func ValidateTextfieldCases(item:TextViewStatus) -> Bool {
        switch item {
        
        case .Message:
            return ValidateAnyText(field: self)
        case .Order_des:
            return ValidateAnyText(field: self)
            case .Offer_Details:
                return ValidateAnyText(field: self)
        case .Work_Details:
            return ValidateAnyText(field: self)
        case .Notes:
            return ValidateAnyText(field: self)
        }
        
    }
    
}

// MARK:Validation
extension CustomTextView {
    
    func ValidateAnyText(field : CustomTextView)->Bool {

        if field.MessageTV.text == "" || field.MessageTV.text == "Type your Message Here".localized || field.MessageTV.text == nil || field.MessageTV.text == "Please enter the text of the message".localized || field.MessageTV.text == "Please enter order description".localized || field.MessageTV.text == "Please insert your comments".localized || field.MessageTV.text == "Please enter offer description".localized || field.MessageTV.text == "Please insert your comments" || field.MessageTV.text == "Please enter Work description"{
            ValidationLabel.isHidden = false
            return false
        }  else {
            ValidationLabel.isHidden = true
            return true
        }
    }
    
   
}
