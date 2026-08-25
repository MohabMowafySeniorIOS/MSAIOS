//
//  UpdateAppVC.swift
//  Shine
//
//  Created by Mohab Elsayed on 18/02/2025.
//

import Foundation
import UIKit

let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
enum App_updated_enum: String {
    case under_maintainance
    case updated
}
class UpdateAppVC: BaseControllerVC {
    var appStatus : App_updated_enum?
    
    var titleFromApi = ""
    var desFromApi = ""
    var BtnTitle = ""
    var imagefromApi = ""
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if appStatus == .updated {
            titleLabel.text = "تحديث جديد للتطبيق"
            desLabel.text = "لازم تحدّث التطبيق من متجر عشان تكمل استخدامه."
            updateBtn.setTitle("تحديث", for: .normal)
        }else if appStatus == .under_maintainance {
            titleLabel.text = "في شغل صيانة دلوقتي"
            desLabel.text = "في مشكلة بسيطة وإحنا بنحلها دلوقتي، التطبيق هيرجع يشتغل تاني قريب.معلش على الإزعاج 🙏"
            updateBtn.setTitle("غلق", for: .normal)

        }
//        titleLabel.text = titleFromApi
//        desLabel.text = desFromApi
//        updateBtn.setTitle(BtnTitle, for: .normal)
//        img.loadImage(imagefromApi)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    @IBAction func UpdateAction(_ sender: Any) {
        if appStatus == .updated {
            if let url = URL(string: "https://apps.apple.com/app/\(AppleId)"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
        }else if appStatus == .under_maintainance {
            exit(0)

        }
       
    }
    
}
import UIKit

class UpdateChecker {
    static let shared = UpdateChecker()
  
    
    func checkForUpdate(completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(AppleId)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    
                 
                    
                    if self.isUpdateAvailable(currentVersion: currentVersion, appStoreVersion: appStoreVersion) {
                        completion(true, appStoreVersion)
                    } else {
                        completion(false, nil)
                    }
                }
            } catch {
                completion(false, nil)
            }
        }
        task.resume()
    }
    
    private func isUpdateAvailable(currentVersion: String, appStoreVersion: String) -> Bool {
        print(currentVersion , appStoreVersion)
        return currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending
    }
}


