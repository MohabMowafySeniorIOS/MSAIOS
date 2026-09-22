//
//  AppDelegate.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//




import UIKit
import AuthenticationServices
import Firebase
import UserNotifications
import FirebaseMessaging
import UserNotifications
import FirebaseCore
import GoogleMobileAds
import IQKeyboardManagerSwift

protocol testProtocol {
    func MakeAction(test:[AnyHashable:Any])
}


var handle_noti_type_id = ""
var handle_noti_type = ""
var handle_noti_sub_id = ""

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate   {
    
    var window: UIWindow?
    
    var Delegate : testProtocol?
    
    var getNotification :(()->())?
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
 
    }
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------>\(fontFamilyNames.count)")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            
            print("Font Names = [\(names)]")
        }
    }

   
    var DevicToken : String?
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let def = UserDefaults.standard
        def.setValue(token, forKey: "mobileToken")
        def.synchronize()
        DevicToken = token
       
       // MobileAds.shared.start()
        Messaging.messaging().apnsToken = deviceToken
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        // بنطبّق اختيارات المستخدم من شاشة الإعدادات بدل الاشتراك الأعمى في
        // كل التوبيكس. الاشتراك الأعمى كان بيلغي أي إشعار المستخدم قافله كل
        // مرة يفتح التطبيق. الافتراضي لو مفيش حاجة محفوظة = كل الأنواع مفعّلة،
        // فسلوك المستخدمين الحاليين زي ما هو.
        NotificationSettings.applyAll()
        
        Helper.restartApp()
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        printFonts()
//        GMSServices.provideAPIKey(GoogleKey)
//        GMSPlacesClient.provideAPIKey(GoogleKey)
        L102Localizer.DoTheMagic()
     
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        L102Localizer.editLocalizationView()
        
        FirebaseApp.configure()
       
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        registerForNotifications()
        
        if Helper.getisFirst() != true {
            changeLanguage(Type: .Arabic)
        }
        
        if #available(iOS 10.0, *) {
              // For iOS 10 display notification (sent via APNS)
              UNUserNotificationCenter.current().delegate = self

              let authOptions: UNAuthorizationOptions = [.alert, .sound]
              UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {isGranted, error in
                    print("UNUserNotificationCenter requestAuthorization isGranted: \(isGranted)")
                })
            } else {
              let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
              application.registerUserNotificationSettings(settings)
            }
        
       
        
        application.registerForRemoteNotifications()
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
//        if L102Language.currentAppleLanguage() == englishLang {
//            self.changeLanguage(Type: .Arabic)
//        }
        
        
        

        
        showIQkeyboard()

        return true
    }
    
    func showIQkeyboard(){
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.toolbarConfiguration.tintColor = UIColor.MainColor
       // IQKeyboardManager.shared.keyboardAppearance = .dark
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.deepResponderAllowedContainerClasses.append(UIStackView.self)
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance = true
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

        /*
         * ⚠️ مفيش `NotificationSettings.applyAll()` هنا عن قصد.
         *
         * الدالة دي ليها نداء واحد بس: السطر اللي فوق في
         * `didFinishLaunching` اللي بيرجّع اللغة للعربي إجبارياً عند
         * كل فتح للتطبيق (شوف الملاحظة هناك). تغيير لغة المستخدم
         * الحقيقي بيمر على `UIViewController.changeLanguage` — وده
         * المكان اللي الاشتراكات بتتحدّث فيه.
         *
         * لو ناديناها هنا، كل فتحة للتطبيق كانت هتلغي اشتراك المستخدم
         * الإنجليزي وترجّعه للتوبيكات العربي.
         */
        let mainStoryboard1: UIStoryboard = UIStoryboard(name: storyBoardName.Authontication.rawValue, bundle: nil)
        let HomeVc = mainStoryboard1.instantiateViewController(withIdentifier: "SlashVC")
        guard let window = UIApplication.shared.keyWindow else{return}
        
        window.rootViewController = HomeVc
        window.makeKeyAndVisible()
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
        }) { (finished) -> Void in
            
        }
    }
    
    //MARK: - dynamicLinks
    

    
    //Check on dynamicLinks
    func application(_ application: UIApplication, continue userActivity:
                        NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let inCommingURL = userActivity.webpageURL else { return false }
        print("Incomming Web Page URL: \(inCommingURL)")
       
        return true
    }
    
    
    
    
   
    
    
    
    func SideMenu() {
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: HomeStry, bundle: nil)
//        let SideMenueStoryboard: UIStoryboard = UIStoryboard(name: SideMenue, bundle: nil)
//        let rightMenuVC: SideMenueVC = SideMenueStoryboard.instantiateViewController(withIdentifier: "SideMenueVC")  as! SideMenueVC
//        let HomeVc = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC")
//        let PanelController: FAPanelController = FAPanelController()
//    
//        if L102Language.currentAppleLanguage() == arabicLang {
//            PanelController.leftPanelPosition = .front
//            PanelController.right(rightMenuVC).center(HomeVc)
//        } else {
//            PanelController.leftPanelPosition = .front
//            PanelController.left(rightMenuVC).center(HomeVc)
//        }
//        window?.rootViewController = PanelController
//        window?.makeKeyAndVisible()
    }
    //
    
    
    func registerForNotifications() {
        // Register for notification: This will prompt for the user's consent to receive notifications from this app.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
    }
    
    func createBackgroundNotificationRequest() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = appName 
        content.subtitle = "Just so you are aware."
        content.body = "We'll be waiting for you back in \(appName)"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "aSUoV7eCGcs.mb3")) // هنا يتم تحديد الصوت المخصص
        // إعداد المشغل
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

