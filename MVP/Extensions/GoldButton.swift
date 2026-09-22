//
//  خميأعففخر.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Foundation
import UIKit


class GoldButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    private let shineLayer = CAGradientLayer()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        clipsToBounds = false
        layer.cornerRadius = 14
        
        setupGradient()
        setupShine()
        setupShadow()
        setupTitle()
        setupTouchAnimation()
    }
    
    // MARK: - Gradient
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(hex: "#F2D28C").cgColor,
            UIColor(hex: "#E8B138").cgColor,
            UIColor(hex: "#A77F28").cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = 14
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Shine Effect
    private func setupShine() {
        shineLayer.colors = [
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        
        shineLayer.startPoint = CGPoint(x: 0, y: 0)
        shineLayer.endPoint = CGPoint(x: 1, y: 1)
        shineLayer.cornerRadius = 14
        
        layer.insertSublayer(shineLayer, above: gradientLayer)
    }
    
    // MARK: - Shadow (Luxury Look)
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    // MARK: - Title
    private func setupTitle() {
        setTitleColor(.WhiteColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    // MARK: - Press Animation
    private func setupTouchAnimation() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }
    
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.9
        }
    }
    
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        shineLayer.frame = bounds
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }
}
