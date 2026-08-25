//
//  Segue.swift
//  MVP
//
//  Created by Mohab on 7/18/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    
    func goVC(_ vc : String , _ StryName : String)  {
        let storyboard = UIStoryboard(name: StryName, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: vc)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
   
    
    func PopUpSegue(){
        let storyboard = UIStoryboard(name: "mycourses", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "RateVC") 
        
        vc.modalPresentationStyle = .fullScreen
        self.addChild(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func BottomPobUp(){
        
//        let Storyboard = UIStoryboard(name: PopUpsStry, bundle: nil)
//        guard let popupVC = Storyboard.instantiateViewController(withIdentifier: "SortedOrder") as? SortedOrder else { return }
//     
//        popupVC.Delegate = self
//        popupVC.height = 50
//        popupVC.topCornerRadius = 8
//        popupVC.presentDuration = 0.7
//        popupVC.dismissDuration = 0.7
//      
//        self.present(popupVC, animated: true, completion: nil)
    }
    
    func dismiss()  {
        navigationController?.popViewController(animated: true)
        //  dismiss(animated: true, completion: nil)
    }
    
    func showAnimate()
             {
                 self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                 self.view.alpha = 0.0;
                 UIView.animate(withDuration: 0.25, animations: {
                     self.view.alpha = 1.0
                     self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

                 });
             }

             func removeAnimate()
             {
                 UIView.animate(withDuration: 0.25, animations: {
                     self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                     self.view.alpha = 0.0;

                 }, completion:{(finished : Bool)  in
                     if (finished)
                     {
                         self.view.removeFromSuperview()
                     }
                 });
             }
    
  
    
  

      
}
