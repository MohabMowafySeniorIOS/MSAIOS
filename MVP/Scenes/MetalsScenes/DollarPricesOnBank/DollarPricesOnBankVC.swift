//
//  DollarPricesOnBankVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 16/04/2026.
//

import UIKit
import FirebaseFirestore

enum Trend : Codable {
    case up
    case down
    case same
}



class DollarPricesOnBankVC: BaseControllerVC {
    var selectedCurrency = "USD"
    private var listener:
    ListenerRegistration?
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet weak var currencyLabel: UILabel!
    var bankRates: [CurrencyBankModel] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.pressShare = { [weak self] in
            guard let self else { return }
            self.shareApp()
        }
     
     //   self.bankRates = BankRateService.userData ?? []
        fetchCurrency()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RegisterNib(cell: DollarCell.self)
       
    
    }
    @IBAction func changeCurrencyView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "CurrencyTypeVC") as! CurrencyTypeVC
        tabBarController?.tabBar.isHidden = true
        vc.Delegate = self
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
//        self.addChild(vc)
//        vc.view.frame = self.view.frame
//        self.view.addSubview(vc.view)
//        vc.didMove(toParent: self)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
     //   getPrices()
    }
    
}
extension DollarPricesOnBankVC: chooseCurrency {
    func selectCurrency(currency: String) {
        selectedCurrency = currency
        self.fetchCurrency()
        self.selectedCurrency = currency
        self.currencyLabel.text = currency
    }
    
    
}

extension DollarPricesOnBankVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DollarCell", for: indexPath) as! DollarCell
        if !(indexPath.row > bankRates.count-1) {
            cell.ConfigrationCell(Model: bankRates[indexPath.row])
            cell.onNotificationToggle = { bankName, isOn in
                BankNotificationSettings.setEnabled(isOn, for: bankName)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(bankRates[indexPath.row].bankUrl ?? "")
        guard let urlString =
                bankRates[indexPath.row].bankUrl,
              let url =
                URL(string: urlString)
        else {
            return
        }

        UIApplication.shared.open(url)
    }
}
extension DollarPricesOnBankVC {
    func fetchCurrency() {

        listener?.remove()

        listener = Firestore.firestore()
            .collection("currencies")
            .document(selectedCurrency)
            .collection("banks")
            .order(by: "bankUpdatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in

                guard let self = self else { return }

                guard let docs = snapshot?.documents else {
                    return
                }

                let calendar = Calendar.current

                self.bankRates = docs.compactMap { doc in

                    let data = doc.data()

                    print(data)

                    return CurrencyBankModel(
                        id: doc.documentID,
                        bank: data["bank"] as? String ?? "",
                        currency: data["currency"] as? String ?? "",
                        buy: data["buy"] as? Double ?? 0,
                        sell: data["sell"] as? Double ?? 0,
                        logo: data["logo"] as? String ?? "",
                        trend: data["trend"] as? String ?? "same",
                        bankUrl: data["bankUrl"] as? String ?? "",
                        bankUpdatedAt: (data["bankUpdatedAt"] as? Timestamp)?.dateValue()
                    )
                }

                self.bankRates.sort { first, second in

                    guard let firstDate = first.bankUpdatedAt,
                          let secondDate = second.bankUpdatedAt else {
                        return false
                    }

                    // لو نفس اليوم رتب بالسعر من الأكبر للأصغر
                    if calendar.isDate(firstDate, inSameDayAs: secondDate) {
                        return first.buy > second.buy
                    }

                    // غير كده احتفظ بالترتيب حسب التاريخ
                    return firstDate > secondDate
                }

                self.tableView.reloadData()
            }
    }
//    func getPrices() {
//
//        Firestore.firestore()
//            .collection("banks")
//            .addSnapshotListener { [weak self] snapshot, error in
//
//                guard let self = self else { return }
//
//                guard let documents = snapshot?.documents else {
//
//                    print(error?.localizedDescription ?? "")
//
//                    return
//                }
//
//                var localBankRates: [BankRate] = []
//
//                for document in documents {
//
//                    let data = document.data()
//
//                    let bank =
//                        data["name"] as? String ?? ""
//
//                    let buyValue =
//                        data["buy"] as? Double ?? 0
//
//                    let sellValue =
//                        data["sell"] as? Double ?? 0
//
//                    let logo =
//                        data["logo"] as? String ?? ""
//
//                    // MARK: - Last Update
//
//                    let timestamp =
//                        data["updatedAt"] as? Timestamp
//
//                    let date =
//                        timestamp?.dateValue()
//                        .formatted(
//                            date: .omitted,
//                            time: .shortened
//                        ) ?? ""
//
//                    // MARK: - Trend
//
//                    let trendString =
//                        data["trend"] as? String ?? "same"
//
//                    var trend: Trend = .same
//
//                    if trendString == "up" {
//
//                        trend = .up
//
//                    } else if trendString == "down" {
//
//                        trend = .down
//                    }
//
//                    let bankRate = BankRate(
//
//                        name: bank,
//
//                        buy: "\(buyValue)",
//
//                        sell: "\(sellValue)",
//
//                        logo: logo,
//
//                        date: date,
//
//                        trend: trend
//                    )
//
//                    localBankRates.append(bankRate)
//                }
//
//                let sortedBanks = localBankRates.sorted {
//
//                    (Double($0.buy) ?? 0) >
//                    (Double($1.buy) ?? 0)
//                }
//
//                DispatchQueue.main.async {
//
//                    BankRateService.userData = sortedBanks
//
//                    self.bankRates = sortedBanks
//
//                    self.tableView.reloadData()
//                }
//            }
//    }
    
    func timeAgoToSeconds(_ text: String) -> Int {
        
        var totalSeconds = 0
        
        let parts = text.components(separatedBy: " / ")
        
        for part in parts {
            
            if part.contains("Minute".localized) {
                let num = extractNumber(from: part)
                totalSeconds += num * 60
                
            } else if part.contains("Hour".localized) {
                let num = extractNumber(from: part)
                totalSeconds += num * 3600
                
            } else if part.contains("Day".localized) {
                let num = extractNumber(from: part)
                totalSeconds += num * 86400
                
            } else if part.contains("Mounth".localized) {
                let num = extractNumber(from: part)
                totalSeconds += num * 2592000
            }
        }
        
        return totalSeconds
    }
    
    func extractNumber(from text: String) -> Int {
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        for num in numbers {
            if let number = formatter.number(from: num)?.intValue {
                return number
            }
        }
        
        return 0
    }
}
