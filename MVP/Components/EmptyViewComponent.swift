//
//  EmptyViewComponent.swift
//  SIN
//
//  Created by Mohab Mowafy on 28/08/2024.
//


import Foundation
import UIKit



@IBDesignable class EmptyViewComponent : UIView {
  
    @IBOutlet weak var SecondBtnLabel: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DesLabel: UILabel!
    @IBOutlet weak var FirstBtn: CustomButtonView!
    @IBOutlet weak var SecondBtn: UIButton!
    
    @IBOutlet weak var BackToHomeView: UIView!
    var Press_BackToHome :(()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
        
    }
    
    
    private func commonInit(){
        let bundle = Bundle.init(for: EmptyViewComponent.self)
        
        if let viewToAd = bundle.loadNibNamed("EmptyViewComponent", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
            
            
        }
    }
    
    
    func Configration_cell(Icon:UIImage,TitleLabel:String,DesLabel:String){
        self.Icon.image = Icon
        self.TitleLabel.text = TitleLabel
        self.DesLabel.text = DesLabel
        FirstBtn.Press_next = {
            Helper.restartApp()
        }
        
    }
   
    @IBAction func BackToHomeHomeAction(_ sender: Any) {
        Helper.restartApp()
    }
    
    
    
    
}
extension EmptyViewComponent {
    @IBInspectable var TitleLabelKey: String? {
        get { return nil }
        set(key) {
            TitleLabel.text = key?.localized
            
            if (key?.count ?? 0) > 0 {
                self.TitleLabel.isHidden = false
            }else {
                self.TitleLabel.isHidden = true
            }
        }
    }
    
    
    @IBInspectable var DesLabelKey: String? {
        get { return nil }
        set(key) {
            DesLabel.text = (key?.localized ?? "")
            
            if (key?.count ?? 0) > 0 {
                self.DesLabel.isHidden = false
            }else {
                self.DesLabel.isHidden = true
            }
        }
    }
    
    
    @IBInspectable var FirstBtnKey: String? {
        get { return nil }
        set(key) {
            FirstBtn.ConfirmBtn.setTitle(key?.localized, for: .normal)
            
            if (key?.count ?? 0) > 0 {
                self.FirstBtn.isHidden = false
            }else {
                self.FirstBtn.isHidden = true
            }
        }
    }
    
    @IBInspectable var secondBtnKey: String? {
        get { return nil }
        set(key) {
            SecondBtnLabel.text = key?.localized
            
            if (key?.count ?? 0) > 0 {
                self.SecondBtn.isHidden = false
            }else {
                self.SecondBtn.isHidden = true
            }
        }
    }
    
    @IBInspectable var Icon_Key: UIImage? {
        get { return nil }
        set(key) {
            Icon.image = key
            if key == nil {
                self.Icon.isHidden = true
            }else {
                self.Icon.isHidden = false
            }
        }
    }
    
    @IBInspectable var show_first_btn: String? {
        get { return nil }
        set(key) {
            FirstBtn.isHidden = key == "false" ? true : false
           
        }
    }
    
   
}
