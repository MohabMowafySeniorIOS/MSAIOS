//
//  OpenViewVC.swift
//  SIN
//
//  Created by Mohab Mowafy on 25/03/2024.
//

import Foundation
import UIKit
import WebKit

import UIKit
import WebKit

class OpenViewVC: UIViewController {
    
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var is_dismiss = false
    
    @IBOutlet weak var back: UIButton!
    //    var selectedVideo : PreviousAucationdata?

    var videoUrl:String?
    var titleOfVideo: String?

    override func viewDidLoad() {
        super.viewDidLoad()

       

        print(videoUrl)

        let detailsUrl = URL(string:videoUrl ?? "")
        let request:URLRequest = URLRequest(url: detailsUrl!)

        self.webView.load(request)

     //   self.videoTitle.attributedText = titleOfVideo
      
        
    }
    
   
    @IBAction func back(_ sender: Any) {
        if is_dismiss {
            dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
   //   dismiss(animated: true, completion: nil)
    
    }
    
}
