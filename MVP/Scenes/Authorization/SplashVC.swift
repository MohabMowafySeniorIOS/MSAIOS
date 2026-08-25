//
//  SlashVC.swift
//  zoud
//
//  Created by Mohab on 8/20/21.
//

import UIKit
import AVFoundation
import FirebaseFirestore

class BGView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let lightLayer = CAGradientLayer()
    private let textureView = UIImageView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupBaseGradient()
        setupLightEffect()
        setupTexture()
    }
    
    // MARK: - Base Gradient
    private func setupBaseGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1).cgColor,
            UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1).cgColor,
            UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Light Effect
    private func setupLightEffect() {
        lightLayer.colors = [
            UIColor(red: 0.83, green: 0.69, blue: 0.22, alpha: 0.4).cgColor,
            UIColor.clear.cgColor
        ]
        
        lightLayer.startPoint = CGPoint(x: 0, y: 0)
        lightLayer.endPoint = CGPoint(x: 0.7, y: 0.7)
        
        layer.insertSublayer(lightLayer, above: gradientLayer)
    }
    
    // MARK: - Texture
    private func setupTexture() {
        textureView.image = UIImage(named: "BGImage")
        textureView.contentMode = .scaleAspectFill
        textureView.alpha = 0.15
        
        addSubview(textureView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        lightLayer.frame = bounds
        textureView.frame = bounds
    }
}

class SplashVC: UIViewController {
   
    var Slider_array = [Sliders]()
  
    @IBOutlet weak var Logo: UIImageView!
    
    //    @IBOutlet weak var Logo3: UIImageView!
    //    @IBOutlet weak var Logo2: UIImageView!
    //    @IBOutlet weak var Log4: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Helper.restartApp()
    }
    
}
extension SplashVC {
    
    func listenOnBoarding() {
        self.lock()
        let db = Firestore.firestore()
        
        db.collection("on_boarding").addSnapshotListener {[weak self] snapshot, error in
            self?.unlock()
            guard let self = self else { return }
            guard let documents = snapshot?.documents else { return }
            
            self.Slider_array.removeAll()
            for pages in documents {
                var page = pages.documentID as? String
                let data = pages.data()
                let title = L102Language.currentAppleLanguage() == "ar" ? data["title_ar"] as? String : data["title_en"] as? String
                let describtion = L102Language.currentAppleLanguage() == "ar" ? data["describtion_ar"] as? String : data["describtion_en"] as? String
                let image = data["image"] as? String
                self.Slider_array.append(Sliders(title: title, des: describtion, image: image))
                
            }
            self.handleOnBoardingData()
            
            
        }
    }
    
    func getAppVersion() {
       
        let db = Firestore.firestore()
        
        db.collection("appVersion").addSnapshotListener {[weak self] snapshot, error in
           
            guard let self = self else { return }
            guard let documents = snapshot?.documents else { return }
            
            for pages in documents {
                var page = pages.documentID as? String
                let data = pages.data()
                let version = data["version"] as? String
                print(version,(Double(appVersion) ?? 0.0))
                
                if (Double(version ?? "0.0") ?? 0.0) > (Double(appVersion) ?? 0.0) {
                    let storyboard = UIStoryboard(name: PopUpsStry, bundle: nil)
                    let vc  = storyboard.instantiateViewController(withIdentifier: "UpdateAppVC") as! UpdateAppVC
                    vc.appStatus = .updated
                    vc.modalPresentationStyle = .fullScreen
                    self.addChild(vc)
                    vc.view.frame = self.view.frame
                    self.view.addSubview(vc.view)
                    vc.didMove(toParent: self)
                }else {
                    self.handleData()
                }
                
            }
        }
    }
    
    
    func handleData(){
        self.Logo.isHidden = false
        self.Logo.animate(animations: [AnimationType.from(direction: .left, offset: 500)], reversed: false, initialAlpha: 0.2, finalAlpha: 1.0, delay: 0.0, duration: 2.0) {
          
            self.Logo.isHidden = false
            if L102Language.currentAppleLanguage() == "en" {
                    self.handlenavigation()
                
            }else {
                    self.handlenavigation()
            }
        }
    }
    
    func handleOnBoardingData(){
        guard let window = UIApplication.shared.keyWindow else{return}
        let sb = UIStoryboard(name: Authontication, bundle: nil)
        var vc : OnBoardingVC
        vc = sb.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
        vc.Slider_array = self.Slider_array
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.5, options: .showHideTransitionViews, animations: nil, completion: nil)
    }
    
    func handleEnglishData(){
        Helper.restartToLanguage()
    }
    
    func handlenavigation(){
//        if Helper.getisStart_Language() != "true" {
//            handleEnglishData()
//        }else {
//            if Helper.getisFirst() != true {
//                handleOnBoardingData()
//            }else {
                Helper.restartApp()
//            }
//        }
        
    }
}
extension UIImageView {
    static func fromGif(frame: CGRect, resourceName: String) -> UIImageView? {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
              let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let gifImageView = UIImageView(frame: frame)
        gifImageView.animationImages = images
        return gifImageView
    }
}

extension SplashVC {
    private struct AssociatedKeys {
        static var AudioPlayerTag = "AudioPlayerTag"
    }
    func playSound(_ file:String) {
        
        var player: AVAudioPlayer? {
            get {
                return objc_getAssociatedObject(self, &AssociatedKeys.AudioPlayerTag) as? AVAudioPlayer
            }
            
            set {
                if let newValue = newValue {
                    objc_setAssociatedObject(
                        self,
                        &AssociatedKeys.AudioPlayerTag,
                        newValue as AVAudioPlayer?,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


