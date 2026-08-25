//
//  CollectionViewLoadingReusableView.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//

import UIKit

class LoadingReusableView: UICollectionReusableView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.color = .MainColor
        activityIndicator.isHidden = true
        view.backgroundColor = .clear
    }
}
