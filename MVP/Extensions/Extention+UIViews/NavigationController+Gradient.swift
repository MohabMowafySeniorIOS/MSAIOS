//
//  NavigationController+Gradient.swift
//  zoud
//
//  Created by Mohab on 8/20/21.
//

import Foundation
import UIKit

extension UINavigationBar {
    func setGradientBackground(colors: [UIColor], gradientOrientation orientation: GradientOrientation) {
       
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        var bounds = self.bounds
         bounds.size.height += UIApplication.shared.statusBarFrame.size.height
         gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor };
        
        self.setBackgroundImage(self.image(fromLayer: gradient), for: UIBarMetrics.default)
    }

    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}

