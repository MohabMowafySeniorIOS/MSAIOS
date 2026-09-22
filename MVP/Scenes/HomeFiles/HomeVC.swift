//
//  HomeVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 07/05/2026.
//


import UIKit
import SocketIO
import ImageSlideshow
import SwiftUI
import FirebaseFirestore

struct MetalModel: Codable {
    var type: String?
    var name: String?
    var buyPrice: String?
    var salePrice: String?
    var updatedAt: Timestamp?
}

struct metalPrice {
    var goldPrice: metalPriceType?
    var silverPrice: metalPriceType?
}

struct metalPriceType {
    var buyPrice: String = ""
    var salePrice: String = ""
}

var metalPriceValue: metalPrice = .init(goldPrice: metalPriceType(buyPrice: "",salePrice: ""), silverPrice: metalPriceType(buyPrice: "",salePrice: ""))

enum MetalEnum {
    case Gold
    case Silver
}

var Setting_Model : Setting_Data?

struct OuncePrice: Codable {
    var goldPrice: Double = 0.0
    var silverPrice: Double = 0.0
}

class HomeVC: BaseControllerVC {
    var metalsArr: [MetalModel] = []
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tableView: UITableView!
 
    var timerCount: Double = 10
    var ounce = OuncePrice()
    @IBOutlet weak var lastUpdateLabel: UILabel!
    let pageIndicator = UIPageControl()
   
    var SliderArray = [Sliders]()
    var ImageArrrayLinks = [String]()
    
    var metalType: MetalEnum = .Gold
    
    @IBOutlet weak var GoldView: UIView!
    @IBOutlet weak var silverView: UIView!
//    @IBOutlet weak var SilverCheckImg: UIImageView!
//    @IBOutlet weak var GoldCheckImg: UIImageView!
    
    var timer: Timer?
    
    var dollarPrice = ""

    /// بانرات الشريط اللي تحت صف الفجوة السعرية.
    ///
    /// فاضية لحد ما الطلب يرجع، وفاضية كمان لو الطلب فشل أو مفيش بانر
    /// نشط في المكان ده — وساعتها الصف مبيتضافش أصلاً.
    /// التفاصيل في `HomeVC+InlineBanner.swift`.
    var inlineBanners: [Banner] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        getAppVersion()

        // Home-only maintenance switch (`ioshomeMaintain` in the appVersion doc).
        // Independent of `iosneedMaintain` above, which still blocks the whole
        // app. This one only covers the Home content — the tab bar stays live so
        // the user can go to prices, news, etc.
        bindScreenMaintenance(.home)
        
        setupBannerSlider()

        
        headerView.pressShare = { [weak self] in
            guard let self else { return }
            self.shareApp()
        }
//        self.metalsArr = MetalService.userData ?? []
//        self.ounce.goldPrice = OunceService.userData?.goldPrice ?? 0.0
//        self.ounce.silverPrice = OunceService.userData?.silverPrice ?? 0.0
       
        var price =  BankRateService.userData?.map({
           if $0.name.contains("المركزى") == true {
               self.dollarPrice = $0.sell
            }
            
        })
    
        
       
        listenToMetals()
        tableView.RegisterNib(cell: HomeDollarCell.self)
        tableView.RegisterNib(cell: GoldCell.self)
        tableView.RegisterNib(cell: OunceDollarCell.self)

        // الشريط الإعلاني التاني — خلية بالكود مش nib
        tableView.register(HomeInlineBannerCell.self,
                           forCellReuseIdentifier: HomeInlineBannerCell.identifier)

        /*
         لما المحتوى يرضى في الشاشة، الجدول ما يرتجّش.

         `alwaysBounceVertical` كانت `YES` في الـ storyboard، يعني
         الرئيسية كانت بتتحرك تحت الإصبع حتى لما يكون مفيش حاجة
         تتسكرول — وده بيحسّ إن فيه محتوى مخفي تحت. لما المحتوى يطول
         عن الشاشة، السكرول بيشتغل عادي زي ما هو.
         */
        tableView.alwaysBounceVertical = false

        tableView.dataSource = self
        tableView.delegate = self

        loadInlineBanner()

        // كارت الاجتماع القادم للفيدرالي — بيتحط في تذييل الجدول عشان
        // ما نلمسش الـ data source. التفاصيل في HomeVC+FomcCard.swift
        installFomcCard()
       
