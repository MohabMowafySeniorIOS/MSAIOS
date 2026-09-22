//
//  CustomTextField.swift
//  Teck-En
//
//  Created by mohab mowafy on 20/12/2021.
//

import Foundation
import UIKit


@IBDesignable class HeaderView : UIView , UITextFieldDelegate {
   
    @IBOutlet weak var titleLabel: UILabel!
    var pressShare: (()->())?
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
      
    }
    
    
    private func commonInit(){
        let bundle = Bundle.init(for: HeaderView.self)
       
        if let viewToAd = bundle.loadNibNamed("HeaderView", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
          
           
        }
    }

    @IBAction func shareAction(_ sender: Any) {
        pressShare?()
    }
    
    
}

extension HeaderView {
    @IBInspectable var TitleLabelKey: String? {
        get { return nil }
        set(key) {
            titleLabel.text = key?.localized.capitalized
        }
    }
 
}








