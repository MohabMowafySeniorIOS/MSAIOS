//
//  View+Animations.swift
//  zoud
//
//  Created by Mohab on 8/20/21.
//

import Foundation
import UIKit
public protocol Animation {

    /// Defines the starting point for the animations.
    var initialTransform: CGAffineTransform { get }
}

// MARK: - UIView extension with animations.
public extension UIView {

    /// Performs the animation.
    ///
    /// - Parameters:
    ///   - animations: Array of Animations to perform on the animation block.
    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
    ///   - initialAlpha: Initial alpha of the view prior to the animation.
    ///   - finalAlpha: View's alpha after the animation.
    ///   - delay: Time Delay before the animation.
    ///   - duration: TimeInterval the animation takes to complete.
    ///   - dampingRatio: The damping ratio for the spring animation.
    ///   - velocity: The initial spring velocity.
    ///   - completion: CompletionBlock after the animation finishes.
    func animate(animations: [Animation],
                 reversed: Bool = false,
                 initialAlpha: CGFloat = 0.0,
                 finalAlpha: CGFloat = 1.0,
                 delay: Double = 0,
                 duration: TimeInterval = ViewAnimatorConfig.duration,
                 usingSpringWithDamping dampingRatio: CGFloat = ViewAnimatorConfig.springDampingRatio,
                 initialSpringVelocity velocity: CGFloat = ViewAnimatorConfig.initialSpringVelocity,
                 options: UIView.AnimationOptions = [],
                 completion: (() -> Void)? = nil) {
        
        let transformFrom = transform
        var transformTo = transform
        animations.forEach { transformTo = transformTo.concatenating($0.initialTransform) }
        if !reversed {
            transform = transformTo
        }

        alpha = initialAlpha
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: dampingRatio,
                       initialSpringVelocity: velocity,
                       options: options,
                       animations: { [weak self] in
            self?.transform = reversed ? transformTo : transformFrom
            self?.alpha = finalAlpha
        }) { _ in
            completion?()
        }
    }
    
    /// Performs the animation.
    ///
    /// - Parameters:
    ///   - animations: Array of Animations to perform on the animation block.
    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
    ///   - initialAlpha: Initial alpha of the view prior to the animation.
    ///   - finalAlpha: View's alpha after the animation.
    ///   - delay: Time Delay before the animation.
    ///   - animationInterval: Interval between the animations of each view.
    ///   - duration: TimeInterval the animation takes to complete.
    ///   - dampingRatio: The damping ratio for the spring animation.
    ///   - velocity: The initial spring velocity.
    ///   - completion: CompletionBlock after the animation finishes.
    static func animate(views: [UIView],
                        animations: [Animation],
                        reversed: Bool = false,
                        initialAlpha: CGFloat = 0.0,
                        finalAlpha: CGFloat = 1.0,
                        delay: Double = 0,
                        animationInterval: TimeInterval = 0.05,
                        duration: TimeInterval = ViewAnimatorConfig.duration,
                        usingSpringWithDamping dampingRatio: CGFloat = ViewAnimatorConfig.springDampingRatio,
                        initialSpringVelocity velocity: CGFloat = ViewAnimatorConfig.initialSpringVelocity,
                        options: UIView.AnimationOptions = [],
                        completion: (() -> Void)? = nil) {

        guard views.count > 0 else {
            completion?()
            return
        }
        
        views.forEach { $0.alpha = initialAlpha }
        let dispatchGroup = DispatchGroup()
        for _ in 1...views.count { dispatchGroup.enter() }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            for (index, view) in views.enumerated() {
                view.alpha = initialAlpha
                view.animate(animations: animations,
                             reversed: reversed,
                             initialAlpha: initialAlpha,
                             finalAlpha: finalAlpha,
                             delay: Double(index) * animationInterval,
                             duration: duration,
                             usingSpringWithDamping: dampingRatio,
                             initialSpringVelocity: velocity,
                             options: options,
                             completion: { dispatchGroup.leave() })
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
}



public class ViewAnimatorConfig {
    
    /// Amount of movement in points.
    /// Depends on the Direction given to the AnimationType.
    public static var offset: CGFloat = 30.0
    
    /// Duration of the animation.
    public static var duration: Double = 0.3
    
    /// Interval for animations handling multiple views that need
    /// to be animated one after the other and not at the same time.
    public static var interval: Double = 0.075
    
    /// Maximum zoom to be applied in animations using random AnimationType.zoom.
    public static var maxZoomScale: Double = 2.0
    
    /// Maximum rotation (left or right) to be applied in animations using random AnimationType.rotate
    public static var maxRotationAngle: CGFloat = CGFloat.pi/4

    /// The damping ratio for the spring animation as it approaches its quiescent state.
    public static var springDampingRatio: CGFloat = 1
    
    /// The initial spring velocity. For smooth start to the animation, match this value to the view’s velocity as it was prior to attachment.
    public static var initialSpringVelocity: CGFloat = 0
}


public enum AnimationType: Animation {

    case from(direction: Direction, offset: CGFloat)
    case zoom(scale: CGFloat)
    case rotate(angle: CGFloat)
    
    /// Creates the corresponding CGAffineTransform for AnimationType.from.
    public var initialTransform: CGAffineTransform {
        switch self {
        case .from(let direction, let offset):
            let sign = direction.sign
            if direction.isVertical { return CGAffineTransform(translationX: 0, y: offset * sign) }
            return CGAffineTransform(translationX: offset * sign, y: 0)
        case .zoom(let scale):
             return CGAffineTransform(scaleX: scale, y: scale)
        case .rotate(let angle):
            return CGAffineTransform(rotationAngle: angle)
        }
    }
    
    /// Generates a random Animation.
    ///
    /// - Returns: Newly generated random Animation.
    public static func random() -> Animation {
        let index = Int.random(in: 0..<3)
        if index == 1 {
            return AnimationType.from(direction: Direction.random(),
                                      offset: ViewAnimatorConfig.offset)
        } else if index == 2 {
            let scale = Double.random(in: 0...ViewAnimatorConfig.maxZoomScale)
            return AnimationType.zoom(scale: CGFloat(scale))
        }
        let angle = CGFloat.random(in: -ViewAnimatorConfig.maxRotationAngle...ViewAnimatorConfig.maxRotationAngle)
        return AnimationType.rotate(angle: angle)
    }
}
public enum Direction: Int, CaseIterable {

    case top
    case left
    case right
    case bottom
    
    /// Checks if the animation should go on the X or Y axis.
    var isVertical: Bool {
        switch self {
        case .top, .bottom:
            return true
        default:
            return false
        }
    }

    /// Positive or negative value to determine the direction.
    var sign: CGFloat {
        switch self {
        case .top, .left:
            return -1
        case .right, .bottom:
            return 1
        }
    }

    /// Random direction.
    static func random() -> Direction {
        return allCases.randomElement()!
    }
}


extension UIView {
    func flipX() {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    
    func flipY() {
        transform = CGAffineTransform(scaleX: transform.a, y: -transform.d)
    }
}
