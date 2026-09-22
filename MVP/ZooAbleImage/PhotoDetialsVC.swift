//
//  PhotoDetialsVC.swift
//  Matajer
//
//  Created by mohab mowafy on 27/06/2022.
//

import Foundation
import UIKit

class PhotoDetialsVC: BaseControllerVC{
    
    var images = [String]()
    var Selected_index = 3
    
    @IBOutlet weak var PageIndicator: UIPageControl!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if images.count == 0 {
            PageIndicator.isHidden = true
        }
        
        PageIndicator.numberOfPages = images.count
        PageIndicator.currentPage = Selected_index
       
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.RegisterNib(cell: ZoomPhotoCollectionView.self)
        print(Selected_index)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.CollectionView.scrollToItem(at: IndexPath(row: self?.Selected_index ?? 0, section: 0), at: .centeredHorizontally, animated: false)
         }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
   
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension PhotoDetialsVC : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomPhotoCollectionView", for: indexPath) as! ZoomPhotoCollectionView
        cell.Configration_Cell(theImage: images[indexPath.row])
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        PageIndicator.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}





extension UIStoryboard {
    func instantiate<T>(identifier: String, asClass: T.Type) -> T {
        return instantiateViewController(withIdentifier: identifier) as! T
    }
    
    func instantiate<T>(identifier: String) -> T {
        return instantiateViewController(withIdentifier: identifier) as! T
    }
}
