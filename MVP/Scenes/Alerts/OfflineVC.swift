//
//  OfflineVC.swift
//  Teck-En
//
//  Created by mohab mowafy on 29/07/2022.
//

import UIKit
import Alamofire

class OfflineVC: UIViewController {
    var oldVC = UIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let net = NetworkReachabilityManager()
              net?.startListening()
        net?.listener =
            { status in

                if  net?.isReachable ?? false
                {
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                   
                }
            }

        // Do any additional setup after loading the view.
    }

    @IBAction func TryAction(_ sender: Any) {
        if ApiServices.GetInstance().checkConnection() {
            
            self.dismiss(animated: true, completion: nil)
            self.oldVC.viewDidLoad()
           self.oldVC.viewWillAppear(true)
//            self.oldVC.viewDidAppear(true)
            
        }else {
           // Globals().showError(title: Globals().GetStringForKey(key:"You seem to be offline.\nCheck your internet settings."))
        }
    }
    
   
}
