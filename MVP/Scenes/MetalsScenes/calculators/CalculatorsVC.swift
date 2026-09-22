//
//  CalculatorsVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 16/04/2026.
//

import UIKit
import SwiftUI

class CalculatorsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func goldCalculatorAction(_ sender: Any) {
        let swiftUIView = GoldValueCalculatorView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
   
   
    
    @IBAction func SilverPriceViewAction(_ sender: Any) {
        let swiftUIView = SilverCalculatorView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
 
    
    @IBAction func zakatCalculatorAction(_ sender: Any) {
        let swiftUIView = ZakatView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func silverZakatCalculatorAction(_ sender: Any) {
        let swiftUIView = SilverZakatView()

        let hostingController = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }

}
