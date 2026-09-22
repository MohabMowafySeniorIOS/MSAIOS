//
//  CurrencyTypeVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 24/05/2026.
//

import UIKit

protocol chooseCurrency {
    func selectCurrency(currency: String)
}

struct CurrencyOption {
    var code: String?
    var name: String?
}

class CurrencyTypeVC: UIViewController {
    var Delegate: chooseCurrency?
    let currencies = [
        CurrencyOption(code: "USD", name: "الدولار الأمريكي"),
        CurrencyOption(code: "EUR", name: "اليورو"),
        CurrencyOption(code: "GBP", name: "الجنيه الإسترليني"),
        CurrencyOption(code: "SAR", name: "الريال السعودي"),
        CurrencyOption(code: "AED", name: "الدرهم الإماراتي"),
        CurrencyOption(code: "KWD", name: "الدينار الكويتي"),
        CurrencyOption(code: "QAR", name: "الريال القطري"),
        CurrencyOption(code: "BHD", name: "الدينار البحريني"),
        CurrencyOption(code: "OMR", name: "الريال العماني"),
        CurrencyOption(code: "JOD", name: "الدينار الأردني"),
        CurrencyOption(code: "CHF", name: "الفرنك السويسري"),
        CurrencyOption(code: "CAD", name: "الدولار الكندي"),
        CurrencyOption(code: "AUD", name: "الدولار الأسترالي"),
        CurrencyOption(code: "CNY", name: "اليوان الصيني"),
        CurrencyOption(code: "JPY", name: "الين الياباني"),
         //  CurrencyOption("TRY", "الليرة التركية")
    ]
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RegisterNib(cell: ChooseCurrencyCell.self)
    }
    

    @IBAction func dismissAction(_ sender: Any) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
}

extension CurrencyTypeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue() as ChooseCurrencyCell
        cell.currencyLabel.text = "\(currencies[indexPath.row].name ?? "")-\(currencies[indexPath.row].code ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.Delegate?.selectCurrency(currency: currencies[indexPath.row].code ?? "")
        tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
}
