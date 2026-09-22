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
      
      
      /// المحتوى بقى من لوحة التحكم بدل Firestore.
      ///
      /// معرّفات الصفحات على السيرفر مختلفة عن الـ enum المحلي
      /// (`about` ← `about_us`، `terms` ← `usage_policy`)، فالربط صريح
      /// بدل ما نغيّر الـ enum ونكسر الكود اللي بيستخدمه.
      func listenToMetals() {
          let slug: String
          switch Item {
          case .AboutUs:        slug = PageSlug.about
          case .terms_of_use:   slug = PageSlug.usage
          case .Refund:         slug = PageSlug.refund
          case .Privacy_policy: slug = PageSlug.privacy
          case .none:           return
          }

          Task { @MainActor in
              guard let page = await ContentStore.shared.loadPage(slug) else { return }
              self.title = page.title
              self.titleLabel.text = page.title
              self.textView.text = page.body
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