        getPrices()

        configureMetalToggle()
        ChangeGold()
        listenToOuncePrice()
      
        
    }
    
//  func getGoldPrice(){
//      timer?.invalidate()
//      timer = nil
//      let scraper = GoldPriceScraper()
//      self.getGoldOunce(scrapper:scraper)
//      timer = Timer.scheduledTimer(withTimeInterval: timerCount, repeats: true) {[weak self] _ in
//          guard let self else { return }
//          self.getGoldOunce(scrapper:scraper)
//      }
//
//    }
    
//    func getGoldOunce(scrapper: GoldPriceScraper){
//        scrapper.fetchPrice { price in
//            print(price)
//            DispatchQueue.main.async {
//                
//                self.ounce.goldPrice = price?.toDoubleSafe ?? 0.0
//                OunceService.userData = self.ounce
//            }
//            
//            print("Gold: \(self.ounce)\(self.ounce.goldPrice)\(price?.toDoubleSafe)")
//            self.tableView.reloadData()
//        }
//    }
    
//    func getSilverPrice(){
//        timer?.invalidate()
//        timer = nil
//       
//        let silver = SilverPriceScraper()
//        self.getSilverOunce(silver: silver)
//        timer = Timer.scheduledTimer(withTimeInterval: timerCount, repeats: true) {[weak self] _ in
//            guard let self else { return }
//            self.getSilverOunce(silver: silver)
//        }
//
//      }
//    
//    func getSilverOunce(silver: SilverPriceScraper) {
//        silver.fetchPrice { price in
//            
//            self.ounce.silverPrice = price?.toDoubleSafe ?? 0.0
//            OunceService.userData = self.ounce
//            print("Silver Price: \(self.ounce)\(self.ounce.silverPrice)")
//            self.tableView.reloadData()
//        }
//    }
   
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false

        resumeBannerSlider()
        setInlineBannerActive(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseBannerSlider()
        setInlineBannerActive(false)
    }

    deinit {
        ScreenMaintenanceService.shared.stopObserving(owner: self)
    }

   
    @IBAction func goldAction(_ sender: Any) {
        metalType = .Gold
        tableView.reloadData()
        ChangeGold()
        // مبقاش محتاج نعيد استدعاء سكرابر — listenToOuncePrice() شغال
        // مستمر وبيغطي الدهب والفضة مع بعض في نفس الوقت.
    }
    
    @IBAction func silverAction(_ sender: Any) {
        metalType = .Silver
        tableView.reloadData()
        ChangeSilver()
        // نفس الكلام: مفيش داعي لإعادة تشغيل سكرابر تاني.
    }
    
    /**
     خلفية الشاشة — بتتغيّر مع المعدن المختار.

     `BGView` متحطّة في الـ storyboard كأول subview، ومالهاش outlet.
     بندوّر عليها بنوعها بدل ما نضيف outlet جديد: كده التعديل مالوش
     أي أثر على ملف الـ storyboard (٤٧٥ كيلوبايت وصعب مراجعته).

     لو ما اتلقتش، التبديل بيتجاهل بهدوء والخلفية بتفضل زي ما هي.
     */
    private var brandBackground: BGView? {
        func findBackground(in parent: UIView) -> BGView? {
            if let background = parent as? BGView { return background }
            for child in parent.subviews {
                if let background = findBackground(in: child) { return background }
            }
            return nil
        }

        return findBackground(in: view)
    }

    /// Android-style segmented pill: one dark container with a single
    /// gold-filled selected segment and no gap between the two options.
    private func configureMetalToggle() {
        guard let container = GoldView?.superview as? UIStackView else { return }

        container.backgroundColor = UIColor(red: 0x1A / 255.0,
                                            green: 0x1A / 255.0,
                                            blue: 0x1A / 255.0,
                                            alpha: 1)
        container.layer.cornerRadius = 27
        container.clipsToBounds = true
        container.spacing = 0
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

        [GoldView, silverView].forEach { segment in
            segment?.layer.cornerRadius = 24
            segment?.layer.masksToBounds = true
            segment?.layer.borderWidth = 0
            segment?.subviews
                .flatMap { $0.subviews }
                .compactMap { $0 as? UILabel }
                .forEach {
                    $0.font = UIFont(name: "IBMPlexSansArabic-Bold", size: 16)
                        ?? UIFont.boldSystemFont(ofSize: 16)
                }
        }
    }

    private func setMetalSegment(_ segment: UIView, selected: Bool) {
        segment.backgroundColor = selected
            ? UIColor(red: 0xB5 / 255.0, green: 0x89 / 255.0, blue: 0x34 / 255.0, alpha: 1)
            : .clear

        segment.subviews
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }
            .forEach { $0.textColor = selected ? .black : .white }
    }

    func ChangeGold(){

        // Gold always restores the original branded background.
        brandBackground?.setTexture(named: BGView.goldTexture)

        setMetalSegment(GoldView, selected: true)
        setMetalSegment(silverView, selected: false)
      //  silverView.borderWidth = 1
       // SilverCheckImg.image = nil
       
        
        
    }
    
    func ChangeSilver(){

        // Silver uses the black geometric texture copied from Android.
        brandBackground?.setTexture(named: BGView.silverTexture)

        setMetalSegment(silverView, selected: true)
        setMetalSegment(GoldView, selected: false)
      //  silverView.borderWidth = 1
       // SilverCheckImg.image = #imageLiteral(resourceName: "check")
     
       // GoldView.borderWidth = 1
       // GoldCheckImg.image = nil
    }
    
    
    @IBAction func whasAppAction(_ sender: Any) {
        let swiftUIView = WebView(url: URL(string: "https://m.netdania.com/commodities")!)

        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
}
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if metalsArr.count == 0 { return 0 }

        // صف زيادة للشريط الإعلاني — بس لو فيه بانر فعلاً.
        // `inlineBannerRow` في HomeVC+InlineBanner.swift.
        let base = metalType == .Gold ? 8 : 7
        return inlineBanners.isEmpty ? base : base + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        /*
         الشريط الإعلاني قبل أي حاجة تانية.

         الفحص هنا فوق مش جوه فروع الدهب/الفضة عشان الصف ده مالوش
         علاقة بالمعدن المختار، ولأن الفرعين التانيين بيستخدموا
         `else` مفتوح — أي صف أعلى من المتوقع كان هيرجع خلية الفجوة
         السعرية تاني.
         */
        if let bannerRow = inlineBannerRow, indexPath.row == bannerRow {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: HomeInlineBannerCell.identifier,
                for: indexPath
            ) as! HomeInlineBannerCell

            cell.configure(with: inlineBanners)
            cell.onTapBanner = { [weak self] item in
                self?.handleInlineBannerTap(item)
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "GoldCell", for: indexPath) as! GoldCell
        if metalType == .Gold {
            if let goldMetal = metalsArr.first(where: { $0.type == "gold" }) {
                if indexPath.row < 6 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GoldCell", for: indexPath) as! GoldCell
                    self.lastUpdateLabel.text = timeAgo(dateFormated: goldMetal.updatedAt?.dateValue())
                    cell.configrationCell(buyGold21Price: goldMetal.buyPrice ?? "", saleGold21Price: goldMetal.salePrice ?? "", index: indexPath.row, ounce: ounce.goldPrice)
                    return cell
                }else if indexPath.row == 6 {
                    let cell = tableView.dequeue() as HomeDollarCell
                    
                    cell.ConfigrationCell(value: "\(ounce.goldPrice)")
                    return cell
                }
                else {
                    let cell2 = tableView.dequeue() as OunceDollarCell
                    cell2.configrationCell(buyGold21Price: goldMetal.buyPrice ?? "", saleGold21Price: goldMetal.salePrice ?? "", index: indexPath.row, ounce: ounce.goldPrice, Dollar: dollarPrice)
                    
                    cell2.pressGap = {[weak self] data in
                        guard let self else { return }
                        let swiftUIView = PriceGapView(data: data, onBack: { [weak self] in
                            self?.navigationController?.popViewController(animated: true)
                        })

                        let hostingController = UIHostingController(rootView: swiftUIView)
                        tabBarController?.tabBar.isHidden = true
                        self.navigationController?.pushViewController(hostingController, animated: true)
                    }
                    return cell2
                  
                }
              
            }
        }else if metalType == .Silver {
           
            
            if let silverMetal = metalsArr.first(where: { $0.type == "silver" }) {
               
                if indexPath.row < 5 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GoldCell", for: indexPath) as! GoldCell
                    self.lastUpdateLabel.text = timeAgo(dateFormated: silverMetal.updatedAt?.dateValue())
                    cell.configrationSilverCell(buySilverPrice: silverMetal.buyPrice ?? "", saleSilverPrice: silverMetal.salePrice ?? "", index: indexPath.row, ounce: self.ounce.silverPrice)
                    return cell
                }else if indexPath.row == 5 {
                    let cell = tableView.dequeue() as HomeDollarCell
                    
                    cell.ConfigrationCell(value: "\(self.ounce.silverPrice)")
                    return cell
                }else {
                    let cell2 = tableView.dequeue() as OunceDollarCell
                    cell2.configrationSilverCell(buySilverPrice: silverMetal.buyPrice ?? "", saleSilverPrice: silverMetal.salePrice ?? "", index: indexPath.row, ounce: self.ounce.silverPrice, Dollar: dollarPrice)

                    /*
                     الجزء ده كان ناقص: `pressGap` كانت بتتربط في فرع
                     الدهب بس. الخلية بتتعاد استخدامها، فالضغط على
                     الفجوة في وضع الفضة كان إمّا ما يعملش حاجة
                     (المغلّف فاضي) أو يفتح شاشة الدهب بأرقام قديمة.
                     */
                    cell2.pressGap = {[weak self] data in
                        guard let self else { return }
                        let swiftUIView = PriceGapView(data: data, onBack: { [weak self] in
                            self?.navigationController?.popViewController(animated: true)
                        })

                        let hostingController = UIHostingController(rootView: swiftUIView)
                        tabBarController?.tabBar.isHidden = true
                        self.navigationController?.pushViewController(hostingController, animated: true)
                    }
                    return cell2
                  
                }
            }
           
        }
      
        return cell
     
    }

    

}
extension HomeVC {
    func listenToMetals() {
        let db = Firestore.firestore()
        
        db.collection("metals").addSnapshotListener {[weak self] snapshot, error in
            guard let self = self else { return }
            guard let documents = snapshot?.documents else { return }
            
            metalsArr.removeAll()
            for doc in documents {
                var type = doc.documentID as? String
                let data = doc.data()
                var name      = data["name_ar"] as? String
                let buyPrice  = data["buyPrice"] as? String
                let salePrice = data["salePrice"] as? String
                let updatedAt = data["updatedAt"] as? Timestamp
                print(updatedAt)
                metalsArr.append(MetalModel(type: type,name: name,buyPrice: buyPrice,salePrice: salePrice,updatedAt: updatedAt))
                print("🔥", doc.documentID, buyPrice, salePrice, updatedAt)
            }
            
            MetalService.userData = self.metalsArr ?? []
            
            if let goldMetal = metalsArr.first(where: { $0.type == "gold" }) {
                metalPriceValue.goldPrice = metalPriceType(buyPrice: goldMetal.buyPrice ?? "",salePrice: goldMetal.salePrice ?? "")
            }
      
            
            if let silverMetal = metalsArr.first(where: { $0.type == "silver" }) {
                metalPriceValue.silverPrice = metalPriceType(buyPrice: silverMetal.buyPrice ?? "",salePrice: silverMetal.salePrice ?? "")
            }
            
         
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }

    /// بيقرا سعر الأوقية (الذهب/الفضة) من Firestore بدل ما يسكربه من
    /// investing.com زي GoldPriceScraper/SilverPriceScraper القدام.
    /// شكل المستند اللي السيرفر بيكتبه (index.js، كل دقيقة):
    ///   metals/ounce  →  { gold: { price: "2350.50" }, silver: { price: "29.30" } }
    func listenToOuncePrice() {
        let db = Firestore.firestore()

        db.collection("metalsOunce").document("ounce").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            guard let data = snapshot?.data() else {
                print("ounce doc missing:", error?.localizedDescription ?? "")
                return
            }

            if let goldMap = data["gold"] as? [String: Any],
               let goldPriceString = goldMap["price"] as? String,
               let goldPrice = Double(goldPriceString) {
                self.ounce.goldPrice = goldPrice
            }

            if let silverMap = data["silver"] as? [String: Any],
               let silverPriceString = silverMap["price"] as? String,
               let silverPrice = Double(silverPriceString) {
                self.ounce.silverPrice = silverPrice
            }

            OunceService.userData = self.ounce

            print("ounce from Firestore: gold=\(self.ounce.goldPrice) silver=\(self.ounce.silverPrice)")

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
                let version = data["iosversion"] as? String
                let iosneedMaintain = data["iosneedMaintain"] as? Bool
                print(version,(Double(appVersion) ?? 0.0))
                
                
                if iosneedMaintain == true {
                    let storyboard = UIStoryboard(name: PopUpsStry, bundle: nil)
                    let vc  = storyboard.instantiateViewController(withIdentifier: "UpdateAppVC") as! UpdateAppVC
                    vc.appStatus = .under_maintainance
                    vc.modalPresentationStyle = .fullScreen
                    self.addChild(vc)
                    vc.view.frame = self.view.frame
                    self.view.addSubview(vc.view)
                    vc.didMove(toParent: self)
                }else if (Double(version ?? "0.0") ?? 0.0) > (Double(appVersion) ?? 0.0) {
                    let storyboard = UIStoryboard(name: PopUpsStry, bundle: nil)
                    let vc  = storyboard.instantiateViewController(withIdentifier: "UpdateAppVC") as! UpdateAppVC
                    vc.appStatus = .updated
                    vc.modalPresentationStyle = .fullScreen
                    self.addChild(vc)
                    vc.view.frame = self.view.frame
                    self.view.addSubview(vc.view)
                    vc.didMove(toParent: self)
                }
                
            }
        }
    }
    
    func getPrices() {

        Firestore.firestore()
            .collection("banks")
            .addSnapshotListener { [weak self] snapshot, error in

                guard let self = self else { return }

                guard let documents = snapshot?.documents else {

                    print(error?.localizedDescription ?? "")

                    return
                }

                var localBankRates: [BankRate] = []

                for document in documents {

                    let data = document.data()

                    let bank = data["name"] as? String ?? ""

                    let buyValue = data["buy"] as? Double ?? 0

                    let sellValue = data["sell"] as? Double ?? 0

                    let logo = data["logo"] as? String ?? ""

                    // MARK: - Last Update

                    let timestamp = data["updatedAt"] as? Timestamp

                    let date = timestamp?.dateValue().formatted(
                        date: .omitted,
                        time: .shortened
                    ) ?? ""

                    // MARK: - Trend

                    let trendString = data["trend"] as? String ?? "same"

                    var trend: Trend = .same

                    if trendString == "up" {
                        trend = .up
                    } else if trendString == "down" {
                        trend = .down
                    }

                    let bankRate = BankRate(
                        name: bank,
                        buy: "\(buyValue)",
                        sell: "\(sellValue)",
                        logo: logo,
                        date: date,
                        trend: trend
                    )

                    localBankRates.append(bankRate)
                }

                // ترتيب الجدول حسب أعلى سعر شراء
                let sortedBanks = localBankRates.sorted {
                    (Double($0.buy) ?? 0) > (Double($1.buy) ?? 0)
                }

                // اختيار أحدث بنك من (المركزي - بنك مصر - الأهلي المصري)
                let latestBank = documents
                    .filter {
                        let name = $0.data()["name"] as? String ?? ""

                        return name.contains("المركزى")
                            || name.contains("بنك مصر")
                            || name.contains("الأهلي المصري")
                    }
                    .max {
                        let firstDate = ($0.data()["bankUpdatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
                        let secondDate = ($1.data()["bankUpdatedAt"] as? Timestamp)?.dateValue() ?? .distantPast

                        return firstDate < secondDate
                    }

                DispatchQueue.main.async {

                    BankRateService.userData = sortedBanks

                    if let latestBank {
                        print(latestBank.data())
                        let sell = latestBank.data()["sell"] as? Double ?? 0
                        self.dollarPrice = "\(sell)"
                    }

                   
                }
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.tableView.reloadData()
//                }
            }
    }
   
}



//import UIKit
//import WebKit
//
//class GoldPriceScraper: NSObject, WKNavigationDelegate {
//    
//    private var webView: WKWebView!
//    private var completion: ((String?) -> Void)?
//    
//    override init() {
//        super.init()
//       
//        webView = WKWebView(frame: .zero)
//        webView.navigationDelegate = self
//        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)"
//    }
//    
//    func fetchPrice(completion: @escaping (String?) -> Void) {
//        self.completion = completion
//        
//        let url = URL(string: "https://www.investing.com/currencies/xau-usd")!
//        webView.load(URLRequest(url: url))
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            
//            webView.evaluateJavaScript("""
//            document.querySelector('[data-test="instrument-price-last"]').innerText
//            """) { result, error in
//                
//                if let price = result as? String {
//                    self.completion?(price)
//                } else {
//                    self.completion?(nil)
//                }
//            }
//        }
//    }
//    
//    
//       
//      
//}

//import UIKit
//import WebKit
//
//class SilverPriceScraper: NSObject, WKNavigationDelegate {
//    
//    private var webView: WKWebView!
//    private var completion: ((String?) -> Void)?
//    
//    override init() {
//        super.init()
//        
//        webView = WKWebView(frame: .zero)
//        webView.navigationDelegate = self
//        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)"
//    }
//    
//    func fetchPrice(completion: @escaping (String?) -> Void) {
//        self.completion = completion
//        
//        let url = URL(string: "https://www.investing.com/currencies/xag-usd")!
//        webView.load(URLRequest(url: url))
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            
//            webView.evaluateJavaScript("""
//            document.querySelector('[data-test="instrument-price-last"]').innerText
//            """) { result, error in
//                
//                if let price = result as? String {
//                    self.completion?(price)
//                } else {
//                    self.completion?(nil)
//                }
//            }
//        }
//    }
//    
//    
//}
import Foundation
import SwiftSoup

//final class InvestingScraper {
//
//    static func fetchGoldNews(
//        isArabic: Bool,
//        completion: @escaping ([NewsModel]) -> Void
//    ) {
//
//        let urlString = isArabic
//        ? "https://sa.investing.com/commodities/gold-news"
//        : "https://www.investing.com/commodities/gold-news"
//
//        guard let url = URL(string: urlString) else {
//            completion([])
//            return
//        }
//
//        var request = URLRequest(url: url)
//
//        request.setValue(
//            "Mozilla/5.0",
//            forHTTPHeaderField: "User-Agent"
//        )
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//
//            guard let data else {
//                completion([])
//                return
//            }
//
//            do {
//
//                let html = String(data: data, encoding: .utf8) ?? ""
//
//                let doc = try SwiftSoup.parse(html)
//
//                let articles = try doc.select("article")
//
//                var news: [NewsModel] = []
//
//                for item in articles.array() {
//
//                    let title =
//                    try item.select("a").text()
//
//                    let link =
//                    try item.select("a").attr("href")
//
//                    let image =
//                    try item.select("img").attr("src")
//
//                    if !title.isEmpty {
//
//                        let model = NewsModel(
//                            title: title,
//                            image: image,
//                            link: "https://www.investing.com\(link)"
//                        )
//
//                        news.append(model)
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    completion(news)
//                }
//
//            } catch {
//
//                print(error)
//
//                DispatchQueue.main.async {
//                    completion([])
//                }
//            }
//
//        }.resume()
//    }
//
//
//}
func timeAgo(dateFormated: Date?) -> String {
    
    guard let date = dateFormated else { return "-" }
    let now = Date()
    let diff = Int(now.timeIntervalSince(date))
    
    let minute = 60
    let hour = 3600
    let day = 86400
    
    func arabicNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
  
    
    if diff < minute {
        return "Now".localized
        
    } else if diff < hour {
        let minutes = diff / minute
        
        switch minutes {
        case 1:
            return "One minute ago".localized
        case 2:
            return "Two minutes ago".localized
        case 3...10:
            return "منذ \(arabicNumber(minutes)) دقائق"
        default:
            return "منذ \(arabicNumber(minutes)) دقيقة"
        }
        
    } else if diff < day {
        let hours = diff / hour
        
        switch hours {
        case 1:
            return  "One hour ago".localized
        case 2:
            return "Two hours ago".localized
        case 3...10:
            return "منذ \(arabicNumber(hours)) ساعات"
        default:
            return "منذ \(arabicNumber(hours)) ساعة"
        }
        
    } else {
        let days = diff / day
        
        switch days {
        case 1:
            return "One day ago".localized
        case 2:
            return "Two days ago".localized
        case 3...10:
            return "منذ \(arabicNumber(days)) أيام"
        default:
            return "منذ \(arabicNumber(days)) يوم"
        }
    }
}
