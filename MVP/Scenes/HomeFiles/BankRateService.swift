//
//  BankRateService.swift
//  MSA
//
//  Created by Mohab Mowafy on 10/05/2026.
//

import Foundation
import Foundation
import UIKit




import Foundation
import UIKit

typealias BankRateModel = BankRate

class BankRateService {
    
    private init () { }
    
    private let BankRateKey = "_Bank_|_Rate_"
    
    private static let userDefault = UserDefaults.standard
    
    fileprivate func getUserData() -> [BankRateModel]? {
        let defaults = UserDefaults.standard
        guard let savedPerson = defaults.object(forKey: BankRateKey) as? Data,
              let loadedData = try? JSONDecoder().decode([BankRateModel].self, from: savedPerson)
        else { return nil }
        return loadedData
    }
    
    fileprivate func setUserData(_ newValue: [BankRateModel]?) {
        // guard let newValue = newValue else { return }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newValue) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: BankRateKey)
        } else {
            fatalError("Unable To Save User Data")
        }
    }
    
    static var userData: [BankRate]? {
        get {
            let authService = BankRateService()
            return authService.getUserData()
        } set {
            let authService = BankRateService()
            authService.setUserData(newValue)
        }
    }
    
    
}



typealias OunceModel = OuncePrice

class OunceService {
    
    private init () { }
    
    private let OunceRateKey = "_Ounce_|_Rate_"
    
    private static let userDefault = UserDefaults.standard
    
    fileprivate func getOunceData() -> OuncePrice? {
        let defaults = UserDefaults.standard
        guard let savedPerson = defaults.object(forKey: OunceRateKey) as? Data,
              let loadedData = try? JSONDecoder().decode(OunceModel.self, from: savedPerson)
        else { return nil }
        return loadedData
    }
    
    fileprivate func setOunceData(_ newValue: OunceModel?) {
        // guard let newValue = newValue else { return }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newValue) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: OunceRateKey)
        } else {
            fatalError("Unable To Save User Data")
        }
    }
    
    static var userData: OunceModel? {
        get {
            let authService = OunceService()
            return authService.getOunceData()
        } set {
            let authService = OunceService()
            authService.setOunceData(newValue)
        }
    }
    
    
}



class MetalService {
    
    private init () { }
    
    private let MetalRateKey = "_Metal_|_Rate_"
    
    private static let userDefault = UserDefaults.standard
    
    fileprivate func getOunceData() -> [MetalModel]? {
        let defaults = UserDefaults.standard
        guard let savedPerson = defaults.object(forKey: MetalRateKey) as? Data,
              let loadedData = try? JSONDecoder().decode([MetalModel].self, from: savedPerson)
        else { return nil }
        return loadedData
    }
    
    fileprivate func setOunceData(_ newValue: [MetalModel]?) {
        // guard let newValue = newValue else { return }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newValue) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: MetalRateKey)
        } else {
            fatalError("Unable To Save User Data")
        }
    }
    
    static var userData: [MetalModel]? {
        get {
            let authService = MetalService()
            return authService.getOunceData()
        } set {
            let authService = MetalService()
            authService.setOunceData(newValue)
        }
    }
    
    
}



