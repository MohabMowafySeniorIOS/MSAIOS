//
//  NoNetView.swift
//  RoyalCatsStore
//
//  Created by ebtsam on 9/3/20.
//  Copyright © 2020 Tahaqom. All rights reserved.
//

import UIKit

class NoNetView: UIView {
    @IBOutlet var contentView: UIView!
    var noNetAction : (()->())?
    var oldVC = UIViewController()
    var press_try :(()->())?

    @IBOutlet weak var ConfirmBtn: UIButton!
    override init(frame: CGRect) { // for using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit(){
        Bundle.main.loadNibNamed("NoNetView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
       
        
    }
    @IBAction func noNetBtnAction(_ sender: Any) {
       
    }

}
