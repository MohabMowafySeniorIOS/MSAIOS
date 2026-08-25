//
//  NetWorkHelper.swift
//  FinalSwiftUI
//
//  Created by Mohab Elsayed on 12/01/2025.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case serverError(String)
    case decodingError
    case NotAuthorized
    case ParamterError
}

public enum HTTPMethodType: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
public enum EndPoints: String {
    
    //MARK: AUTH
    case register =  "client/auth/register"
    case Login = "client/auth/login"
    case verify_phone = "client/auth/verify"
    case resend_otp = "client/auth/send"
    case forgot_password = "client/password/forget"
    case password_verify = "client/password/verify"
    case reset_password = "client/password/reset"
    case update_password = "client/profile/update-password"
    case logout = "client/logout"
    
    //MARK: Profile
    case updatePhone = "client/profile/send/otp"
    case activeUpdatePhone = "client/profile/update/auth"
    
    //    MARK: Home
    case home = "client/home"
    case vendorsList = "client/traders"
    case favorites = "client/traders/favorites/list"
    case vendorDetails = "client/traders/"
    case orders = "client/orders"
    
    //MARK: Chats
    case chats = "client/chats"
    case unread_count = "client/chats/unread-count"
    
    //MARK: Payment
    case AvailablePaymentMethod = "client/payment-methods"
    case Wallet = "client/wallet"
    case WalletBalanace = "client/wallet/balance"
    case WalletTransAction = "client/wallet/transactions"
    case ChargeWallet = "client/wallet/charge"
    case WalletChanges = "client/wallet/charges"
    case WalletWithDraw = "client/wallet/withdraw"
    case WalletWithDrawRequest = "client/wallet/withdraw-requests"
    
    
    //MARK: Car Properties
    case categories = "client/cars/categories"
    case brands = "client/cars/brands"
    case Models = "client/cars/models"
    case years = "client/cars/years"
    //MARK: General
    
    //MARK: UserProfile
    case profile = "client/profile"
    case account_request_deletion = "client/profile/delete/account"
    
    //MARK: SidMenue Views
    
    //MARK: Addresses
    case client_addresses = "client/addresses"
    //MARK: Cars
    case profile_cars = "client/vehicles"
    
    
    //MARK: Vendor
    
    case completeProfile = "trader/profile/complete"
    
    
    case ratings = "client/ratings/trader"
    
    
    
    //MARK: AttachMents
    case storeAttachMents = "general/attachment"
    case getAttachMents = "general/attachment/models/list"
    case deleteAttachMent = "general/attachment/delete"
    
    //MARK: General
    case countries = "general/countries"
    case cities = "general/cities"
    case settings = "general/settings"
    
    //MARK: Pages
    case pages = "general/pages/pages"
    case faq = "general/pages/faqs"
    case showPage = "general/pages/page"
    case contact_us = "general/pages/contact"
    
   
    
    
    // MARK: Notifications
    case notifications = "general/notifications"
    
    
    
   
    
    
    
    
   
    
    
    
    
    //MARK: General Categories
    case general_categories = "general-categories"
    
    
    //MARK: Settings&Contents
    case settings_public = "settings"
    
  
    
    
    
}
