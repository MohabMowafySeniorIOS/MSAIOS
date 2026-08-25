//
//  uiView+Extention.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Kingfisher


typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

var remove_filter_view :(()->())?

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
        case .horizontal:
            return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
        }
    }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}




class Plure_View : UIView {
    
}

extension UIView {
    
    //var Filter_tapped :(()->())?
    
    func applyBlurEffect(FrontView:UIView , is_remove_blure : Bool ) {
        DispatchQueue.main.async {
            let blurEffect = Plure_View()
            blurEffect.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            blurEffect.frame = self.bounds
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.FilterViewTapped(tapGestureRecognizer:)))
            blurEffect.isUserInteractionEnabled = true
            blurEffect.addGestureRecognizer(tapGestureRecognizer)
            
            if is_remove_blure {
                self.addSubview(FrontView)
                for view in self.subviews {
                    if let Plure_View = view as? Plure_View {
                        view.removeFromSuperview()
                    }
                }
                
                
            }else {
                self.addSubview(blurEffect)
                blurEffect.addSubview(FrontView)
            }
        }
       
        
       
    }
    @objc func FilterViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
     
        remove_filter_view?()
   
    }
    
    
}



enum Keboard_type {
    case Deafult
    case PhoneNumber
    case Decimal
    case Email
    case NumberPad
    
}

extension CustomButtonView {
    @IBInspectable var TitleLabelKey: String? {
        get { return nil }
        set(key) {
            ConfirmBtn.setTitle(key?.localized.capitalized, for: .normal)
        }
    }
    
    @IBInspectable var imageTitleKey: UIImage? {
        get { return nil }
        set(key) {
            
            ConfirmBtn.setImage(key?.withRenderingMode(.alwaysOriginal),for: .normal)
        }
    }
   
}



extension UIButton {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized.capitalized, for: .normal)
        }
    }
}

extension UITextField {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized.capitalized
        }
    }
}

extension UILabel {
    func colorString(text: String?, coloredText: String?, color: UIColor? = UIColor.RedColor) {
        
        let attributedString = NSMutableAttributedString(string: text!)
        let range = (text! as NSString).range(of: coloredText!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                       range: range)
        self.attributedText = attributedString
    }
}

extension UITextField {
    func colorString(text: String?, coloredText: String?, color: UIColor? = UIColor.RedColor) {
        
        let attributedString = NSMutableAttributedString(string: text!)
        let range = (text! as NSString).range(of: coloredText!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                       range: range)
        self.attributedText = attributedString
    }
}


extension UIView {
    

