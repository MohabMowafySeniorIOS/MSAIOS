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

        // العناصر غير المرغوبة من قائمة «المزيد» متوقفة على iOS كمان.
        hideRemovedMenuRows()
    }

    private func hideRemovedMenuRows() {
        view.layoutIfNeeded()
        let removedTitles: Set<String> = [
            "My Wallet", "محفظتي", "My Portfolio",
            "Profile", "حسابي", "My Account"
        ]

        func walk(_ node: UIView) {
            for child in node.subviews {
                if let label = child as? UILabel, removedTitles.contains(label.text ?? "") {
                    var current: UIView? = label
                    while let item = current, let parent = item.superview {
                        if let stack = parent as? UIStackView,
                           stack.axis == .vertical,
                           item.bounds.height >= 45,
                           item.bounds.width >= 250 {
                            stack.removeArrangedSubview(item)
                            item.removeFromSuperview()
                            break
                        }
                        current = parent
                    }
                }
                walk(child)
            }
        }

        walk(view)
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
    
    /// الحساب — دخول أو تسجيل، أو خروج لو مسجّل بالفعل
    @IBAction func AccountAction(_ sender: Any) {
        // لو مسجّل يروح للبروفايل — الخروج وحذف الحساب جوّاه
        if AuthSession.shared.isLoggedIn {
            pushProfile()
        } else {
            pushLogin()
        }
    }

    private func pushProfile() {
        var view = ProfileView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onSignedOut = { [weak self] in self?.popAuth() }
        host.rootView = view
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    /// المحفظة — بتتفتح من صف «محفظتي» في القايمة
    @IBAction func WalletAction(_ sender: Any) {
        var view = WalletView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onLogin = { [weak self] in self?.pushLogin() }
        host.rootView = view
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    /// شاشات الحساب متسلسلة على نفس الـ navigation stack:
    /// دخول ⇄ تسجيل ← تأكيد الكود، وبعد النجاح بنرجع لشاشة المزيد.
    func pushLogin() {
        var view = LoginView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.popAuth() }
        view.onFinished = { [weak self] in self?.popAuth() }
        view.onGoRegister = { [weak self] in self?.pushRegister(replacing: true) }
        view.onNeedVerify = { [weak self] phone in self?.pushVerify(phone: phone) }
        host.rootView = view
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    private func pushRegister(replacing: Bool) {
        var view = RegisterView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.popAuth() }
        view.onCodeSent = { [weak self] phone in self?.pushVerify(phone: phone) }
        view.onGoLogin = { [weak self] in self?.swapToLogin() }
        host.rootView = view

        guard replacing, var stack = navigationController?.viewControllers else {
            navigationController?.pushViewController(host, animated: true)
            return
        }
        // بنستبدل شاشة الدخول بدل ما نكدّس الاتنين فوق بعض،
        // وإلا زرار الرجوع هيرجّعه لشاشة دخول مش شاشة المزيد.
        stack.removeLast()
        stack.append(host)
        navigationController?.setViewControllers(stack, animated: true)
    }

    private func swapToLogin() {
        guard var stack = navigationController?.viewControllers else { return }
        var view = LoginView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.popAuth() }
        view.onFinished = { [weak self] in self?.popAuth() }
        view.onGoRegister = { [weak self] in self?.pushRegister(replacing: true) }
        view.onNeedVerify = { [weak self] phone in self?.pushVerify(phone: phone) }
        host.rootView = view
        stack.removeLast()
        stack.append(host)
        navigationController?.setViewControllers(stack, animated: true)
    }

    private func pushVerify(phone: String) {
        var view = VerifyOtpView(phone: phone)
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.onVerified = { [weak self] in self?.popAuth() }
        host.rootView = view
        navigationController?.pushViewController(host, animated: true)
    }

    /// الرجوع لشاشة المزيد وإخفاء كل شاشات الحساب من الـ stack
    private func popAuth() {
        navigationController?.popToViewController(self, animated: true)
    }

    /// الإعدادات — تحكّم منفصل لكل نوع إشعار
    @IBAction func SettingsAction(_ sender: Any) {
        var view = SettingsView()
        let hostingController = UIHostingController(rootView: view)
        // الرجوع بيتم بالـ pop مباشرة، مش بـ dismiss — لأن الشاشة متدفوعة
        // على الـ navigation stack مش معروضة كـ sheet.
        view.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        hostingController.rootView = view
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }

    /// المؤشرات — بقت رسم بياني حيّ من تريدنج فيو بدل بيانات مولّدة محلياً
    @IBAction func IndicatorAction(_ sender: Any) {
        var view = IndicatorsMarketView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = view
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
    }

    /// التحليل الفني — تقييم حيّ بدل أرقام مكتوبة ثابتة
    @IBAction func TechnicalAnalysisAction(_ sender: Any) {
        var view = TechnicalAnalysisMarketView()
        let host = UIHostingController(rootView: view)
        view.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        host.rootView = view
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(host, animated: true)
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
