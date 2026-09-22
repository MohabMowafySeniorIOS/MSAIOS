//
//  L10language.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import UIKit

// constants
let APPLE_LANGUAGE_KEY = "AppleLanguages"
/// L102Language
class L102Language {
    /// get current Apple language
    /// ⚠️ الدالة دي بقت بتتنادى من مسار الإشعارات كمان.
    ///
    /// كانت `as!` على `AppleLanguages` و`as!` على أول عنصر، و`offsetBy: 2`
    /// على نص ممكن يكون حرف واحد — تلات أماكن بتقفل التطبيق. ماكانتش
    /// بتضرب لأنها كانت بتتنادى من الواجهة بس بعد ما النظام يكون ظبط
    /// المفتاح؛ دلوقتي بتتنادى من كول-باك تسجيل توكن FCM في الخلفية،
    /// فالتشدّد مش رفاهية.
    ///
    /// الافتراضي عربي — نفس اللي `AppDelegate` بيعمله عند أول فتح.
    class func currentAppleLanguage() -> String {
        let userdef = UserDefaults.standard

        guard let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as? [Any],
              let current = langArray.first as? String,
              current.count >= 2
        else { return arabicLang }

        return String(current.prefix(2))
    }
    
    class func currentAppleLanguageFull() -> String {
        let userdef = UserDefaults.standard

        guard let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as? [Any],
              let current = langArray.first as? String
        else { return arabicLang }

        return current
    }
    
    /// set @lang to be the first in Applelanguages list
    class func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: APPLE_LANGUAGE_KEY)
        userdef.synchronize()
    }
    
    class var isRTL: Bool {
        
        
        return L102Language.currentAppleLanguage() == "ar"
    }
    
}
