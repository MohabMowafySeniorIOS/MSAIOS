//
//  HelpVC.swift
//  SIN
//
//  Created by Mohab Mowafy on 26/08/2024.
//

import UIKit
import FirebaseFirestore

class HelpVC: BaseControllerVC {

    @IBOutlet weak var NameTF: CustomTextField!
    @IBOutlet weak var EmailTF: CustomTextField!
    @IBOutlet weak var MessageTV: CustomTextView!
    @IBOutlet weak var ConfirmBtn: CustomButtonView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
      

        ConfirmBtn.ConfirmBtn.setTitle("Send".localized, for: .normal)
        EmailTF.NameTF.keyboardType = .emailAddress
        title = "Help".localized
        ConfirmBtn.Press_next = {
            var isPassing = true
            self.addNews(createdAt: Timestamp(), description: "test_description", imageUrl: "imageUrl", publishedAt: "publishedAt", source: "source", title: "title", url: "url")
          
            if !self.NameTF.validate_Text(field: self.NameTF) {
                isPassing = false
            }
            
            
            if !self.EmailTF.validate_email(field: self.EmailTF) {
                isPassing = false
            }
           
            
            if !self.MessageTV.validate_Text(field: self.MessageTV) {
                isPassing = false
            }
            
           

            if isPassing {
                self.saveMetal(name: self.NameTF.NameTF.text ?? "", email: self.EmailTF.NameTF.text ?? "", message: self.MessageTV.MessageTV.text ?? "")
                
                
                
            }
            
           
            
        }
    }
   
    @IBAction func BackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
   
    
}

extension HelpVC {
    func saveMetal(name: String, email: String,message: String) {
        let db = Firestore.firestore()
        let id = Int(Date().timeIntervalSince1970)
        db.collection("ContactUs")
            .document("\(id)")
            .setData([
                "name": name,
                "email": email,
                "message": message
            ], merge: true)
        
    }
    
    func addNews(createdAt: Timestamp, description: String,imageUrl: String,publishedAt: String,source: String,title: String,url: String) {
        let db = Firestore.firestore()
        let id = Int(Date().timeIntervalSince1970)
        db.collection("manual_news")
            .document("\(id)")
            .setData([
                "createdAt": createdAt,
                "description": description,
                "imageUrl": imageUrl,
                "publishedAt":  publishedAt,
                "source": source,
                "title": title,
                "url": url
            ], merge: true)
        
    }
}
