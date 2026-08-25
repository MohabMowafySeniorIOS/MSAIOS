//
//  NoDataView.swift
//  RoyalCatsStore
//
//  Created by ebtsam on 9/4/20.
//  Copyright © 2020 Tahaqom. All rights reserved.
//

import UIKit

class NoDataView: UIView {
     @IBOutlet var contentView: UIView!
     

        override init(frame: CGRect) { // for using custom view in code
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) { // for using custom view in IB
            super.init(coder: aDecoder)
            commonInit()
        }
        private func commonInit(){
            Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        }
        
        /*
        // Only override draw() if you perform custom drawing.
        // An empty implementation adversely affects performance during animation.
        override func draw(_ rect: CGRect) {
            // Drawing code
        }
        */

    }
