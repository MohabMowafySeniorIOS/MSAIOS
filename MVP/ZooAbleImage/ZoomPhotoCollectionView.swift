//
//  ZoomPhotoCollectionView.swift
//  Garage Plus
//
//  Created by Mohab Mowafy on 13/03/2024.
//

import UIKit

class ZoomPhotoCollectionView: UICollectionViewCell , UIScrollViewDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func Configration_Cell(theImage : String){
        
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        self.imgPhoto.loadImage(theImage)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imgPhoto
    }

}

