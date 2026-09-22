////
////  SkeltonView.swift
////  DemoProject
////
////  Created by Mohab on 12/16/20.
////  Copyright © 2020 MOHAB. All rights reserved.
////
//
//import SkeletonView
//import Foundation
//public extension UIView {
//    /// Shows the skeleton without animation using the view that calls this method as root view.
//    ///
//    /// - Parameters:
//    ///   - color: The color of the skeleton. Defaults to `SkeletonAppearance.default.tintColor`.
//    ///   - transition: The style of the transition when the skeleton appears. Defaults to `.crossDissolve(0.25)`.
//    func showSkeleton(usingColor color: UIColor = SkeletonAppearance.default.tintColor, transition: SkeletonTransitionStyle = .crossDissolve(0.25)) {
//        let config = SkeletonConfig(type: .solid, colors: [color], transition: transition)
//        showSkeleton(skeletonConfig: config)
//    }
//    
//    /// Shows the gradient skeleton without animation using the view that calls this method as root view.
//    ///
//    /// - Parameters:
//    ///   - gradient: The gradient of the skeleton. Defaults to `SkeletonAppearance.default.gradient`.
//    ///   - transition: The style of the transition when the skeleton appears. Defaults to `.crossDissolve(0.25)`.
//    func showGradientSkeleton(usingGradient gradient: SkeletonGradient = SkeletonAppearance.default.gradient, transition: SkeletonTransitionStyle = .crossDissolve(0.25)) {
//        let config = SkeletonConfig(type: .gradient, colors: gradient.colors, transition: transition)
//        showSkeleton(skeletonConfig: config)
//    }
//    
//    /// Shows the animated skeleton using the view that calls this method as root view.
//    ///
//    /// If animation is nil, sliding animation will be used, with direction left to right.
//    ///
//    /// - Parameters:
//    ///   - color: The color of skeleton. Defaults to `SkeletonAppearance.default.tintColor`.
//    ///   - animation: The animation of the skeleton. Defaults to `nil`.
//    ///   - transition: The style of the transition when the skeleton appears. Defaults to `.crossDissolve(0.25)`.
//    func showAnimatedSkeleton(usingColor color: UIColor = SkeletonAppearance.default.tintColor, animation: SkeletonLayerAnimation? = nil, transition: SkeletonTransitionStyle = .crossDissolve(0.25)) {
//        let config = SkeletonConfig(type: .solid, colors: [color], animated: true, animation: animation, transition: transition)
//        showSkeleton(skeletonConfig: config)
//    }
//    
//    /// Shows the gradient skeleton without animation using the view that calls this method as root view.
//    ///
//    /// If animation is nil, sliding animation will be used, with direction left to right.
//    ///
//    /// - Parameters:
//    ///   - gradient: The gradient of the skeleton. Defaults to `SkeletonAppearance.default.gradient`.
//    ///   - animation: The animation of the skeleton. Defaults to `nil`.
//    ///   - transition: The style of the transition when the skeleton appears. Defaults to `.crossDissolve(0.25)`.
//    func showAnimatedGradientSkeleton(usingGradient gradient: SkeletonGradient = SkeletonAppearance.default.gradient, animation: SkeletonLayerAnimation? = nil, transition: SkeletonTransitionStyle = .crossDissolve(0.25)) {
//        let config = SkeletonConfig(type: .gradient, colors: gradient.colors, animated: true, animation: animation, transition: transition)
//        showSkeleton(skeletonConfig: config)
//    }
//
//    func updateSkeleton(usingColor color: UIColor = SkeletonAppearance.default.tintColor) {
//        let config = SkeletonConfig(type: .solid, colors: [color])
//        updateSkeleton(skeletonConfig: config)
//    }
//
//    func updateGradientSkeleton(usingGradient gradient: SkeletonGradient = SkeletonAppearance.default.gradient) {
//        let config = SkeletonConfig(type: .gradient, colors: gradient.colors)
//        updateSkeleton(skeletonConfig: config)
//    }
//
//    func updateAnimatedSkeleton(usingColor color: UIColor = SkeletonAppearance.default.tintColor, animation: SkeletonLayerAnimation? = nil) {
//        let config = SkeletonConfig(type: .solid, colors: [color], animated: true, animation: animation)
//        updateSkeleton(skeletonConfig: config)
//    }
//
//    func updateAnimatedGradientSkeleton(usingGradient gradient: SkeletonGradient = SkeletonAppearance.default.gradient, animation: SkeletonLayerAnimation? = nil) {
//        let config = SkeletonConfig(type: .gradient, colors: gradient.colors, animated: true, animation: animation)
//        updateSkeleton(skeletonConfig: config)
//    }
//
//    func layoutSkeletonIfNeeded() {
//        flowDelegate?.willBeginLayingSkeletonsIfNeeded(rootView: self)
//        recursiveLayoutSkeletonIfNeeded(root: self)
//    }
//    
//    func hideSkeleton(reloadDataAfter reload: Bool = true, transition: SkeletonTransitionStyle = .crossDissolve(0.25)) {
//        flowDelegate?.willBeginHidingSkeletons(rootView: self)
//        recursiveHideSkeleton(reloadDataAfter: reload, transition: transition, root: self)
//    }
//    
//    func startSkeletonAnimation(_ anim: SkeletonLayerAnimation? = nil) {
//        subviewsSkeletonables.recursiveSearch(leafBlock: startSkeletonLayerAnimationBlock(anim)) { subview in
//            subview.startSkeletonAnimation(anim)
//        }
//    }
//
//    func stopSkeletonAnimation() {
//        subviewsSkeletonables.recursiveSearch(leafBlock: stopSkeletonLayerAnimationBlock) { subview in
//            subview.stopSkeletonAnimation()
//        }
//    }
//}
//extension UIView {
//    enum Status {
//        case on
//        case off
//    }
//
//    var flowDelegate: SkeletonFlowDelegate? {
//        get { return ao_get(pkey: &ViewAssociatedKeys.flowDelegate) as? SkeletonFlowDelegate }
//        set { ao_setOptional(newValue, pkey: &ViewAssociatedKeys.flowDelegate) }
//    }
//
//    var skeletonLayer: SkeletonLayer? {
//        get { return ao_get(pkey: &ViewAssociatedKeys.skeletonLayer) as? SkeletonLayer }
//        set { ao_setOptional(newValue, pkey: &ViewAssociatedKeys.skeletonLayer) }
//    }
//
//    var currentSkeletonConfig: SkeletonConfig? {
//        get { return ao_get(pkey: &ViewAssociatedKeys.currentSkeletonConfig) as? SkeletonConfig }
//        set { ao_setOptional(newValue, pkey: &ViewAssociatedKeys.currentSkeletonConfig) }
//    }
//
//    var status: Status! {
//        get { return ao_get(pkey: &ViewAssociatedKeys.status) as? Status ?? .off }
//        set { ao_set(newValue ?? .off, pkey: &ViewAssociatedKeys.status) }
//    }
//
//    var isSkeletonAnimated: Bool! {
//        get { return ao_get(pkey: &ViewAssociatedKeys.isSkeletonAnimated) as? Bool ?? false }
//        set { ao_set(newValue ?? false, pkey: &ViewAssociatedKeys.isSkeletonAnimated) }
//    }
//}
//
//extension UIView {
//    @objc func skeletonLayoutSubviews() {
//        skeletonLayoutSubviews()
//        guard isSkeletonActive else { return }
//        layoutSkeletonIfNeeded()
//    }
//
//    @objc func skeletonTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        skeletonTraitCollectionDidChange(previousTraitCollection)
//        guard isSkeletonable, isSkeletonActive, let config = currentSkeletonConfig else { return }
//        updateSkeleton(skeletonConfig: config)
//    }
//    
//    func showSkeleton(skeletonConfig config: SkeletonConfig) {
//        isSkeletonAnimated = config.animated
//        flowDelegate = SkeletonFlowHandler()
//        flowDelegate?.willBeginShowingSkeletons(rootView: self)
//        recursiveShowSkeleton(skeletonConfig: config, root: self)
//    }
//
//    private func recursiveShowSkeleton(skeletonConfig config: SkeletonConfig, root: UIView? = nil) {
//        guard isSkeletonable && !isSkeletonActive else { return }
//        currentSkeletonConfig = config
//        swizzleLayoutSubviews()
//        swizzleTraitCollectionDidChange()
//        addDummyDataSourceIfNeeded()
//        subviewsSkeletonables.recursiveSearch(leafBlock: {
//            showSkeletonIfNotActive(skeletonConfig: config)
//        }){ subview in
//            subview.recursiveShowSkeleton(skeletonConfig: config)
//        }
//
//        if let root = root {
//            flowDelegate?.didShowSkeletons(rootView: root)
//        }
//    }
//
//    private func showSkeletonIfNotActive(skeletonConfig config: SkeletonConfig) {
//        guard !isSkeletonActive else { return }
//        saveViewState()
//        isUserInteractionEnabled = false
//        prepareViewForSkeleton()
//        addSkeletonLayer(skeletonConfig: config)
//    }
//
//    func updateSkeleton(skeletonConfig config: SkeletonConfig) {
//        isSkeletonAnimated = config.animated
//        flowDelegate?.willBeginUpdatingSkeletons(rootView: self)
//        recursiveUpdateSkeleton(skeletonConfig: config, root: self)
//    }
//
//    private func recursiveUpdateSkeleton(skeletonConfig config: SkeletonConfig, root: UIView? = nil) {
//        guard isSkeletonActive else { return }
//        currentSkeletonConfig = config
//        updateDummyDataSourceIfNeeded()
//        subviewsSkeletonables.recursiveSearch(leafBlock: {
//            if skeletonLayer?.type != config.type {
//                removeSkeletonLayer()
//                addSkeletonLayer(skeletonConfig: config)
//            } else {
//                updateSkeletonLayer(skeletonConfig: config)
//            }
//        }) { subview in
//            subview.recursiveUpdateSkeleton(skeletonConfig: config)
//        }
//
//        if let root = root {
//            flowDelegate?.didUpdateSkeletons(rootView: root)
//        }
//    }
//
//    private func recursiveLayoutSkeletonIfNeeded(root: UIView? = nil) {
//        subviewsSkeletonables.recursiveSearch(leafBlock: {
//            guard isSkeletonable, isSkeletonActive else { return }
//            layoutSkeletonLayerIfNeeded()
//            if let config = currentSkeletonConfig, config.animated, !isSkeletonAnimated {
//                startSkeletonAnimation(config.animation)
//            }
//        }) { subview in
//            subview.recursiveLayoutSkeletonIfNeeded()
//        }
//
//        if let root = root {
//            flowDelegate?.didLayoutSkeletonsIfNeeded(rootView: root)
//        }
//    }
//
//    private func recursiveHideSkeleton(reloadDataAfter reload: Bool, transition: SkeletonTransitionStyle, root: UIView? = nil) {
//        guard isSkeletonActive else { return }
//        currentSkeletonConfig?.transition = transition
//        isUserInteractionEnabled = true
//        removeDummyDataSourceIfNeeded(reloadAfter: reload)
//        subviewsSkeletonables.recursiveSearch(leafBlock: {
//            recoverViewState(forced: false)
//            removeSkeletonLayer()
//        }) { subview in
//            subview.recursiveHideSkeleton(reloadDataAfter: reload, transition: transition)
//        }
//        
//        if let root = root {
//            flowDelegate?.didHideSkeletons(rootView: root)
//        }
//    }
//    
//    private func startSkeletonLayerAnimationBlock(_ anim: SkeletonLayerAnimation? = nil) -> VoidBlock {
//        return {
//            self.isSkeletonAnimated = true
//            guard let layer = self.skeletonLayer else { return }
//            layer.start(anim) { [weak self] in
//                self?.isSkeletonAnimated = false
//            }
//        }
//    }
//    
//    private var stopSkeletonLayerAnimationBlock: VoidBlock {
//        return {
//            self.isSkeletonAnimated = false
//            guard let layer = self.skeletonLayer else { return }
//            layer.stopAnimation()
//        }
//    }
//    
//    private func swizzleLayoutSubviews() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//            DispatchQueue.once(token: "UIView.SkeletonView.swizzleLayoutSubviews") {
//                swizzle(selector: #selector(UIView.layoutSubviews),
//                        with: #selector(UIView.skeletonLayoutSubviews),
//                        inClass: UIView.self,
//                        usingClass: UIView.self)
//                self.layoutSkeletonIfNeeded()
//            }
//        }
//    }
//
//    private func swizzleTraitCollectionDidChange() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//            DispatchQueue.once(token: "UIView.SkeletonView.swizzleTraitCollectionDidChange") {
//                swizzle(selector: #selector(UIView.traitCollectionDidChange(_:)),
//                        with: #selector(UIView.skeletonTraitCollectionDidChange(_:)),
//                        inClass: UIView.self,
//                        usingClass: UIView.self)
//            }
//        }
//    }
//}
//
//extension UIView {
//    func addSkeletonLayer(skeletonConfig config: SkeletonConfig) {
//        guard let skeletonLayer = SkeletonLayerBuilder()
//            .setSkeletonType(config.type)
//            .addColors(config.colors)
//            .setHolder(self)
//            .build()
//            else { return }
//
//        self.skeletonLayer = skeletonLayer
//        layer.insertSublayer(skeletonLayer,
//                             at: UInt32.max,
//                             transition: config.transition) { [weak self] in
//                                if config.animated {
//                                    self?.startSkeletonAnimation(config.animation)
//                                }
//        }
//        status = .on
//    }
//    
//    func updateSkeletonLayer(skeletonConfig config: SkeletonConfig) {
//        guard let skeletonLayer = skeletonLayer else { return }
//        skeletonLayer.update(usingColors: config.colors)
//        if config.animated {
//            startSkeletonAnimation(config.animation)
//        } else {
//            skeletonLayer.stopAnimation()
//        }
//    }
//
//    func layoutSkeletonLayerIfNeeded() {
//        guard let skeletonLayer = skeletonLayer else { return }
//        skeletonLayer.layoutIfNeeded()
//    }
//    
//    func removeSkeletonLayer() {
//        guard isSkeletonActive,
//            let skeletonLayer = skeletonLayer,
//            let transitionStyle = currentSkeletonConfig?.transition else { return }
//        skeletonLayer.stopAnimation()
//        skeletonLayer.removeLayer(transition: transitionStyle) {
//            self.skeletonLayer = nil
//            self.status = .off
//            self.currentSkeletonConfig = nil
//        }
//    }
//}
//import UIKit
//
//public typealias SkeletonLayerAnimation = (CALayer) -> CAAnimation
//
//public enum SkeletonType {
//    case solid
//    case gradient
//    
//    var layer: CALayer {
//        switch self {
//        case .solid:
//            return CALayer()
//        case .gradient:
//            return CAGradientLayer()
//        }
//    }
//    
//    var layerAnimation: SkeletonLayerAnimation {
//        switch self {
//        case .solid:
//            return { $0.pulse }
//        case .gradient:
//            return { $0.sliding }
//        }
//    }
//}
//
//struct SkeletonLayer {
//    private var maskLayer: CALayer
//    private weak var holder: UIView?
//    
//    var type: SkeletonType {
//        return maskLayer is CAGradientLayer ? .gradient : .solid
//    }
//    
//    var contentLayer: CALayer {
//        return maskLayer
//    }
//    
//    init(type: SkeletonType, colors: [UIColor], skeletonHolder holder: UIView) {
//        self.holder = holder
//        self.maskLayer = type.layer
//        self.maskLayer.anchorPoint = .zero
//        self.maskLayer.bounds = holder.maxBoundsEstimated
//        self.maskLayer.cornerRadius = CGFloat(holder.skeletonCornerRadius)
//        addTextLinesIfNeeded()
//        self.maskLayer.tint(withColors: colors)
//    }
//    
//    func update(usingColors colors: [UIColor]) {
//        layoutIfNeeded()
//        maskLayer.tint(withColors: colors)
//    }
//
//    func layoutIfNeeded() {
//        if let bounds = holder?.maxBoundsEstimated {
//            maskLayer.bounds = bounds
//        }
//        updateLinesIfNeeded()
//    }
//    
//    func removeLayer(transition: SkeletonTransitionStyle, completion: (() -> Void)? = nil) {
//        switch transition {
//        case .none:
//            maskLayer.removeFromSuperlayer()
//            completion?()
//        case .crossDissolve(let duration):
//            maskLayer.setOpacity(from: 1, to: 0, duration: duration) {
//                self.maskLayer.removeFromSuperlayer()
//                completion?()
//            }
//        }
//    }
//
//    /// If there is more than one line, or custom preferences have been set for a single line, draw custom layers
//    func addTextLinesIfNeeded() {
//        guard let textView = holderAsTextView else { return }
//        
//        let config = SkeletonMultilinesLayerConfig(lines: textView.numLines,
//                                                   lineHeight: textView.multilineTextFont?.lineHeight,
//                                                   type: type,
//                                                   lastLineFillPercent: textView.lastLineFillingPercent,
//                                                   multilineCornerRadius: textView.multilineCornerRadius,
//                                                   multilineSpacing: textView.multilineSpacing,
//                                                   paddingInsets: textView.paddingInsets)
//
//        maskLayer.addMultilinesLayers(for: config)
//    }
//    
//    func updateLinesIfNeeded() {
//        guard let textView = holderAsTextView else { return }
//        let config = SkeletonMultilinesLayerConfig(lines: textView.numLines,
//                                                   lineHeight: textView.multilineTextFont?.lineHeight,
//                                                   type: type,
//                                                   lastLineFillPercent: textView.lastLineFillingPercent,
//                                                   multilineCornerRadius: textView.multilineCornerRadius,
//                                                   multilineSpacing: textView.multilineSpacing,
//                                                   paddingInsets: textView.paddingInsets)
//        
//        maskLayer.updateMultilinesLayers(for: config)
//    }
//    
//    var holderAsTextView: ContainsMultilineText? {
//        guard let textView = holder as? ContainsMultilineText,
//            (textView.numLines == 0 || textView.numLines > 1 || textView.numLines == 1 && !SkeletonAppearance.default.renderSingleLineAsView) else {
//                return nil
//        }
//        return textView
//    }
//}
//
//extension SkeletonLayer {
//    func start(_ anim: SkeletonLayerAnimation? = nil, completion: (() -> Void)? = nil) {
//        let animation = anim ?? type.layerAnimation
//        contentLayer.playAnimation(animation, key: "skeletonAnimation", completion: completion)
//    }
//
//    func stopAnimation() {
//        contentLayer.stopAnimation(forKey: "skeletonAnimation")
//    }
//}
///// Used to store all config needed to activate the skeleton layer.
//struct SkeletonConfig {
//    /// Type of skeleton layer
//    let type: SkeletonType
//    
//    /// Colors used in skeleton layer
//    let colors: [UIColor]
//    
//    /// If type is gradient, which gradient direction
//    let gradientDirection: GradientDirection?
//    
//    /// Specify if skeleton is animated or not
//    let animated: Bool
//    
//    /// Used to execute a custom animation
//    let animation: SkeletonLayerAnimation?
//    
//    ///  Transition style
//    var transition: SkeletonTransitionStyle
//    
//    init(
//        type: SkeletonType,
//        colors: [UIColor],
//        gradientDirection: GradientDirection? = nil,
//        animated: Bool = false,
//        animation: SkeletonLayerAnimation? = nil,
//        transition: SkeletonTransitionStyle = .crossDissolve(0.25)
//        ) {
//        self.type = type
//        self.colors = colors
//        self.gradientDirection = gradientDirection
//        self.animated = animated
//        self.animation = animation
//        self.transition = transition
//    }
//}
//
//import UIKit
//
//public protocol Appearance {
//    var tintColor: UIColor { get set }
//    var gradient: SkeletonGradient { get set }
//    var multilineHeight: CGFloat { get set }
//    var multilineSpacing: CGFloat { get set }
//    var multilineLastLineFillPercent: Int { get set }
//    var multilineCornerRadius: Int { get set }
//    var renderSingleLineAsView: Bool { get set }
//}
//
//public enum SkeletonAppearance {
//    public static var `default`: Appearance = SkeletonViewAppearance.shared
//}
//
//// codebeat:disable[TOO_MANY_IVARS]
//class SkeletonViewAppearance: Appearance {
//    static var shared = SkeletonViewAppearance()
//
//    var tintColor: UIColor = .skeletonDefault
//
//    var gradient: SkeletonGradient = SkeletonGradient(baseColor: .skeletonDefault)
//
//    var multilineHeight: CGFloat = 15
//
//    var multilineSpacing: CGFloat = 10
//
//    var multilineLastLineFillPercent: Int = 70
//
//    var multilineCornerRadius: Int = 0
//    
//    var renderSingleLineAsView: Bool = false
//}
//// codebeat:enable[TOO_MANY_IVARS]
//
//extension UIView {
//    @objc var subviewsSkeletonables: [UIView] {
//        return subviewsToSkeleton.filter { $0.isSkeletonable }
//    }
//
//    @objc var subviewsToSkeleton: [UIView] {
//        return subviews
//    }
//}
//
//extension UITableView {
//    override var subviewsToSkeleton: [UIView] {
//        return visibleCells + visibleSectionHeaders + visibleSectionFooters
//    }
//}
//
//extension UITableViewCell {
//    override var subviewsToSkeleton: [UIView] {
//        return contentView.subviews
//    }
//}
//
//extension UITableViewHeaderFooterView {
//    override var subviewsToSkeleton: [UIView] {
//        return contentView.subviews
//    }
//}
//
//extension UICollectionView {
//    override var subviewsToSkeleton: [UIView] {
//        return subviews
//    }
//}
//
//extension UICollectionViewCell {
//    override var subviewsToSkeleton: [UIView] {
//        return contentView.subviews
//    }
//}
//
//extension UIStackView {
//    override var subviewsToSkeleton: [UIView] {
//        return arrangedSubviews
//    }
//}
//import UIKit
//
//typealias VoidBlock = () -> Void
//typealias RecursiveBlock<T> = (T) -> Void
//
//protocol IterableElement {}
//extension UIView: IterableElement {}
//extension CALayer: IterableElement {}
//
////MARK: Recursive
//protocol Recursive {
//    associatedtype Element: IterableElement
//    func recursiveSearch(leafBlock: VoidBlock, recursiveBlock: RecursiveBlock<Element>)
//}
//
//extension Array: Recursive where Element: IterableElement {
//    func recursiveSearch(leafBlock: VoidBlock, recursiveBlock: RecursiveBlock<Element>) {
//        guard count > 0 else {
//            leafBlock()
//            return
//        }
//        forEach { recursiveBlock($0) }
//    }
//}
//
//
//protocol SkeletonFlowDelegate {
//    func willBeginShowingSkeletons(rootView: UIView)
//    func didShowSkeletons(rootView: UIView)
//    func willBeginUpdatingSkeletons(rootView: UIView)
//    func didUpdateSkeletons(rootView: UIView)
//    func willBeginLayingSkeletonsIfNeeded(rootView: UIView)
//    func didLayoutSkeletonsIfNeeded(rootView: UIView)
//    func willBeginHidingSkeletons(rootView: UIView)
//    func didHideSkeletons(rootView: UIView)
//}
//
//class SkeletonFlowHandler: SkeletonFlowDelegate {
//    func willBeginShowingSkeletons(rootView: UIView) {
//        NotificationCenter.default.post(name: .willBeginShowingSkeletons, object: rootView, userInfo: nil)
//        rootView.addAppNotificationsObservers()
//    }
//
//    func didShowSkeletons(rootView: UIView) {
//        printSkeletonHierarchy(in: rootView)
//        NotificationCenter.default.post(name: .didShowSkeletons, object: rootView, userInfo: nil)
//    }
//
//    func willBeginUpdatingSkeletons(rootView: UIView) {
//        NotificationCenter.default.post(name: .willBeginUpdatingSkeletons, object: rootView, userInfo: nil)
//    }
//
//    func didUpdateSkeletons(rootView: UIView) {
//        NotificationCenter.default.post(name: .didUpdateSkeletons, object: rootView, userInfo: nil)
//    }
//
//    func willBeginLayingSkeletonsIfNeeded(rootView: UIView) {
//    }
//
//    func didLayoutSkeletonsIfNeeded(rootView: UIView) {
//    }
//
//    func willBeginHidingSkeletons(rootView: UIView) {
//        NotificationCenter.default.post(name: .willBeginHidingSkeletons, object: rootView, userInfo: nil)
//        rootView.removeAppNoticationsObserver()
//    }
//
//    func didHideSkeletons(rootView: UIView) {
//        rootView.flowDelegate = nil
//        NotificationCenter.default.post(name: .didHideSkeletons, object: rootView, userInfo: nil)
//    }
//}
//
//public extension Notification.Name {
//    static let willBeginShowingSkeletons = Notification.Name("willBeginShowingSkeletons")
//    static let didShowSkeletons = Notification.Name("didShowSkeletons")
//    static let willBeginUpdatingSkeletons = Notification.Name("willBeginUpdatingSkeletons")
//    static let didUpdateSkeletons = Notification.Name("didUpdateSkeletons")
//    static let willBeginHidingSkeletons = Notification.Name("willBeginHidingSkeletons")
//    static let didHideSkeletons = Notification.Name("didHideSkeletons")
//}
