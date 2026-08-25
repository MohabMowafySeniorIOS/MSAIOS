//
//  PageCell.swift
//  Teck-En
//
//  Created by mohab mowafy on 24/12/2021.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var SkipBtn: UIButton!
    @IBOutlet weak var PageNum: UIPageControl!
    
    @IBOutlet weak var ImgCell: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desLabel: addInterLineSpacing!
    
    var press_next :(()->())?
    var press_skip :(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func ConfigrationCell(title:String , des:String , img : UIImage , skipAppear:Bool , Next_title : String , index:Int){
       
        ImgCell.image = img
        titleLabel.text = title
        desLabel.text = des
        SkipBtn.isHidden = !skipAppear
        NextBtn.setTitle(Next_title, for: .normal)
        desLabel.addInterlineSpacing(isCentered: true)
        
    }
    
    @IBAction func SkipAction(_ sender: Any) {
        press_skip?()
    }
    
    @IBAction func NextAction(_ sender: Any) {
        press_next?()
    }
    
}
