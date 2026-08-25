//
//  Extention+TlphotoImages.swift
//  SIN
//
//  Created by Mohab Mowafy on 25/03/2024.
//

//import Foundation
//import UIKit
//import TLPhotoPicker
//import Photos
//class CustomStylePickerViewController: TLPhotosPickerViewController {
//    override func makeUI() {
//        super.makeUI()
//        self.customNavItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: nil, action: #selector(customAction))
//        self.view.backgroundColor = UIColor.white
//        self.collectionView.backgroundColor = UIColor.white
//        self.navigationBar.barStyle = .default
//        self.titleLabel.textColor = UIColor.MainColor
//        self.subTitleLabel.textColor = UIColor.MainColor
//        self.doneButton.tintColor = UIColor.MainColor
//        self.navigationBar.tintColor = UIColor.MainColor
//        self.popArrowImageView.image = TLBundle.podBundleImage(named: "pop_arrow")?.colorMask(color: .black)
//        self.albumPopView.popupView.backgroundColor = .white
//        self.albumPopView.tableView.backgroundColor = .white
//    }
//    
//    @objc func customAction() {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! TLCollectionTableViewCell
//        cell.backgroundColor = .black
//        cell.titleLabel.textColor = .white
//        cell.subTitleLabel.textColor = .white
//        cell.tintColor = .white
//        return cell
//    }
//}
//
//
//
//
//
