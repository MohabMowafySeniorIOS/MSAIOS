//
//  UIViewController+Extentions.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import UIKit

import NVActivityIndicatorView
import AJMessage
import AudioToolbox
//import MaterialComponents.MaterialSnackbar

enum Language_cases {
    case Arabic
    case English
    case Ardu
}

extension UIViewController {
    
    func openUrl(link: String){
        var url = NSURL(string: link)
        
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.openURL(url! as URL)
        }
    }
    
    
    
    func WatsApp(phone:String){
        
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phone)")!
       
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        } else {
            // WhatsApp is not installed
        }
        
    }
    
    
    func editTF(text :UITextField){
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.MainColor?.cgColor
        text.backgroundColor = UIColor.white
        //        text.placeHolderColor = .lightGray
        //        text.textColor = .lightGray
        text.tag = 1
    }
    func editMainTF(text :UITextField){
        text.layer.borderWidth = 1
//        text.layer.borderColor = UIColor.attributedTextFieldColor?.cgColor
//        text.backgroundColor = UIColor.attributedTextFieldColor
        
        text.tag = 1
    }
    
    func shareApp(app_id : String){
        
        let firstActivityItem = ""
        //MARK: - for sare the App in App Store  use this commented line
        let secondActivityItem : NSURL = NSURL(string: "https://apps.apple.com/us/app/id\(app_id)")!
        
        // If you want to put an image
        let image : UIImage = #imageLiteral(resourceName: "Group 21")
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView =  UIButton()
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func EnableLineAnimite(text : UITextField , lineView : UIView , ishidden : Bool )  {
        
        UIView.animate(withDuration: 0.02, animations: {
            
            lineView.isHidden = ishidden
            lineView.center.x = 100
            lineView.frame.size.width = +200
            
        }) { (_) in
            
        }
    }
    
    func makeCall(phone: String) {
        let numbersOnly = phone.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: "tel://\(numbersOnly)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        
    }
    
    func MakeCallWats_App(PhoneNumber : String) {
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(PhoneNumber)")!
       
             if UIApplication.shared.canOpenURL(appURL) {
                 if #available(iOS 10.0, *) {
                     UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                 }
                 else {
                     UIApplication.shared.openURL(appURL)
                 }
             } else {
                 // WhatsApp is not installed
             }
    }
    
    func alert(_ msg:String){
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "موافق", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func EnableLineAnimiteNoimage(text : UITextField , lineView : UIView , ishidden : Bool )  {
        
        UIView.animate(withDuration: 0.02, animations: {
            
            lineView.isHidden = ishidden
            lineView.center.x = 100
            lineView.frame.size.width = +200
            
        }) { (_) in
            
        }
    }
    
    func EnableLineAnimiteTextView(text : UITextView , lineView : UIView , ishidden : Bool )  {
        
        UIView.animate(withDuration: 0.02, animations: {
            
            lineView.isHidden = ishidden
            lineView.center.x = 100
            lineView.frame.size.width = +200
            
        }) { (_) in
            
        }
    }
}

extension Data {
    
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}
extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
    
    
}

extension UITextView {
    func setHTMLFromString(_ htmlContent: String) {
        guard let data = htmlContent.data(using: .unicode) else { return }
        
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
//            let customFont = AppFont.Regular.size(12)
//            
////            // Apply font to entire string
//            let fullRange = NSRange(location: 0, length: attributedString.length)
//            attributedString.addAttribute(.font, value: customFont, range: fullRange)
            
            self.attributedText = attributedString
        } catch {
            print("Error rendering HTML: \(error)")
        }
    }
}


extension UIViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func showAllImageToChose(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func EvaluateEmail(_ email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if !emailTest.evaluate(with: email){
            
        
            
            return false
        }
        else{
            return true
        }
        
    }
   
    
    
}
import UIKit
import Kingfisher
import AudioToolbox
//import MaterialComponents.MaterialSnackbar
//import FAPanels

extension UITableViewCell  {
    func setShadow(view : UIView , width : Double = 1 , height: Double = 1 , shadowRadius: CGFloat = 0.5 , shadowOpacity: Float = 1, shadowColor: CGColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)){
        // to make the shadow with rounded corners and offset shadow form the bottom
        view.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.clipsToBounds = true
        view.layer.masksToBounds = false
    }
}

extension UICollectionViewCell {
    func setShadow(view : UIView , width : Double , height: Double , shadowRadius: CGFloat , shadowOpacity: Float , shadowColor: CGColor){
        // to make the shadow with rounded corners and offset shadow form the bottom
        view.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.clipsToBounds = true
        view.layer.masksToBounds = false
    }
}

extension UIView {
    func setShadowView(){
        // to make the shadow with rounded corners and offset shadow form the bottom
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.1
        self.clipsToBounds = true
        self.layer.masksToBounds = false
    }
    
    func setBGShadowView(){
        // to make the shadow with rounded corners and offset shadow form the bottom
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.3
        self.clipsToBounds = true
        self.layer.masksToBounds = false
    }
}

extension UIViewController : UIGestureRecognizerDelegate {
    
