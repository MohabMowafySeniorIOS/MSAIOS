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

        setupTabBarBackground()
        setupTabs()
    }

    /// إصلاح «التاب بار بيبيض» في شاشة السبائك.
    ///
    /// من iOS 15، الـ tab bar بيبدّل بين مظهرين:
    ///   • `standardAppearance`   — لما المحتوى بيتمرّر تحت الشريط
    ///   • `scrollEdgeAppearance` — لما مفيش محتوى بيتمرّر (الشاشة قصيرة)
    ///
    /// في الاستوري بورد الأول متظبط بلون `SecondarColor` مع blur:
    ///     <tabBarAppearance key="standardAppearance" backgroundEffect="regular">
    /// والتاني سايب فاضي:
    ///     <tabBarAppearance key="scrollEdgeAppearance"/>
    ///
    /// المظهر الفاضي معناه الخلفية الافتراضية بتاعة النظام — بيضا في الوضع الفاتح.
    /// عشان كده الشريط بيبان غامق في «الشاشة العالمية» (محتواها طويل وبيتمرّر)
    /// وبيبيض في «السبائك» (ثلاث قوايم بس، مفيش تمرير).
    ///
    /// الحل: ننسخ نفس مظهر الاستوري بورد على الحالتين، فالشريط ما يفرقش
    /// حسب طول محتوى الشاشة.
    private func setupTabBarBackground() {
        guard #available(iOS 15.0, *) else { return }
        // نسخة من المظهر المظبوط في الاستوري بورد — بنفس اللون والـ blur
        // وألوان العناصر، من غير ما نعيد كتابتها هنا.
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
    }

    private func setupTabs() {

        tabBar.items?[0].title = "Screen".localized
        tabBar.items?[1].title = "Currency prices".localized
        tabBar.items?[2].title = "Billions".localized
        tabBar.items?[3].title = "News".localized
        tabBar.items?[4].title = "More".localized
    }
}
