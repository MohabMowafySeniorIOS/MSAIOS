//
//  Extention+TableView.swift
//  MVP
//
//  Created by Mohab on 7/15/21.
//

import Foundation
import UIKit
import Foundation

extension UITableView {
    
    func RegisterNib<cell : UITableViewCell>(cell : cell.Type){
        
        let nibName = String(describing : cell.self)
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
        
    }
    
    
    func dequeue<cell : UITableViewCell>() -> cell{
        
        let identifier = String(describing: cell.self)
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier) as? cell else {
            fatalError("error in cell")
        }
        
        return cell
    }
    
}
