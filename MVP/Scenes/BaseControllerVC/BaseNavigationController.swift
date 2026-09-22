//
//  BaseNavigationController.swift
//  zoud
//
//  Created by Mohab on 8/21/21.
//



    


import Foundation
import UIKit


class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        delegate = self
    }
    
    private func setup() {
        
      
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .black
       
//        let backButton = UIBarButtonItem(title: "Custom", style: .plain, target: self, action: nil    )
//        //backButton.image = UIImage(named: "imageName") //Replaces title
//        backButton.setBackgroundImage(#imageLiteral(resourceName: "arrow.alt.left"), for: .normal, barMetrics: .default) // Stretches image
        //navigationItem.setLeftBarButton(backButton, animated: false)
        
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: AppFont.Medium.size(16),
            NSAttributedString.Key.foregroundColor: UIColor.MainColor!
            
        ]
        navigationBar.largeTitleTextAttributes = [
            // خط العناوين من الهوية
            NSAttributedString.Key.font: AppDisplayFont.bold.size(24),
        ]
      
        
        
    }
    
    // TODO:- Enhance it ----> Currently I disable back menu in iOS 14 because it's empty and needs some work in back button
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}

class BackBarButtonItem: UIBarButtonItem {
    @available(iOS 14.0, *)
    override var menu: UIMenu? {
        set {
            /* Don't set the menu here */
            /* super.menu = menu */
        }
        get {
            return super.menu
        }
    }
}
extension UIFont {
    
    static func qtsRegularFont(ofSize size: CGFloat = 15) -> UIFont {
        return .systemFont(ofSize: size) // UIFont(name: "ArialMT", size: size)
    }
    
    static func qtsBoldFont(ofSize size: CGFloat = 15) -> UIFont {
        return .boldSystemFont(ofSize: size) // UIFont(name: "Arial-BoldMT", size: size)
    }
    
    static func qtsSemibold(ofSize size: CGFloat = 15) -> UIFont {
        return .systemFont(ofSize: size, weight: .semibold)
    }
    
    static var qtsNoDataFont: UIFont {
        qtsRegularFont(ofSize: 15)
    }
    
}
