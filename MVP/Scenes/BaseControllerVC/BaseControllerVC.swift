//
//  BaseControllerVC.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import UIKit

import Alamofire


var Picker_Color = UIColor.SecondarColor
var Picker_font = AppFont.Regular.size(18)

final class MSAPullToRefreshControl: UIRefreshControl {
    var onRefresh: (() -> Void)?

    @objc func triggerRefresh() {
        onRefresh?()
    }
}

extension UIViewController {
    @discardableResult
    func addMSAPullToRefresh(
        to scrollView: UIScrollView,
        action: @escaping () -> Void
    ) -> MSAPullToRefreshControl {
        let refresh = MSAPullToRefreshControl()
        refresh.tintColor = UIColor.MainColor
        refresh.onRefresh = action
        refresh.addTarget(refresh, action: #selector(MSAPullToRefreshControl.triggerRefresh), for: .valueChanged)
        scrollView.refreshControl = refresh
        return refresh
    }
}

class BaseControllerVC: UIViewController {
    
  //  let normalRefresh = NormalHeaderAnimator()
  
    
    func createDatePicker(is_minimum : Bool,is_maximum : Bool , current_date : String) -> UIDatePicker {
        let newMinimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        let picker = UIDatePicker()
        if is_minimum {
            picker.minimumDate = newMinimumDate
        }
        
        if is_maximum {
            picker.maximumDate = newMinimumDate
        }
        let calendar = Calendar.current
        var minDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        let isoDate = current_date
        let dateFormatter = DateFormatter()
         dateFormatter.locale = Locale(identifier: "ar") // set locale to reliable US_POSIX
         dateFormatter.dateFormat = "yyyy-MM-dd"
         let date = dateFormatter.date(from:isoDate)
        
        if let date = date {
            let monthInt = Calendar.current.component(.month, from: date)
              let dayInt = Calendar.current.component(.day, from: date)
              let yearInt = Calendar.current.component(.year, from: date)
            
            minDateComponent.day = dayInt
            minDateComponent.month = monthInt
            minDateComponent.year = yearInt
        }
       
       
        
        picker.date = Calendar.current.date(from: minDateComponent) ?? Date()
        picker.backgroundColor = .white

        
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
                // Fallback on earlier versions
        }
        picker.backgroundColor = .white
        picker.locale = Locale.init(identifier: "ar")
        return picker
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func openGoogleMap(latitude : String,lng : String) {
         guard  let latDouble = Double(latitude) else {return }
        
         guard let longDouble =  Double(lng) else {return }
          if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app

              if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:])
               }}
          else {
                 //Open in browser
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                                   UIApplication.shared.open(urlDestination)
                               }
                    }

            }
    
    func createTimePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        
        //picker.minimumDate = Date()
        picker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
                // Fallback on earlier versions
        }
        picker.backgroundColor = .white
        return picker
    }
    
  //   pagination properities
    var isActive = false
     func createSpinnerFooter() -> UIView {
        let FooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))

        FooterView.backgroundColor = .clear
        let spinner = UIActivityIndicatorView()
        
        spinner.style = .large
        spinner.color = UIColor.MainColor
        
        spinner.center = FooterView.center
        FooterView.addSubview(spinner)
        spinner.startAnimating()

        return FooterView

    }
    var CurrentPage = 1
    var lastPage = 1
    
    
    // Pagination with closure
    
    var isLoaded_Closure : (()->())?
    
  
    
    var noData_view : NoDataView!
    var AnError_view : AnErrorView!
    var nonet : NoNetView!
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
   var is_net_exist = false
    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: AppFont.Medium.size(16),
            NSAttributedString.Key.foregroundColor: UIColor.MainColor!
            
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            // خط العناوين من الهوية
            NSAttributedString.Key.font: AppDisplayFont.bold.size(24),
        ]