    func alert(msg:String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func isNotEmptyString(text: String, withAlertMessage message: String ) -> Bool{
        if text == ""{
             self.showAlertWithTitle(title: "".localized, message: message, type: .error)
            return false
        }
        else{
            return true
        }
    }
    
    
    
    
    func if_user_login()->Bool{
//        guard let token = AuthService.userData?.token  else{
//            let storyboard = UIStoryboard(name: PopUpsStry, bundle: nil)
//            let vc  = storyboard.instantiateViewController(withIdentifier: "ConfirmDeleteVC") as! ConfirmDeleteVC
//            vc.DeleteItem = .Visitor
//            present(vc, animated: true)
//            return false
//        }
        return true
        
//        let alert = UIAlertController.init(title: "".localized , message: "please login first".localized ,  preferredStyle: .alert)
//        alert.view.tintColor = UIColor.MainColor
//        
//        let OKAction = UIAlertAction.init(title: "Ok".localized, style: .default, handler: { (nil) in
//            AuthService.userData = nil
//            Helper.restartToLogin()
//        })
//        
//        let cancelAction = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { (nil) in
//        })
//        
//        alert.addAction(OKAction)
//        alert.addAction(cancelAction)
//        self.present(alert, animated: true, completion: nil)
    }
    
    func setShadow(view : UIView , width : Double , height: Double , shadowRadius: CGFloat , shadowOpacity: Float , shadowColor: CGColor){
        // to make the shadow with rounded corners and offset shadow form the bottom
        view.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.clipsToBounds = true
        view.layer.masksToBounds = false
    }
    enum Vibration {
        case error
        case success
        case warning
        case light
        case medium
        case heavy
        case selection
        case oldSchool
        func vibrate() {
            
            switch self {
            case .error:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
            case .success:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
            case .warning:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                
            case .light:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
            case .medium:
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            case .heavy:
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
                
            case .oldSchool:
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            
        }
        
    }
    func showAlertWithTitle(title: String, message: String, type: Vibration) {
        let vibrate : Vibration = .selection
        if type == .error {
            AJMessage(title: title, message: message , status : .error ).show()
            
          //  self.navigationController?.view.makeToast(message)
            
        }else if type == .success {
            AJMessage(title: title, message: message , status : .success).show()
           // self.navigationController?.view.makeToast(message , position: .top)
            
            
        }else if type == .warning {
          //  AJMessage(title: title, message: message , status : .error ).show()
            //self.navigationController?.view.makeToast(message)
            AJMessage(title: title, message: message , status : .error ).show()
        }
        
        
    }
    
    func changeLanguage(Type:Language_cases) {
        let transition: UIView.AnimationOptions = .transitionCrossDissolve
        
        if Type == .Arabic {
            L102Language.setAppleLAnguageTo(lang: arabicLang)
        } else if Type == .English {
            L102Language.setAppleLAnguageTo(lang: englishLang)
        }else {
            L102Language.setAppleLAnguageTo(lang: urdoLang)
        }
        
        L102Localizer.editLocalizationView()
        
        let mainStoryboard1: UIStoryboard = UIStoryboard(name: HomeStry, bundle: nil)
        let HomeVc = mainStoryboard1.instantiateViewController(withIdentifier: "MainTabBarVC")
        guard let window = UIApplication.shared.keyWindow else{return}
        
        window.rootViewController = HomeVc
        window.makeKeyAndVisible()
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
        }) { (finished) -> Void in
            
        }
    }
    
    func changeLanguageFirst(Type:Language_cases) {
        let transition: UIView.AnimationOptions = .transitionCrossDissolve
        
        if Type == .Arabic {
            L102Language.setAppleLAnguageTo(lang: arabicLang)
        } else if Type == .English {
            L102Language.setAppleLAnguageTo(lang: englishLang)
        }else {
            L102Language.setAppleLAnguageTo(lang: urdoLang)
        }
        
        L102Localizer.editLocalizationView()
        
        let mainStoryboard1: UIStoryboard = UIStoryboard(name: Authontication, bundle: nil)
        let HomeVc = mainStoryboard1.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
     
        guard let window = UIApplication.shared.keyWindow else{return}
        
        window.rootViewController = HomeVc
        window.makeKeyAndVisible()
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
        }) { (finished) -> Void in
            
        }
    }
    
    func performSegueTo(storyBoard: storyBoardName, vc: storyBoardVCIDs) {
        let sb = UIStoryboard(name: storyBoard.rawValue, bundle: nil)
        let vcNew = sb.instantiateViewController(withIdentifier: vc.rawValue)
        self.navigationController?.pushViewController(vcNew, animated: true)
        //        show(vcNew, sender: self)
        
    }
    
   
}


extension UIViewController {
    func lock(frameRect: CGRect = CGRect.zero) {
        let activityIndicatorView = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 50, height: 50), type: .ballClipRotateMultiple, color: UIColor.MainColor, padding: .zero)
        view.addSubview(activityIndicatorView)
        view.isUserInteractionEnabled = false
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
       
        
    }
   
    
    func unlock() {
        DispatchQueue.main.async {
            if let indicator = self.view.subviews.first(where: {$0 is NVActivityIndicatorView }) as? NVActivityIndicatorView {
                indicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                indicator.removeFromSuperview()
            }
        }

      
    }
    
}

extension UIScreen {
    var minEdge: CGFloat {
        return UIScreen.main.bounds.minEdge
    }
}
extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
