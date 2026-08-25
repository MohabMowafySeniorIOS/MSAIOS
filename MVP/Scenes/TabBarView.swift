//
//  TabBarView.swift
//  MSA
//
//  Created by Mohab Mowafy on 19/05/2026.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
    }

    private func setupTabs() {

        tabBar.items?[0].title = "Screen".localized
        tabBar.items?[1].title = "Currency prices".localized
        tabBar.items?[2].title = "Billions".localized
        tabBar.items?[3].title = "News".localized
        tabBar.items?[4].title = "More".localized
    }
}
