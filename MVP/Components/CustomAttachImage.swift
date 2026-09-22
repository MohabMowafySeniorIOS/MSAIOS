//
//  CustomAttachImage.swift
//  Dar Driving
//
//  Created by Mohab on 10/21/21.
//

import Foundation
import Foundation
import Foundation
import UIKit


@IBDesignable class CustomAttachImage : UIView  {
    
   
    @IBOutlet weak var BgImage: UIImageView!
    @IBOutlet weak var ValidationLabel: UILabel!
    @IBOutlet weak var AttachImg: UIImageView!
    
    var Press_image : (()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    
    private func commonInit(){
        let bundle = Bundle.init(for: CustomAttachImage.self)
        
        if let viewToAd = bundle.loadNibNamed("CustomAttachImage", owner: self, options: nil) , let contentView = viewToAd.first as? UIView {
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        }
    }
    

    func ConfigrationImage(title:String,ValidationLabel : String , AttachImg : UIImage? , ShowValidation : Bool) {
        self.AttachImg.image = AttachImg
        self.ValidationLabel.attributedText = ValidationLabel.highlightKeyword()
        self.ValidationLabel.isHidden = !ShowValidation
        if AttachImg == nil {
            BgImage.isHidden = false
        }else {
            BgImage.isHidden = true
        }
    }
    
   
    
    @IBAction func PressImageAction(_ sender: Any) {
        Press_image?()
    }
    
   
    
}




