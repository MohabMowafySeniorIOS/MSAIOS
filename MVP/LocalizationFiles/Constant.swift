//
//  Constant.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import UIKit
let arabicLang = "ar"
let englishLang = "en"
let urdoLang = "ur"
//"https://sinback.bb4itdev.com/api/v1/provider/"
var OpenAppForFirstTime = 0
/// بدّل `current` إلى `.staging` لبناء نسخة الاختبار.
enum APIEnvironment {
    case production
    case staging

    static let current: APIEnvironment = .production

    var baseURL: String {
        switch self {
        case .production:
            return "https://backend.msagold.com/api/v1/"
        case .staging:
            return "https://staging.backend.msagold.com/api/v1/"
        }
    }
}
var is_provder = false

var AppleId = "6767865490"
var tail_link = is_provder ? "driver" : "client"
// مصدر واحد لكل طلبات التطبيق، بما فيها المحتوى والبانرات.
let hostName = APIEnvironment.current.baseURL


let FontfamilyName = "IBMPlexSansArabic"
/// خط العناوين من الهوية — الاسم ده هو الـ PostScript name جوّه ملف الـ otf
let DisplayFontFamilyName = "Lafet"
let FontfamilyCurrencyName = "sar"
let GoogleKey = "AIzaSyDnETus6TKuK1XjPJmmLzIaRs-oHi9jotc"
let appName = (Bundle.main.infoDictionary!["CFBundleName"] as? String) ?? ""
let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"


let Notification_order_reload_Screen = "Notification_order_reload_Screen"
let Notification_reload_Screen = "Notification_reload_Screen"
let Notification_lock_Screen = "Notification_lock_Screen"
let handle_Notification_Screen = "handle_Notification_Screen"
let Notification_Determine_time = "Determine_Time"
let Notification_Unlock_Screen = "Unlock_Screen"
var Currency = "¥"

let appDelegate = UIApplication.shared.delegate as! AppDelegate

let Authontication = "Authorization"
let AddPlacesStry = "AddPlacesStry"
let SideMenue = "SidMenueStry"
let MapStry = "MapStry"
let AddressStry = "AddressStry"
let HomeStry = "Home"
let DriverStry = "DriverStry"
let OrderStry = "OrderStry"
let MoreStry = "MoreStry"
let CupounStry = "CupounStry"
let NotificationStry = "NotificationStry"
let ProfileStry = "ProfileStry"
let InvoicesStory = "InvoicesStory"
let WalletStry = "WalletStry"
let AlStatusstry = "AlStatusstry"
let ChatStry = "Chat"
let ZoomAbleImageStry = "ZoomAbleImage"
let PopUpsStry = "PopUp"
let CartStry = "CartStry"
let OrderDetails = "OrderDetails"
let Paymentstry = "Paymentstry"
let ServicesDetailsStry = "ServicesDetailsStry"


enum storyBoardName: String {
 
    case Authontication = "Authorization"
    case AddPlacesStry = "AddPlacesStry"
    case SideMenue = "SideMenue"
    case HomeStry = "Home"
    case OrderStry = "OrderStry"
    case MoreStry = "MoreStry"
    case CupounStry = "CupounStry"
    case NotificationStry = "NotificationStry"
    case ProfileStry = "ProfileStry"
    case InvoicesStory = "InvoicesStory"
    case WalletStry = "WalletStry"
    case RatingStry = "RatingStry"
    case BankStry = "BankStry"
    case FinancialStry = "FinancialStry"
    case ChatStry = "Chat"
    case ZoomAbleImageStry = "ZoomAbleImage"
    case PopUpsStry = "PopUp"
    
}

enum storyBoardVCIDs: String {
    case IntroVC = "IntroVC"
    case signUp = "signUpVc"
    case home = "mainMapsVC"
    case login = "logInVc"
    case Logout = "logout"
    case contactUsVc = "contactUsVc"
    case termsAndConditionVc = "termsAndConditionVc"
    case SideMenueVC = "SideMenueVC"
    case SendComplianceVC = "SendComplianceVC"
}
extension UIStoryboard {
    class func instantiateInitialViewController(_ board: storyBoardName) -> UIViewController {
        let story = UIStoryboard(name: board.rawValue, bundle: nil)
        return story.instantiateInitialViewController()!
    }
}
