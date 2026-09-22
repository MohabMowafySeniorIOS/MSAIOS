//
//  CustomButtonView.swift
//  SIN
//
//  Created by Mohab Mowafy on 26/08/2024.
//

import Foundation

import Foundation
import UIKit



@IBDesignable class CustomButtonView : UIView {
    @IBOutlet weak var ConfirmBtn: GoldButton!
    var Press_next : (()->())?
    
    
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
        
        if let viewToAd = bundle.loadNibNamed("CustomButtonView", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
            
            
        }
    }
    @IBAction func NextAction(_ sender: Any) {
        Press_next?()
    }
}
