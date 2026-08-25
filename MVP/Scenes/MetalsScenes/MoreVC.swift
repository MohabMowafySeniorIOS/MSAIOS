//
//  MoreVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 07/05/2026.
//

import Foundation
import Foundation
import UIKit
import SwiftUI
import StoreKit

class MoreVC: BaseControllerVC {
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var LogOutLabel: UILabel!
    @IBOutlet weak var PointsLAbel: UILabel!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var CurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var AboutView: UIView!
    @IBOutlet weak var AboutLineView: UIView!
    
    @IBOutlet weak var termsView: UIView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.pressShare = { [weak self] in
            guard let self else { return }
            self.shareApp()
        }
        self.title = "More".localized
        versionLabel.text = "Version".localized + ": \(appVersion)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
   
    
    @IBAction func PortfolioAction(_ sender: Any) {
        
        let hostingVC = UIHostingController(rootView: PortfolioScreen())
        hostingVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    @IBAction func MetalCalculatorAction(_ sender: Any) {
        
        let swiftUIView = CalculatorHomeSwiftUIView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    
//    @IBAction func joinUsAction(_ sender: Any) {
//        let swiftUIView = GoldChartView()
//
//        let hostingController = UIHostingController(rootView: swiftUIView)
//        tabBarController?.tabBar.isHidden = true
//        navigationController?.pushViewController(hostingController, animated: true)
//    }
    
    @IBAction func AboutUsVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: SideMenue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        vc.Item = .AboutUs
        vc.titleVar = "About Us".localized
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func TERMSACTION(_ sender: Any) {
        let storyboard = UIStoryboard(name: SideMenue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        vc.titleVar = "Terms Of Use".localized
        vc.Item = .terms_of_use
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    
    @IBAction func RefundAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: SideMenue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        vc.titleVar = "Refund".localized
        vc.Item = .Refund
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Privacyaction(_ sender: Any) {
        let storyboard = UIStoryboard(name: SideMenue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        vc.titleVar = "Privacy And Policy".localized
        vc.Item = .Privacy_policy
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func HelpAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: SideMenue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ContactUsAction(_ sender: Any) {
        let swiftUIView = ContactUsView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func FAQAction(_ sender: Any) {
        let swiftUIView = FAQVCSWIFTUI(viewModel: FAQViewModel())

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
   
    
    @IBAction func LAnguageAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: SideMenue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "ChooseLanguageVCFirst") as! ChooseLanguageVCFirst
        vc.is_fro_side = true
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    @IBAction func shareApp(_ sender: Any) {
        shareApp()
    }
    
    @IBAction func rateApp(_ sender: Any) {
        if let scene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene
        {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    @IBAction func IndicatorAction(_ sender: Any) {
        
        let swiftUIView = IndicatorsView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func TechnicalAnalysisAction(_ sender: Any) {
        
        let swiftUIView = TechnicalAnalysisView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    
   
}
//extension MoreVC : ConfirmAlertProtocol {
//    func Sucess(Item: DeleteStatusEnum, id: String) {
//        tabBarController?.tabBar.isHidden = true
//        if Item == .LogOut {
//          //  LogOut()
//        }else {
//            //  DeleteAccount()
//        }
//    }
//    
//    
//    
//}

extension  MoreVC  {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        var image_choosen = UIImage()
        if let image = info[.originalImage] as? UIImage{
            image_choosen = image
        }else{
            if let imageEdit = info[.editedImage] as? UIImage{
                image_choosen = imageEdit
            }
        }
        //  ImgProfile.image = image_choosen
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}

