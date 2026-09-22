//
//  SettingData.swift
//  MSA
//
//  Created by Mohab Mowafy on 10/05/2026.
//


import Foundation
struct Setting_Data : Codable {
    let app_name_ar : String?
    let app_name_en : String?
    let app_description_ar : String?
    let app_description_en : String?
    let dark_app_logo : String?
    let light_app_logo : String?
    let dash_main_light_logo : String?
    let dash_main_dark_logo : String?
    let dash_small_light_logo : String?
    let dash_small_dark_logo : String?
    let app_logo : String?
    let app_favicon : String?
    let client_logo : String?
    let driver_logo : String?
    let otp_provider : String?
    let otp_sms_gateway : String?
    let otp_whatsapp_gateway : String?
    let otp_expiration : Double?
    let otp_length : Double?
    let otp_default_code : Double?
    let otp_default_message_ar : String?
    let otp_default_message_en : String?
    let otp_use_default : Bool?
    let delivery_fee : Double?
    let unread_messages_count : Double?
    let unread_notifications_count : Double?
    let contact_whatsapp : String?

    enum CodingKeys: String, CodingKey {

        case app_name_ar = "app_name_ar"
        case app_name_en = "app_name_en"
        case app_description_ar = "app_description_ar"
        case app_description_en = "app_description_en"
        case dark_app_logo = "dark_app_logo"
        case light_app_logo = "light_app_logo"
        case dash_main_light_logo = "dash_main_light_logo"
        case dash_main_dark_logo = "dash_main_dark_logo"
        case dash_small_light_logo = "dash_small_light_logo"
        case dash_small_dark_logo = "dash_small_dark_logo"
        case app_logo = "app_logo"
        case app_favicon = "app_favicon"
        case client_logo = "client_logo"
        case driver_logo = "driver_logo"
        case otp_provider = "otp_provider"
        case otp_sms_gateway = "otp_sms_gateway"
        case otp_whatsapp_gateway = "otp_whatsapp_gateway"
        case otp_expiration = "otp_expiration"
        case otp_length = "otp_length"
        case otp_default_code = "otp_default_code"
        case otp_default_message_ar = "otp_default_message_ar"
        case otp_default_message_en = "otp_default_message_en"
        case otp_use_default = "otp_use_default"
        case delivery_fee = "delivery_fee"
        case unread_messages_count = "unread_messages_count"
        case unread_notifications_count = "unread_notifications_count"
        case contact_whatsapp = "contact_whatsapp"
    }

   

}
