//
//  HelperClass.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import Foundation

import UIKit

class Helper: NSObject {
    
   
    
    // IsFirst
    
    class func isFirst()->String {
        
        let api_token = "isFirst"
        return api_token
    }
    
    class func SaveisFirst(token : Bool?){
        let def = UserDefaults.standard
        def.setValue(token, forKey: isFirst())
        def.synchronize()
    }
    
    class func getisFirst()->Bool? {
        let def = UserDefaults.standard
        return def.object(forKey: isFirst()) as? Bool
    }
    
    
    // IsFirst
    
    class func isCountry()->String {
        
        let api_token = "isCountry"
        return api_token
    }
    
    class func SaveisCountry(token : String?){
        let def = UserDefaults.standard
        def.setValue(token, forKey: isCountry())
        def.synchronize()
    }
    
    class func getisCountry()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: isCountry()) as? String
    }
    
    // IsFirst
    
    class func isStart_Language()->String {
        
        let api_token = "isStart_Language"
        return api_token
    }
    
    class func SaveisStart_Language(token : String?){
        let def = UserDefaults.standard
        def.setValue(token, forKey: isStart_Language())
        def.synchronize()
    }
    
    class func getisStart_Language()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: isStart_Language()) as? String
    }
    
    
    // IsFirst
    
    class func isStart_screen()->String {
        
        let api_token = "isStart_screen"
        return api_token
    }
    
    class func SaveisStart_screen(token : String?){
        let def = UserDefaults.standard
        def.setValue(token, forKey: isStart_screen())
        def.synchronize()
    }
    
    class func getisStart_screen()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: isStart_screen()) as? String
    }
    
    // IsFirst
    
    class func isComplete_Register()->String {
        
        let api_token = "isComplete_Register"
        return api_token
    }
    
    class func SaveisComplete_Register(token : String?){
        let def = UserDefaults.standard
        def.setValue(token, forKey: isComplete_Register())
        def.synchronize()
    }
    
    class func getisComplete_Register()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: isComplete_Register()) as? String
    }

  
    
    class func Fcm_toket()->String {
        let Fcm_token = "Fcmtoken"
        return Fcm_token
    }
    
    class func SaveFcmtoken(Fcmtoken : String?){
        let def = UserDefaults.standard
        def.setValue(Fcmtoken, forKey: Fcm_toket())
        def.synchronize()
    }
    
    class func getFcmtoken()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: Fcm_toket()) as? String
    }
    
    
    
    class func User_Provider()->String {
        let user_provider = "userprovider"
        return user_provider
    }
    
    class func SaveUser_Provider(user_provider : String?){
        
        let def = UserDefaults.standard
        def.setValue(user_provider, forKey: User_Provider())
        def.synchronize()
    }
    
    class func getUser_Provider()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: User_Provider()) as? String
    }
    
    class func Provider_Complete_Order()->String {
        let user_provider = "Provider_Complete_Order"
        return user_provider
                                                                                                                                                                                                                                  }
    
    class func SaveProvider_Complete_Order(user_provider : String?){
    
        let def = UserDefaults.standard
        def.setValue(user_provider, forKey: Provider_Complete_Order())
        def.synchronize()
    }
    
    class func getProvider_Complete_Order()->String? {
        let def = UserDefaults.standard
        return def.object(forKey: Provider_Complete_Order()) as? String
    }
    
    
    class func restartApp(){
//        if AuthService.userData?.token != nil {
//            // MARK: go To home
//            
//            if is_provder {
//                Helper.restart_to_driver_home_App()
//            }else {
//                Helper.restart_to_home_App()
//            }
//        }else {
            if Helper.getisStart_Language() == "true" {
                Helper.restart_to_home_App()
              // restartToLogin()
               // restartToLanguage()
            }else {
                restartToLanguage()
            }
          
       // }
       
    }
    
    class func restart_to_home_App(){
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else{return}
            let sb = UIStoryboard(name: HomeStry
                                  , bundle: nil)
            var vc : UIViewController
            vc = sb.instantiateViewController(withIdentifier: "MainTabBarVC")
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
        }
          
    }
    
    class func restart_to_driver_home_App(){
            guard let window = UIApplication.shared.keyWindow else{return}
            let sb = UIStoryboard(name: DriverStry
                                  , bundle: nil)
            var vc : UIViewController
            vc = sb.instantiateViewController(withIdentifier: "MainTabBarVC")
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
    }
    

    class func restartToLogin(){
        guard let window = UIApplication.shared.keyWindow else{return}
        let sb = UIStoryboard(name: HomeStry
                              , bundle: nil)
        var vc : UIViewController
        vc = sb.instantiateViewController(withIdentifier: "MainTabBarVC")
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
//        guard let window = UIApplication.shared.keyWindow else{return}
//        let sb = UIStoryboard(name: Authontication, bundle: nil)
//        var vc : UIViewController
//        vc = sb.instantiateViewController(withIdentifier: "LoginVC")
//        window.rootViewController = vc
//        UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
    }
    
    class func restartOnBoarding(){
        guard let window = UIApplication.shared.keyWindow else{return}
        let sb = UIStoryboard(name: Authontication, bundle: nil)
        var vc : UIViewController
        vc = sb.instantiateViewController(withIdentifier: "OnBoardingVC")
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
    }
    
    class func restartToLanguage(){
        guard let window = UIApplication.shared.keyWindow else{return}
        let sb = UIStoryboard(name: Authontication, bundle: nil)
        var vc : UIViewController
        vc = sb.instantiateViewController(withIdentifier: "ChooseLanguageVCFirst")
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
    }
    
     
   
    
    static func openZoomAbleImage(image: [String], vc: UIViewController , index : Int) {
        let zoomVC = UIStoryboard(name: "ZoomAbleImage", bundle: nil).instantiate(identifier: "PhotoDetialsVC", asClass: PhotoDetialsVC.self)
        zoomVC.images = image
        zoomVC.Selected_index = index
        zoomVC.modalPresentationStyle = .fullScreen
        vc.present(zoomVC, animated: true, completion: nil)
    }
}
