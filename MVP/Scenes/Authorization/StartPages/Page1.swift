//
//  Page1.swift
//  Teck-En
//
//  Created by mohab mowafy on 19/12/2021.
//

import UIKit

class Page1: UIViewController {
    
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
      
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.RegisterNib(cell: PageCell.self)
    
    }
    

   

}

extension Page1 : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCell", for: indexPath) as! PageCell
        
        cell.press_next = {
            if indexPath.row < 2 {
               
            var index = IndexPath(item: indexPath.row+1, section: 0)
            self.CollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            }else {
                Helper.restartApp()
            }
        }
        
        cell.press_skip = {
            Helper.restartApp()
        }
        
       
        if indexPath.row == 0 {
            cell.ConfigrationCell(title: "With us, do not take away the time".localized, des: "As we try hard to do our best to save your time, we have provided all sections of the services you want".localized, img: UIImage(named: "Start1")! , skipAppear: true, Next_title: "Next".localized, index: indexPath.row)
        }else if indexPath.row == 1{
            Helper.SaveisStart_screen(token: "true")
            cell.ConfigrationCell(title: "Easily select your service".localized, des: "As we try hard to do our best to save your time, we have provided all sections of the services you want".localized, img: UIImage(named: "Start2")! , skipAppear: true, Next_title: "Next".localized, index: indexPath.row)
        }else if indexPath.row == 2 {
            cell.ConfigrationCell(title: "Complete the information and submit the request.".localized, des: "As we try hard to do our best to save your time, we have provided all sections of the services you want".localized, img: UIImage(named: "Start3")!, skipAppear: false, Next_title: "Start Now".localized, index: indexPath.row)
        }
        
       
       
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CollectionView.frame.size.width, height: CollectionView.frame.size.height)
    }
}
