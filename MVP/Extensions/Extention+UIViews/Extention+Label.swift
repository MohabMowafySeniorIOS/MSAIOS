//
//  Extention+Label.swift
//  SIN
//
//  Created by Mohab Mowafy on 18/09/2024.
//

import Foundation
import UIKit

class Capitalized_label : UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.text = self.text?.capitalized
        print(self.text?.capitalized)
    }
}
