//
//  ShadowView.swift
//  zoud
//
//  Created by Mohab on 8/21/21.
//

import UIKit

class ShadowView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
       
     //   self.layer.masksToBounds = false
        self.clipsToBounds = true
    }

}

    
class ShadowserviceView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .white
               
               // Add shadow
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.20).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 8

               // Add rounded corners (optional)
        self.layer.cornerRadius = 8

             
    }

}

    
