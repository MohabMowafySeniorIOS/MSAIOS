//
//  DeviceTokenSync.swift
//  MSA
//
//  مزامنة توكن الجهاز واللغة مع السيرفر.
//
//  ## ليه ده موجود
//
//  التوكن كان بيتبعت مع التسجيل والدخول بس. بس FCM بيجدّد التوكن لوحده
//  (تحديث التطبيق · استعادة نسخة احتياطية · إعادة تنصيب)، والمستخدم
//  ممكن يفضل شهور من غير ما يعمل دخول تاني — فالتوكن اللي عند السيرفر
//  بيبوظ والإشعار الموجّه بيروح في الهوا.
//
//  ونفس الكلام على اللغة: كانت بتتبعت مرة واحدة وقت التسجيل، فلو
//  المستخدم غيّر لغة التطبيق بعدين كنا بنفضل نبعتله باللغة القديمة.
//
//  بينده من تلات أماكن:
//  - `AppDelegate.messaging(_:didReceiveRegistrationToken:)` — تجديد التوكن
//  - `AuthViewModel` بعد الدخول وتأكيد الكود — التوكن بيرجع من هناك بس
//  - `AppDelegate.changeLanguage` — تغيير لغة التطبيق
//

import Foundation
import FirebaseMessaging

enum DeviceTokenSync {

    /// بيبعت توكن FCM الحالي واللغة للسيرفر.
    ///
    /// بيرجع من غير ما يعمل حاجة لو المستخدم مش مسجّل دخول أو لسه
    /// مفيش توكن FCM. وبيبلع أي فشل شبكة: النداء ده بيحصل في خلفية
    /// حاجات تانية وما ينفعش يوقّف أي واحدة منهم.
    static func sync() {
        Task { @MainActor in
            /*
             * قراءة الجلسة على الـmain thread.
             *
             * الدالة دي بتتنادى من كول-باك FCM في الخلفية، ولو ده كان
             * أول لمس لـ`AuthSession.shared` فالـ`init` بتاعها بتكتب
             * خصائص `@Published` — وده برّه الـmain thread سلوك غير
             * معرّف في SwiftUI.
             *
             * والمسار نفسه محمي بتوكن دخول: من غير دخول الطلب هيرجع
             * 401 وخلاص. الزائر مش بيضيع عليه حاجة — الإعلانات العامة
             * بتوصله على التوبيك، واللي محتاج توكن هو الإشعار الموجّه
             * لحسابه.
             */
            guard let authToken = AuthSession.shared.token else { return }

            guard let fcmToken = try? await Messaging.messaging().token(),
                  !fcmToken.isEmpty else { return }

            await AuthAPI.updateDeviceToken(
                fcmToken: fcmToken,
                locale: L102Language.currentAppleLanguage(),
                token: authToken
            )
        }
    }
}
