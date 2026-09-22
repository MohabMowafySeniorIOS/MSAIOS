//
//  LoaderViewProtocol.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol LoaderViewProtocol: class {
    func startLoading()
    func stopLoading()
}

extension LoaderViewProtocol where Self: UIViewController {

    func startLoading(){
        let activityIndicatorView = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 50, height: 50), type: .ballClipRotateMultiple, color: .MainColor, padding: .zero)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
    }
    
    func stopLoading(){
        DispatchQueue.main.async {
            if let indicator = self.view.subviews.first(where: {$0 is NVActivityIndicatorView }) as? NVActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }

    }
}
