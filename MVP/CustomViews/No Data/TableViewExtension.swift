//
//  TableViewExtension.swift
//
//  Created by Mohab Mowafy on 11/29/20.
//  Copyright © 2020 Youssef. All rights reserved.
//

import Foundation
import UIKit
extension UITableView {
    
    func setEmptyData(image:UIImage,description:String ,title:String,delegate:NoDataViewControllerDelegate?, buttonText:String? = nil ) {
        let vc = NoDataViewController(frame: .zero)
        vc.setData(image: image, description: description, title: title, delegate: delegate, buttonText: buttonText)
        backgroundView = vc
    }
    
   
    func removeBackGroundView(){
        backgroundView = nil
    }
}

extension UICollectionView {
    func setEmptyData(image:UIImage,description:String ,title:String ,delegate:NoDataViewControllerDelegate?,buttonText:String? = nil ) {
        let vc = NoDataViewController(frame: .zero)
        vc.setData(image: image, description: description, title: title, delegate: delegate, buttonText: buttonText)
        backgroundView = vc
    }
    
   
    func removeBackGroundView(){
        backgroundView = nil
    }
}
