//
//  NoInterNetView.swift
//  iFresh
//
//  Created by Mohab Mowafy on 10/02/1441 AH.
//  Copyright © 1441 BoOodY. All rights reserved.
//

import UIKit

protocol NoInternetDelegate {
    func reloadData()
}

class NoInterNetView: UIView {
    @IBOutlet weak var laTitle: UILabel!
    @IBOutlet weak var laDesc: UILabel!
    @IBOutlet weak var button: MainButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorImage: UIImageView!
    
    var delegate: NoInternetDelegate?
    var errorType: ErrorViewType = .noInternet
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commenInitialization()
    }
    
    init(frame: CGRect, error:ErrorViewType) {
        super.init(frame: frame)
        self.errorType = error
        commenInitialization()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commenInitialization()
    }

    func commenInitialization() {
        Bundle.main.loadNibNamed("NoInterNet", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        displayScreenData()
        
    }
    
    func displayScreenData() {
        if errorType.haveBtn  {
            button.isHidden = false
        }else{
            button.isHidden = true
        }
        laTitle.attributedText = errorType.title.highlightKeyword()
        laDesc.attributedText = errorType.desc.highlightKeyword()
    }
    
    @IBAction func tryAgain(_: UIButton) {
        delegate?.reloadData()
    }
}
