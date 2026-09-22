//
//  AllNewsVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 15/04/2026.
//


import UIKit
import FirebaseFirestore

class AllNewsVC: BaseControllerVC {

//    @IBOutlet weak var checkMind: UIImageView!
//    @IBOutlet weak var checkNews: UIImageView!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var MindView: UIView!
    @IBOutlet weak var headerView: HeaderView!
    
    
    var articles: [NewsItem] = []
    var MAnualarticles: [NewsItem] = []
    
    var isManual: Bool = false

    /// التحميل بيحصل مرة واحدة حتى لو العلم اتقلب أكتر من مرة
    private var didLoadNews = false

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {

        super.viewDidLoad()
        headerView.pressShare = { [weak self] in
            guard let self else { return }
            self.shareApp()
        }
        self.title = "News".localized

        tableView.dataSource = self
        tableView.delegate = self

        tableView.RegisterNib(
            cell: NewsCell.self
        )

        /*
         مفتاح صيانة تبويب الأخبار (`NewsMaintain` في مستند
         `appVersion`).

         الغطا بيتحط على `view` بتاع الكنترولر وده جوّه الـtab bar،
         فالشريط بيفضل ظاهر وشغّال والمستخدم يروح لتبويب تاني.

         **التحميل جوّه `onLive`**: من غير كده الشاشة كانت بتفتح
         مراقب Firestore وبتضرب السيرفر ورا كارت الصيانة — ولو
         التبويب مقفول أصلاً عشان الأخبار بايظة، ده بيضرب الحتة
         البايظة بالظبط. ولما المشرف يقفل العلم، التحميل بيحصل
         ساعتها من غير ما المستخدم يعمل أي حاجة.

         **بعد تجهيز الجدول عن قصد**: `onLive` بتتنادى فوراً بالحالة
         المحفوظة، والتحميل اللي جواها بيعمل `reloadData` — فلازم
         الـdataSource والـnib يكونوا اتظبطوا قبلها.
         */
        bindScreenMaintenance(.news) { [weak self] in
            self?.loadNewsIfNeeded()
        }

        ChangeNews()
    }

    /// بيتنادى أول ما التبويب يبقى شغّال (مش في صيانة)
    private func loadNewsIfNeeded() {
        guard !didLoadNews else { return }
        didLoadNews = true

        getNews()
        getManualNews()
    }

    deinit {
        ScreenMaintenanceService.shared.stopObserving(owner: self)
    }
    
    @IBAction func newsAction(_ sender: Any) {
        isManual = false
        ChangeNews()
        self.tableView.reloadData()
    }
    
    @IBAction func manualNews(_ sender: Any) {
        isManual = true
        ChangeMind()
        self.tableView.reloadData()
    }
    
  
    
    func ChangeNews(){
    
        newView.borderColor = UIColor.selectionBorder
       // newView.borderWidth = 1
       // checkNews.image = #imageLiteral(resourceName: "check")
        newView.backgroundColor = UIColor.MainColor

        
        MindView.borderColor = UIColor.clear
        MindView.backgroundColor = UIColor.selectionBackGround?.withAlphaComponent(1)
       // MindView.borderWidth = 1
      //  checkMind.image = nil
       
        
        
    }
    
    func ChangeMind(){
      
        MindView.borderColor = UIColor.selectionBorder
        MindView.backgroundColor = UIColor.MainColor
//        MindView.borderWidth = 1
//        checkMind.image = #imageLiteral(resourceName: "check")
//     
        
        newView.borderColor = UIColor.clear
        newView.backgroundColor = UIColor.selectionBackGround?.withAlphaComponent(1)
//        newView.borderWidth = 1
//        checkNews.image = nil
    }
    
}



// MARK: - UITableView

extension AllNewsVC:
UITableViewDataSource,
UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return isManual ? MAnualarticles.count : articles.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeue() as NewsCell

        cell.configrationCell(
            Model: isManual ? MAnualarticles[indexPath.row] : articles[indexPath.row]
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        if isManual {
            guard let urlString =
                    MAnualarticles[indexPath.row].urlToImage,
                  let url =
                    URL(string: urlString)
            else {
                return
            }
            Helper.openZoomAbleImage(image: [urlString], vc: self, index: 0)
            //UIApplication.shared.open(url)
        }else {
            guard let urlString =
                    articles[indexPath.row].url,
                  let url =
                    URL(string: urlString)
            else {
                return
            }

            UIApplication.shared.open(url)
        }
       
    }
}



// MARK: - Firebase

extension AllNewsVC {

    func getNews() {

        self.lock()

        Firestore.firestore()
            .collection("news")
            .order(by: "publishedAt", descending: true)
            .addSnapshotListener {
                [weak self] snapshot,
                error in

                guard let self = self else {
                    return
                }

                self.unlock()

                if let error {

                    print(
                        error.localizedDescription
                    )

                    return
                }

                guard let documents =
                        snapshot?.documents
                else {
                    return
                }

                var localArticles:
                [NewsItem] = []

                for document in documents {

                    let data =
                    document.data()

                    let article =
                    NewsItem(

                        title:
                            data["title"]
                            as? String,

                        description:
                            data["description"]
                            as? String,

                        url:
                            data["url"]
                            as? String,

                        urlToImage:
                            data["imageUrl"]
                            as? String,

                        publishedAt:
                            data["publishedAt"]
                            as? String,

                        source:
                            Source(
                                name:
                                    data["source"]
                                    as? String
                            )
                    )

                    localArticles.append(
                        article
                    )
                }

                DispatchQueue.main.async {

                    self.articles =
                    localArticles

                    self.tableView.reloadData()
                }
            }
    }
    
    func getManualNews() {
        let url = "\(hostName)news"
        self.lock()
        APIClient.shared.performRequestWithAlamofire(urlString: url, method: .get, parameters:nil) { [weak self] (Model: NewsModel? , err : String? )in
            self?.unlock()
            guard let self = self else { return }
            
            for item in Model?.data ?? [] {
                self.MAnualarticles.append(item.map())
            }
            print(self.MAnualarticles)
            self.tableView.reloadData()
            
        }
    }
    
    
//    func getManualNews() {
//
//        self.lock()
//        
//
//        Firestore.firestore()
//            .collection("manual_news")
//            .order(by: "publishedAt", descending: true)
//            .addSnapshotListener {
//                [weak self] snapshot,
//                error in
//
//                guard let self = self else {
//                    return
//                }
//
//                self.unlock()
//
//                if let error {
//
//                    print(
//                        error.localizedDescription
//                    )
//
//                    return
//                }
//
//                guard let documents =
//                        snapshot?.documents
//                else {
//                    return
//                }
//
//                var localArticles:
//                [NewsItem] = []
//
//                for document in documents {
//
//                    let data =
//                    document.data()
//
//                    let article =
//                    NewsItem(
//
//                        title:
//                            data["title"]
//                            as? String,
//
//                        description:
//                            data["description"]
//                            as? String,
//
//                        url:
//                            data["url"]
//                            as? String,
//
//                        urlToImage:
//                            data["imageUrl"]
//                            as? String,
//
//                        publishedAt:
//                            data["publishedAt"]
//                            as? String,
//
//                        source:
//                            Source(
//                                name:
//                                    data["source"]
//                                    as? String
//                            )
//                    )
//
//                    localArticles.append(
//                        article
//                    )
//                }
//
//                DispatchQueue.main.async {
//
//                    self.MAnualarticles =
//                    localArticles
//
//                    self.tableView.reloadData()
//                }
//            }
//    }
}
struct NewsItem: Codable {
    
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let source: Source?
}

struct Source: Codable {
    
    let name: String?
}


