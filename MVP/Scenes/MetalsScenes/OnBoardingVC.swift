//
//  OnBoardingVC.swift
//  SIN
//
//  Created by Mohab Mowafy on 04/09/2024.
//

import UIKit
import FirebaseFirestore

struct Sliders: Codable {
    var title: String?
    var des: String?
    var image: String?
  
}

class OnBoardingVC: BaseControllerVC {

    @IBOutlet weak var bgView: UIView!
//    @IBOutlet weak var imgView: UIImageView!
//    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DesLabel: UILabel!
    @IBOutlet weak var PagerView: UIPageControl!
    
   var Slider_array = [Sliders]()
    var selected_index = 0
    
    private lazy var db: Firestore = {
        return Firestore.firestore()
    }()

    private lazy var batch: WriteBatch = {
        return db.batch()
    }()

    private lazy var metalRef: DocumentReference = {
        return db.collection("metals").document("gold")
    }()

    private lazy var historyRef: DocumentReference = {
        return db.collection("price_history").document()
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenToMetals()
       
      
        
    }
    
    @IBAction func NextAction(_ sender: Any) {
        
        if Slider_array.count > selected_index + 1{
            selected_index =  selected_index + 1
            PagerView.currentPage = selected_index
           
           // imgView.loadImage(Slider_array[selected_index].image ?? "")
            TitleLabel.text = Slider_array[selected_index].title ?? ""
            DesLabel.text = Slider_array[selected_index].des ?? ""
        }else {
            Helper.SaveisFirst(token: true)
            Helper.restartToLogin()
        }
        
    }
    
    
    func listenToMetals() {
        let db = Firestore.firestore()
        
        db.collection("on_boarding").addSnapshotListener {[weak self] snapshot, error in
            guard let self = self else { return }
            guard let documents = snapshot?.documents else { return }
            
            Slider_array.removeAll()
            for pages in documents {
                var page = pages.documentID as? String
                let data = pages.data()
                print(data)
                let title = L102Language.currentAppleLanguage() == "ar" ? data["title_ar"] as? String : data["title_en"] as? String
                let describtion = L102Language.currentAppleLanguage() == "ar" ? data["describtion_ar"] as? String : data["describtion_en"] as? String
                let image = data["image"] as? String
                Slider_array.append(Sliders(title: title, des: describtion, image: image))
               
            }
            
            PagerView.numberOfPages =  Slider_array.count
            
            if Slider_array.count > 0 {
                PagerView.currentPage = 0
                selected_index = 0
                TitleLabel.text = Slider_array[0].title ?? ""
                DesLabel.text = (Slider_array[0].des ?? "")
               // imgView.loadImage(Slider_array[0].image ?? "")
               
            }
        }
    }

}
