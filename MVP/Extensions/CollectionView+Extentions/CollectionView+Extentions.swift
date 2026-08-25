//
//  CollectionView+Extentions.swift
//  MVP
//
//  Created by Mohab on 7/16/21.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func RegisterNib<cell : UICollectionViewCell>(cell : cell.Type){
    
        let nibName = String(describing : cell.self)
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
        
    }

}
