//
//  TermsVC.swift
//  Rental
//
//  Created by mohab mowafy on 30/12/2022.
//

import UIKit

enum ValideKey : CaseIterable {
    
    case terms_of_use
    case AboutUs
    case Privacy_policy
   case Refund
    
}


class AboutUsVC: BaseControllerVC {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var AcceptBtn: CustomButtonView!
    
    @IBOutlet weak var AcceptBGView: UIView!
    var Item : ValideKey!
    
    var app_facebook = ""
    var app_twitter = ""
    var app_instagram = ""
    var app_telegrame = ""
    
  var is_from_register = false
    @IBOutlet weak var titleLabel: UILabel!
    
    var titleVar = ""
   
    @IBOutlet weak var DataLabel: UILabel!
    
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
      
      var metalsArr: [MetalModel] = []

      override func viewDidLoad() {
          super.viewDidLoad()
          listenToMetals()
          
          titleLabel.text = titleVar.localized
         
      }
      
      
      func listenToMetals() {
          let db = Firestore.firestore()
          
          db.collection("pages").addSnapshotListener {[weak self] snapshot, error in
              guard let self = self else { return }
              guard let documents = snapshot?.documents else { return }
              
              metalsArr.removeAll()
              for doc in documents {
                  var name = doc.documentID as? String
                  let data = doc.data()
                  let title = L102Language.currentAppleLanguage() == "ar" ? data["title_ar"] as? String : data["title_en"] as? String
                  let describtion = L102Language.currentAppleLanguage() == "ar" ? data["describtion_ar"] as? String : data["describtion_en"] as? String
                  print("🔥", doc.documentID, title)
                  
                 
                  switch Item {
                  case .terms_of_use:
                      if doc.documentID == "terms" {
                          self.title = title
                          self.textView.text = describtion
                      }
                  case .AboutUs:
                      if doc.documentID == "about" {
                          self.title = title
                          self.textView.text = describtion
                      }
                  case .Privacy_policy:
                      if doc.documentID == "privacy" {
                          self.title = title
                          self.textView.text = describtion
                      }
                  case .Refund:
                      if doc.documentID == "refund" {
                          self.title = title
                          self.textView.text = describtion
                      }
                  case .none:
                    print("None")
                  }
                 
              }
              
             
            
          }
      }

    func htmlToAttributedString(_ html: String, font: UIFont) -> NSAttributedString? {
            guard let data = html.data(using: .utf8) else { return nil }
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            // Convert HTML to attributed string
            guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                return nil
            }
            
            // Set custom font and alignment
            let fullRange = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(.font, value: font, range: fullRange)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center  // Set text alignment
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            
            return attributedString
        }
  

    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
   
    
    
}


//
//extension AboutUsVC {
//    func get_fixed_page()  {
//        self.lock()
//        var tail_url = "\(tail_link)/pages/about-us"
//        if Item == .AboutUs {
//            tail_url = "\(tail_link)/pages/about-us"
//        }else if Item == .terms_of_use{
//            tail_url = "\(tail_link)/pages/terms-of-use"
//        }
//        if is_from_register {
//            tail_url = "\(tail_link)/pages/terms-and-conditions"
//        }
//        ApiServices.GetInstance().getPosts(methodType: .get, parameters: nil , url: "\(hostName)\(tail_url)") { (Model: BaseModel<FixedPagesData>? , err : String? )in
//            self.unlock()
//            if self.isApiSuccess(err: err, Model: Model?.info)  {
//                self.title = Model?.data?.title
//                self.textView.setHTMLFromString((Model?.data?.content ?? ""))
//              //  self.DataLabel.attributedText = self.htmlToAttributedString((Model?.data?.content ?? ""), font: AppFont.Regular.size(12))
//                
//            }
//        }
//    }
//}
import UIKit
import FirebaseCore
import FirebaseFirestore



class pagesView: UIViewController {
  
}