        func addShadowImage(parentview:UIView){
            
            //  ADD Shadow right &Bottom & left
            parentview.layer.shadowColor = UIColor.lightGray.cgColor
            parentview.layer.masksToBounds = false
            parentview.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            parentview.layer.shadowOpacity = 0.5
            parentview.layer.shadowRadius = 3.0
            

            
        }
    
    
    func anchor(top :NSLayoutYAxisAnchor? , left : NSLayoutXAxisAnchor? , right : NSLayoutXAxisAnchor? , bottom : NSLayoutYAxisAnchor? , paddingtop : CGFloat , paddingleft : CGFloat , paddingright : CGFloat , paddingbottom : CGFloat , width : CGFloat , height : CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingtop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingleft).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingright).isActive = true
        }
        
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingbottom).isActive = true
        }
        
        if width != 0 {
            
            widthAnchor.constraint(equalToConstant: width).isActive = true
            
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
  
        
        func setGradientLeftToRight(ColorLeft:CGColor,ColorRight:CGColor) {
            
            let gradientLayer = CAGradientLayer()
            // gradientLayer.frame = navigationBar.bounds
            gradientLayer.colors = [ColorLeft, ColorRight]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.frame = self.bounds
            self.layer.insertSublayer(gradientLayer, at:0)
            
            
        }
  
    @IBInspectable var shadowOffset: CGSize{
        get{
            return self.layer.shadowOffset
        }
        set{
            self.layer.shadowOffset = newValue
        }
    }
    func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    @IBInspectable var shadowColor: UIColor{
        get{
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set{
            self.layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        get{
            return self.layer.shadowRadius
        }
        set{
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        get{
            return self.layer.shadowOpacity
        }
        set{
            self.layer.shadowOpacity = newValue
        }
    }
    
    func removeNoDataLabel(tag: Int = 10000){
        if let noDataLabel = self.viewWithTag(tag) {
            UIView.animate(withDuration: 0.2, animations: {
                noDataLabel.alpha = 0.0
            }) { finished in
                noDataLabel.removeFromSuperview()
            }
        }
    }
    func setNoDataLabel(text: String? = "There Are No Results Available".localized, frameRect: CGRect = CGRect.zero, withBackgroundColor backgroundColor: UIColor =  UIColor(white: 0.0, alpha: 0.2), textColor: UIColor = UIColor.black ){
        let containerView = UIView()
        let label = UILabel()
        
        let label2 = UILabel()
        
        let imageQuestion = UIImageView()
       
        
    //  imageQuestion.image = #imageLiteral(resourceName: "error-black-18dp")
        
        imageQuestion.frame.size.width = 128
        imageQuestion.frame.size.height = 128
        
        if frameRect == CGRect.zero{
            containerView.frame = bounds
        }
        else{
            containerView.frame = frameRect
        }
        containerView.tag = 10000
        containerView.backgroundColor = self.backgroundColor
       
        label.frame = containerView.bounds
        label.frame.size.width =  containerView.frame.size.width
        label.numberOfLines = 0
        label.backgroundColor = self.backgroundColor
        label.textAlignment = .center
        label.textColor = UIColor.MainColor
        label.text = text
        label.font = AppFont.bold.size(16)
        label.font.withSize(22)
        
//        label2.frame = containerView.bounds
//        label2.frame.size.width =  containerView.frame.size.width
//        label2.numberOfLines = 0
//        label2.backgroundColor = self.backgroundColor
//        label2.textAlignment = .center
//        label2.textColor = UIColor.MainColor
//        label2.font = AppFont.Regular.size(12)
//        label2.text = "Sorry, there is no content available to display".localized
//        label2.font.withSize(50)
        
        if L102Language.currentAppleLanguage() == arabicLang {
            UILabel.appearance().semanticContentAttribute = .forceRightToLeft
        }else {
            UILabel.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
       
        
      imageQuestion.image = #imageLiteral(resourceName: "error-black-18dp")
        imageQuestion.frame = containerView.bounds
        
        
        containerView.addSubview(imageQuestion)
        containerView.addSubview(label)
        containerView.addSubview(label2)
        
        addSubview(containerView)
        
        imageQuestion.anchor(top: containerView.centerYAnchor , left: containerView.centerXAnchor, right: nil, bottom: nil, paddingtop: -60 , paddingleft: -64, paddingright: 0, paddingbottom: 0, width: 128, height: 128)
        label.anchor(top: imageQuestion.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, bottom: nil, paddingtop: 0, paddingleft: 0, paddingright: 0, paddingbottom: 0, width: 0, height: 30)
      //  label2.anchor(top: label.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, bottom: nil, paddingtop: 0, paddingleft: 0, paddingright: 0, paddingbottom: 0, width: 0, height: 30)
            
            imageQuestion.backgroundColor = #colorLiteral(red: 0.07960281521, green: 0.1419835687, blue: 0.3420339823, alpha: 0)
    }

  
    
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}
@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
extension UIImageView{
    func loadImage(_ urlss : String) {
    
        
        let url = URL(string: urlss)
        
        self.kf.setImage(
            with: url,
            placeholder: #imageLiteral(resourceName: "Rectangle 18383") ,
            options: [
                
//                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        self.kf.indicatorType = .activity
        
        
    }
    
    func loadProfileImage(_ urlss : String) {
        
        let url = URL(string: urlss)
        
        self.kf.setImage(
            with: url,
            placeholder: #imageLiteral(resourceName: "sliderPlaceHolder") ,
            options: [
                
//                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        self.kf.indicatorType = .activity
        
        
    }
}


extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
extension UIButton {
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        //NSAttributedStringKey.foregroundColor : UIColor.blue
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}



extension UILabel {
    func underlineMyText() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}


extension CustomTextView {
    
  
    
    @IBInspectable var TitleLabelKey: String? {
        get { return nil }
        set(key) {
            titleLabel.text = key?.localized.capitalized
            
//            if (key?.count ?? 0) > 0 {
//                self.titleLabel.isHidden = false
//            }else {
//                self.titleLabel.isHidden = true
//            }
        }
    }
    
    
    @IBInspectable var placeHolderKey: String? {
        get { return nil }
        set(key) {
            textViewPlaceHolder = key?.localized.capitalized ?? ""
           
            MessageTV.text = textViewPlaceHolder
            MessageTV.textColor = UIColor.lightGray
            
            
        }
    }
    
    @IBInspectable var ErrorMessageKey: String? {
        get { return (titleLabel.text ?? "").localized + " " + "Is Required".localized }
        set(key) {
            ValidationLabel.text = (titleLabel.text ?? "").localized.capitalized + " " +  "Is Required".localized
        }
    }
    

}

extension CustomTextFieldMobile {
    @IBInspectable var TitleLabelKey: String? {
        get { return nil }
        set(key) {
            titleLabel.text = key?.localized
            
            if (key?.count ?? 0) > 0 {
                self.titleLabel.isHidden = false
            }else {
                self.titleLabel.isHidden = true
            }
        }
    }
    
    
    @IBInspectable var placeHolderKey: String? {
        get { return nil }
        set(key) {
            NameTF.placeholder = "Enter".localized.capitalized + " " +  (titleLabel.text?.localized ?? "")
        }
    }
    
    @IBInspectable var ErrorMessageKey: String? {
        get { return (titleLabel.text ?? "").localized.capitalized + " " + "Is Required".localized }
        set(key) {
            ValidationLabel.text = (titleLabel.text ?? "").localized.capitalized + " " +  "Is Required".localized.capitalized
        }
    }
    

   
}
