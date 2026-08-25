//
//  AnErrorView.swift
//  Rose
//
//  Created by Mohab on 3/6/21.
//  Copyright © 2021 MOHAB. All rights reserved.
//

import UIKit

class AnErrorView: UIView {

    @IBOutlet var contentView: UIView!
    var noNetAction : (()->())?

    override init(frame: CGRect) { // for using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit(){
        Bundle.main.loadNibNamed("AnErrorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }

}
