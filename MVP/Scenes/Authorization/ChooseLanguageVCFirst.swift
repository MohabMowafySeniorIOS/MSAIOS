//
//  ChooseLanguageVCFirst.swift
//  Teck-En
//
//  Created by Waheed on 07/05/2022.
//

import UIKit

class ChooseLanguageVCFirst: BaseControllerVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var ConfirmBtn: CustomButtonView!
    
    
    var Lang = ""
    var is_fro_side = false
    
    @IBOutlet weak var EnglishBgView: UIView!
    @IBOutlet weak var EnglishCheckIcon: UIImageView!
    
    @IBOutlet weak var ArabicBgview: UIView!
    @IBOutlet weak var ArabicCheckImg: UIImageView!
    
    @IBOutlet weak var AurdiBgView: UIView!
    @IBOutlet weak var AurdiCheckImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Language".localized
        if L102Language.currentAppleLanguage() == "ar" {
            ChangeArabic()
        }else if L102Language.currentAppleLanguage() == "en" {
            ChangeEnglish()
        }else {
            ChangeAurdi()
        }
        
        
        ConfirmBtn.Press_next = {
            
           // self.get_slider()
            
            self.handlData()
        }
       
    }
    
    @IBAction func EnglishAction(_ sender: Any) {
        
        ChangeEnglish()
    }
    
    @IBAction func ArabicAction(_ sender: Any) {
        ChangeArabic()
    }
    
    @IBAction func AurdiAction(_ sender: Any) {
        ChangeAurdi()
    }
    
    @IBAction func BackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
   
    
    
    
    
    func ChangeEnglish(){
        Lang = "en"
        EnglishBgView.borderColor = UIColor.selectionBorder
        EnglishBgView.borderWidth = 1
        EnglishCheckIcon.image = #imageLiteral(resourceName: "check")
        EnglishBgView.backgroundColor = UIColor.selectionBackGround
        EnglishBgView.backgroundColor = UIColor.selectionBackGround
        
        ArabicBgview.borderColor = UIColor.clear
        ArabicBgview.backgroundColor = UIColor.selectionBackGround
        ArabicBgview.borderWidth = 1
        ArabicCheckImg.image = nil
       
        
        
    }
    
    func ChangeArabic(){
        Lang = "ar"
        ArabicBgview.borderColor = UIColor.selectionBorder
        ArabicBgview.backgroundColor = UIColor.selectionBackGround
        ArabicBgview.borderWidth = 1
        ArabicCheckImg.image = #imageLiteral(resourceName: "check")
     
        
        EnglishBgView.borderColor = UIColor.clear
        EnglishBgView.backgroundColor = UIColor.selectionBackGround
        EnglishBgView.borderWidth = 1
        EnglishCheckIcon.image = nil
    }
    
    
    func ChangeAurdi(){
        Lang = "ur"
        AurdiBgView.backgroundColor = UIColor.selectionBackGround
        AurdiBgView.borderWidth = 1
        AurdiCheckImg.image = #imageLiteral(resourceName: "check")
        AurdiBgView.borderColor = UIColor.SecondarColor
        
        EnglishBgView.backgroundColor = UIColor.white
        EnglishBgView.borderWidth = 0
        EnglishCheckIcon.image = nil
        EnglishBgView.borderColor = .clear
        
        ArabicBgview.backgroundColor = UIColor.white
        ArabicBgview.borderWidth = 0
        ArabicCheckImg.image = nil
        ArabicBgview.borderColor = .clear
    }
    
    
 
    
    func handlData(){
      
        Helper.SaveisStart_Language(token: "true")
            if self.Lang == "en" {
                self.changeLanguage(Type: .English)
               
            }else if self.Lang == "ar" {
                self.changeLanguage(Type: .Arabic)
            }else {
                self.changeLanguage(Type: .Ardu)
            }
    }
}

