//
//  ViewWithBottomCorner.swift
//  Sin
//
//  Created by Mohab Mowafy on 20/03/2024.
//

import Foundation
import Foundation
import UIKit

class BottomCornerRadius  : UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.setShadowView()
    }
}
