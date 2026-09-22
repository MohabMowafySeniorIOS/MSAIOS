//
//  LoaderExtentions.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//
//
//import UIKit
//import Foundation
import NVActivityIndicatorView

extension UIButton {
    func showLoading(_ show: Bool, _ lock: Bool = true, isBlack: Bool = false) {
        var activityIndicator: NVActivityIndicatorView!
        let tag = 808
        let view = UIView()
        if show {
            
            view.tag = tag
            isEnabled = false
            activityIndicator = NVActivityIndicatorView(frame: .zero)
            activityIndicator.color = .white // add your color
            activityIndicator.type = .circleStrokeSpin // add your type
            if isBlack {
                activityIndicator.color = .MainColor ?? .black
            }
            view.layer.cornerRadius = layer.cornerRadius
            view.backgroundColor = backgroundColor
            view.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
            addSubview(view)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor),
                view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
                view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1),
            ])
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                activityIndicator.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
                activityIndicator.widthAnchor.constraint(equalTo: activityIndicator.heightAnchor, multiplier: 1),
            ])

            activityIndicator.startAnimating()
            if lock {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        } else {
           
            isEnabled = true
            UIApplication.shared.endIgnoringInteractionEvents()

            if let view = viewWithTag(tag) {
                view.removeFromSuperview()
            }
        }
    }
}

extension UILabel {
    func showLoading(_ show: Bool, _ lock: Bool = true, _ isBlack: Bool = false) {
        var activityIndicator: NVActivityIndicatorView!
        let tag = 808
        let view = UIView()
        if show {
            
            view.tag = tag
            isEnabled = false
            activityIndicator = NVActivityIndicatorView(frame: .zero)
            activityIndicator.color = UIColor.MainColor! // add your color
            activityIndicator.type = .circleStrokeSpin // add your type
            if isBlack {
                activityIndicator.color = .black
            }
            view.layer.cornerRadius = layer.cornerRadius
            view.backgroundColor = backgroundColor
            view.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
            addSubview(view)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor),
                view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
                view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1),
            ])
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                activityIndicator.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
                activityIndicator.widthAnchor.constraint(equalTo: activityIndicator.heightAnchor, multiplier: 1),
            ])

            activityIndicator.startAnimating()
            if lock {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        } else {
           
            isEnabled = true
            UIApplication.shared.endIgnoringInteractionEvents()

            if let view = viewWithTag(tag) {
                view.removeFromSuperview()
            }
        }
    }
}
