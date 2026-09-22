//
//  ViewsColor+Extentions.swift
//  Courses
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import Foundation
import UIKit

class addInterLineCenterSpacing : UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // MARK: - Check if there's any text
        guard let textString = text else { return }

        // MARK: - Create "NSMutableAttributedString" with your text
        let attributedString = NSMutableAttributedString(string: textString)

        // MARK: - Create instance of "NSMutableParagraphStyle"
        let paragraphStyle = NSMutableParagraphStyle()
        
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5

//        if L102Language.currentAppleLanguage() == arabicLang {
//            paragraphStyle.alignment = .right
//        }else {
//            paragraphStyle.alignment = .left
//        }
        
        // MARK: - Adding ParagraphStyle to your attributed String
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))

        // MARK: - Assign string that you've modified to current attributed Text
        attributedText = attributedString
        
        }
    
}


class addInterLineSpacing : UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // MARK: - Check if there's any text
        guard let textString = text else { return }

        // MARK: - Create "NSMutableAttributedString" with your text
        let attributedString = NSMutableAttributedString(string: textString)

        // MARK: - Create instance of "NSMutableParagraphStyle"
        let paragraphStyle = NSMutableParagraphStyle()
        
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5

        if L102Language.currentAppleLanguage() == arabicLang {
            paragraphStyle.alignment = .right
        }else {
            paragraphStyle.alignment = .left
        }
        
        // MARK: - Adding ParagraphStyle to your attributed String
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))

        // MARK: - Assign string that you've modified to current attributed Text
        attributedText = attributedString
        
        }
    
}

extension UILabel {
    // MARK: - spacingValue is spacing that you need
    func addInterlineSpacing(isCentered:Bool = true) {

        // MARK: - Check if there's any text
        guard let textString = text else { return }
        // MARK: - Create "NSMutableAttributedString" with your text
        let attributedString = NSMutableAttributedString(string: textString)

        // MARK: - Create instance of "NSMutableParagraphStyle"
        let paragraphStyle = NSMutableParagraphStyle()
     
        if isCentered == true {
            paragraphStyle.alignment = .center
        }
           
        // MARK: - Actually adding spacing we need to ParagraphStyle
        paragraphStyle.lineSpacing = 5
        
        // MARK: - Adding ParagraphStyle to your attributed String
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))

        // MARK: - Assign string that you've modified to current attributed Text
        attributedText = attributedString
        
    }
}





enum AppFont: String {
    case Regular = "Regular"
    //case extra_light = "ExtraLight"
    //case Light = "Light"
    case bold = "Bold"
    //case Thin = "Thin"
    case Medium = "Medium"
   // case SemiBold = "SemiBold"

    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
    fileprivate var fullFontName: String {
        
      //  print(rawValue.isEmpty ? FontfamilyName : FontfamilyName + "-" + rawValue)
        return rawValue.isEmpty ? FontfamilyName : FontfamilyName + "-" + rawValue
    }
}

/**
 خط العناوين من هوية العلامة — `Brand Assets/Fonts/lafet-*.otf`.
 فيه سكربت `arab` بمزايا init/medi/fina/rlig فبيوصّل الحروف العربية صح،
 بس تغطيته 74 حرف وهو خط عرض (display) — فبيتستخدم في العناوين الكبيرة بس.
 النصوص العادية بتفضل على IBM Plex Sans Arabic لأنه أقرأ في الأحجام الصغيرة.
 */
enum AppDisplayFont: String {
    case Regular = "Regular"
    case bold = "Bold"

    func size(_ size: CGFloat) -> UIFont {
        // لو الخط مش متسجّل لأي سبب، بنرجع لخط النص العادي بدل ما التطبيق يقفل
        UIFont(name: fullFontName, size: size)
            ?? AppFont(rawValue: rawValue)?.size(size)
            ?? .systemFont(ofSize: size)
    }

    fileprivate var fullFontName: String { DisplayFontFamilyName + "-" + rawValue }
}

enum AppSARFont: String {
    case Regular = "Regular"
    

    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
    fileprivate var fullFontName: String {
        
      //  print(rawValue.isEmpty ? FontfamilyName : FontfamilyName + "-" + rawValue)
        return "sarRegular"
    }
}


