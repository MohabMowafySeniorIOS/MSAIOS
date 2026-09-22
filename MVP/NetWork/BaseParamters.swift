//
//  أشسث[شقشوفثقس.swift
//  FinalSwiftUI
//
//  Created by Mohab Elsayed on 13/01/2025.
//



import Foundation
struct BaseParameters {
    
    //MARK: Auth Paramter
    var full_name:  String      = ""
    var email    : String       = ""
    var phone    : String       = ""
    var city_id  : String       = ""
    var auth     : String       = ""
    var code     : String       = ""
    var current_password        = ""
    var password : String       = ""
    var password_confirmation   = ""
    var method  : String       = ""
    var device_token            = ""
    var type     : String       = ""
    var agree_terms             = ""
    
    //MARK: Add Car
    var car_category_id : String = ""
    var car_brand_id    : String = ""
    var car_model_id    : String = ""
    var year            : String = ""
    var chassis_number  : String = ""
    var is_default      : String = ""
    
    //MARK: Add Addresses
    var title           : String = ""
    var latitude        : String = ""
    var longitude       :String  = ""
    var address_text    : String = ""
    var description     : String = ""
    var problem_type: String            = ""
    //MARK: AttachMents
    var media_type               = ""
    var id                       = ""
    var model                    = ""
    var model_id                 = ""
    var option                   = ""
    var is_single                = ""
    var model_type               = ""
   
    
    
    //MARK: Contact
    var message                  = ""
    var content                  = ""
    
    //MARK: WithDraw
    var amount                   = ""
    var bank_name                = ""
    var account_name             = ""
    var account_number           = ""
    var iban                     = ""
    
    //MARK: Complete Profile
    var trade_name_ar            = ""
    var trade_name_en            = ""
    var description_ar           = ""
    var description_en           = ""
    var country_id               = ""
    var address                  = ""
    var commercial_register      = ""
    var bank_account_name        = ""
    var bank_iban                = ""
    
    
    //MARK: Create Order
    var vehicle_id            = ""
    var order_type            = ""
    var delivery_type           = ""
    var address_id           = ""
    
    //MARK: Rate
    var rating                  = ""
    var comment                  = ""
    
    var status                  = ""
   
    //MARK: payment_method
    var payment_method = ""
    var brand          = ""
    
    var order_id       = ""
    var trader_id       = ""
}

extension BaseParameters {
    func toDictionary() -> [String: Any] {
        
        var parameters: [String: Any] = [:]
        
        
        //MARK: Auth Paramter
        if !full_name.isEmpty {
            parameters["full_name"] = full_name
        }
        
        
        if !email.isEmpty {
            parameters["email"] = email
        }
        
        if !phone.isEmpty {
            parameters["phone"] = phone
        }
        
        if !city_id.isEmpty {
            parameters["city_id"] = city_id
        }
        
        if !auth.isEmpty {
            parameters["auth"] = auth
        }
        
        if !code.isEmpty {
            parameters["code"] = code
        }
        
        if !password.isEmpty {
            parameters["password"] = password
        }
        
        if !device_token.isEmpty {
            parameters["device_token"] = device_token
        }
        
        if !type.isEmpty {
            parameters["type"] = type
        }
        
        if !password_confirmation.isEmpty {
            parameters["password_confirmation"] = password_confirmation
        }
        
        if !current_password.isEmpty {
            parameters["current_password"] = current_password
        }
        
        
        if !agree_terms.isEmpty {
            parameters["agree_terms"] = agree_terms
        }
        
        if !method.isEmpty {
            parameters["_method"] = method
        }
        
        
        if !phone.isEmpty {
            parameters["phone"] = phone
        }
     
        
        
        if !password.isEmpty {
            parameters["password"] = password
        }
        
       
      
        //MARK: Add Car
        
        if !car_category_id.isEmpty {
            parameters["car_category_id"] = car_category_id
        }
        
        if !car_brand_id.isEmpty {
            parameters["car_brand_id"] = car_brand_id
        }
        
        if !car_model_id.isEmpty {
            parameters["car_model_id"] = car_model_id
        }
        
        if !year.isEmpty {
            parameters["year"] = year
        }
        
        if !chassis_number.isEmpty {
            parameters["chassis_number"] = chassis_number
        }
        
        if !is_default.isEmpty {
            parameters["is_default"] = is_default
        }
      
        
        //MARK: Add Addresses
        
        if !title.isEmpty {
            parameters["title"] = title
        }
        
        if !latitude.isEmpty {
            parameters["latitude"] = latitude
        }
        
        if !longitude.isEmpty {
            parameters["longitude"] = longitude
        }
        
        if !address_text.isEmpty {
            parameters["address_text"] = address_text
        }
        
        if !description.isEmpty {
            parameters["description"] = description
        }
        
        
        //MARK: AttachMentsة
        
        if !media_type.isEmpty {
            parameters["media_type"] = media_type
        }
        
        if !id.isEmpty {
            parameters["id"] = id
        }
        if !model.isEmpty {
            parameters["model"] = model
        }
        
        if !model_id.isEmpty {
            parameters["model_id"] = model_id
        }
        
        if !option.isEmpty {
            parameters["option"] = option
        }
        
        if !is_single.isEmpty {
            parameters["is_single"] = is_single
        }
        
        if !model_type.isEmpty {
            parameters["model_type"] = model_type
        }
        
      
        
        //MARK: Contact
        if !message.isEmpty {
            parameters["message"] = message
        }
        
        if !content.isEmpty {
            parameters["content"] = content
        }
     
        
        //MARK: WithDraw
        if !amount.isEmpty {
            parameters["amount"] = amount
        }
        
        if !bank_name.isEmpty {
            parameters["bank_name"] = bank_name
        }
        
        if !account_name.isEmpty {
            parameters["account_name"] = account_name
        }
        
        if !account_number.isEmpty {
            parameters["account_number"] = account_number
        }
        
        if !iban.isEmpty {
            parameters["iban"] = iban
        }
        
        //MARK: Create Order
        if !vehicle_id.isEmpty {
            parameters["vehicle_id"] = vehicle_id
        }
        
        if !order_type.isEmpty {
            parameters["order_type"] = order_type
        }
        
        if !delivery_type.isEmpty {
            parameters["delivery_type"] = delivery_type
        }
        
        if !address_id.isEmpty {
            parameters["address_id"] = address_id
        }
        
        //MARK: Rate
        if !rating.isEmpty {
            parameters["rating"] = rating
        }
        
        if !comment.isEmpty {
            parameters["comment"] = comment
        }
      
        if !status.isEmpty {
            parameters["status"] = status
        }
        
        //MARK: payment_method
        if !payment_method.isEmpty {
            parameters["payment_method"] = payment_method
        }
        
        if !brand.isEmpty {
            parameters["brand"] = brand
        }
        
        if !problem_type.isEmpty {
            parameters["problem_type"] = problem_type
        }
        
        if !order_id.isEmpty {
            parameters["order_id"] = order_id
        }
        
        if !trader_id.isEmpty {
            parameters["trader_id"] = trader_id
        }
        
    
       
        return parameters
    }
}