//        normalRefresh.releaseToRefreshDescription = NSLocalizedString("releaseToRefresh".localized, comment: "")
//        normalRefresh.loadingDescription = NSLocalizedString("loading".localized, comment: "")
//        normalRefresh.pullToRefreshDescription = NSLocalizedString("pullToRefresh".localized, comment: "")
     
        
        let net = NetworkReachabilityManager()
              net?.startListening()
        net?.listener =
            { status in

                if  net?.isReachable ?? false
                {
                    if self.nonet != nil{
                        self.nonet.removeFromSuperview()
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        if let currentVC = UIApplication.getTopViewController() {
                            ApiServices.GetInstance().moveToOffilne(VC: self)
                        }
                    }
                    return
                   // self.show_NoDataView(View: self.view)
                }
            }
        
        
      //  self.navigationController?.interactivePopGestureRecognizer?.delegate = self
       // self.view.backgroundColor = UIColor.BackGrondColor
        setupTextFelidTintColor()
        setupTextViewTintColor()
    }


    func getMonthAndYearBetween(from start: Date, to end: Date) -> [Date] {
            var allDates: [Date] = []
            guard start < end else { return allDates }
            
            let calendar = Calendar.current
            let month = calendar.dateComponents([.month], from: start, to: end).month ?? 0
            
            for i in 0...month {
                if let date = calendar.date(byAdding: .month, value: i, to: start) {
                    allDates.append(date)
                }
            }
            return allDates
        }
    
    func daysTo(date_from: Date , date_to: Date) -> Int? {
        let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: date_from)
        let date2 = calendar.startOfDay(for: date_to)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day  // This will return the number of day(s) between dates
    }
    
   
    func openWhatsAppChat(phoneNumber: String) {
        let phoneNumberEncoded = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let whatsappURL = URL(string: "https://wa.me/\(phoneNumberEncoded)")!

        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
        } else {
            print("WhatsApp is not installed on this device.")
        }
    }
    
    func getPagination(CurrentPage : Int , lastPage:Int) {
       
            self.CurrentPage = CurrentPage
            self.lastPage = lastPage
            self.isActive = true
        
    }
    
    
   
    
 
    
    /// show no data view
    func show_NoDataView(View : UIView){
        
        
        let topArea = UIApplication.topSafeAreaHeight
        let frame1: CGRect = CGRect(x: 0, y: topArea , width: self.view.frame.width, height: self.view.frame.height - topArea)
        nonet = NoNetView(frame: frame1)
        nonet.noNetAction = {
            if self.nonet != nil{
                self.nonet.removeFromSuperview()
            }
            
        }
        self.view.addSubview(nonet)
        
        
        
        
    }
    ///hide no data view
    func hide_NoConnectionView(View : UIView){
        if nonet != nil{
            nonet.removeFromSuperview()
        }
        
    }
    
    
    func setupTextFelidTintColor(){
        UITextField.appearance().tintColor  = UIColor.MainColor
    
    }
    
    func setupTextViewTintColor(){
        UITextView.appearance().tintColor =  UIColor.MainColor
    }
    
    
    /// show An Error view
    func show_AnErrorView(View : UIView){
        let topArea = UIApplication.topSafeAreaHeight
        let frame1: CGRect = CGRect(x: 0, y: topArea , width: self.view.frame.width, height: self.view.frame.height - topArea)
        AnError_view = AnErrorView(frame: frame1)
        AnError_view.noNetAction = {
            if self.nonet != nil{
                self.AnError_view.removeFromSuperview()
            }
            
        }
        self.view.addSubview(AnError_view)
    }

    ///hide an Error view
    func hide_AnErrorView(View : UIView){
        if AnError_view != nil{
            AnError_view.removeFromSuperview()
        }
    }

   
    
    func shareApp(){
       
        let url = URL(string: "https://apps.apple.com/app/id\(AppleId)")!

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        present(activityVC, animated: true)
    }
}




extension UIApplication {
    static var topSafeAreaHeight: CGFloat {
        var topSafeAreaHeight: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            topSafeAreaHeight = safeFrame.minY
        }
        return topSafeAreaHeight
    }
}
extension UIApplication {

    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