//        // إنشاء الطلب
     //   let request = UNNotificationRequest(identifier: "notificationID", content: content, trigger: trigger)
        
        let request = UNNotificationRequest(identifier: "BackgroundNotification", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 200, repeats: false))
        
        UNUserNotificationCenter.current().add(request) { error in
               if let error = error {
                   print("خطأ أثناء جدولة الإشعار: \(error.localizedDescription)")
               }
           }
        
        return request
    }
    
    
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        print("When lock Screen")
        
        NotificationCenter.default.post(name: Notification.Name(Notification_lock_Screen), object: nil)
        
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: Notification.Name(Notification_Unlock_Screen), object: nil)
        
        print("When Unlock Screen")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(Notification_Unlock_Screen), object: nil)
        print("First Launch")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        print("applicationWillTerminate")
        
    }
    
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        
        
        
    
        /*
         * ⚠️ كان هنا `as!` على `aps` وعلى `aps["alert"]`.
         *
         * الإشعار مش لازم يكون فيه `aps`، و`alert` ممكن تيجي **نص**
         * مش قاموس (إشعار بنص واحد من غير عنوان، أو إشعار بيانات بس).
         * في الحالتين دول `as!` كان **بيقفل التطبيق في وش المستخدم**
         * أول ما الإشعار يوصل — من غير ما يضغط على حاجة.
         *
         * ده مكانش باين لأن الإشعارات كانت بتتبعت من مكان واحد بشكل
         * ثابت. أول إشعار من لوحة التحكم بصيغة مختلفة كان هيولّع.
         */
        print(userInfo)

        let aps = userInfo[AnyHashable("aps")] as? [String: Any]
        print(aps ?? [:])

        // `alert` ممكن تبقى قاموس (عنوان + نص) أو نص واحد
        if let alertDictionary = aps?["alert"] as? [String: Any] {
            print(alertDictionary)
        } else if let alertText = aps?["alert"] as? String {
            print(alertText)
        }

        let type = userInfo[AnyHashable("type")] as? String
        let main_id = userInfo[AnyHashable("type_id")] as? String

        print(type ?? "", main_id ?? "")

        completionHandler([.sound , .alert])
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("didReceiveRemoteNotification")
        
        
        
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("didReceiveRemoteNotification")
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        
        let userInfo = response.notification.request.content.userInfo
      
        
        print(userInfo ,"->userInfo" )

        // نفس سبب التعديل في `willPresent` فوق — الضغط على الإشعار
        // كان بيقفل التطبيق لو الحمولة مش بالشكل المتوقّع بالظبط.
        let aps = userInfo[AnyHashable("aps")] as? [String: Any]

        if let alertDictionary = aps?["alert"] as? [String: Any] {
            print(alertDictionary, "->al")
        } else if let alertText = aps?["alert"] as? String {
            print(alertText, "->al")
        }

        let body = userInfo[AnyHashable("type")] as? String
        print(body ?? "", "->body" )

        completionHandler()
    }
    
  
  
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "-")")
        Helper.SaveFcmtoken(Fcmtoken: fcmToken)

        /*
         * والسيرفر لازم يعرف التوكن الجديد.
         *
         * التوكن كان بيتبعت مع التسجيل والدخول بس، وFCM بيجدّده لوحده
         * (تحديث التطبيق · استعادة نسخة احتياطية). يعني مستخدم مش
         * بيعمل دخول كل شوية كان بيختفي من الإشعارات الموجّهة من غير
         * ما حد ياخد باله.
         *
         * النداء بيقف لوحده لو المستخدم مش مسجّل دخول.
         */
        DeviceTokenSync.sync()
    }
  
    
}


