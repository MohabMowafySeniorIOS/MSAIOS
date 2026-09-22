//
//  MainButton.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//dasdasdasdas

import UIKit
class MainButton: UIButton {

    var fontSize:CGFloat = 16
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //dasdasdjaksjdokajsoidjoias
        layer.cornerRadius = 23
        titleLabel?.font = .systemFont(ofSize: fontSize)
    }

    
}
