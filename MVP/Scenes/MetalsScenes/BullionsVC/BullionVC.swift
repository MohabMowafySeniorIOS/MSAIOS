//
//  BullionVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 21/04/2026.
//

import UIKit
import FirebaseFirestore

class BullionVC: BaseControllerVC {

    var bullionArr: [String] = []
    var bullionTypesArr: [String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    private var pullRefresh: MSAPullToRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RegisterNib(cell: BullionCell.self)
        
        tableView2.dataSource = self
        tableView2.delegate = self
        tableView2.RegisterNib(cell: BullionCell.self)

        pullRefresh = addMSAPullToRefresh(to: tableView) { [weak self] in
            self?.getBrands()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self?.pullRefresh?.endRefreshing()
            }
        }
        
        getBrands()
    }
   
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
extension BullionVC {


        func getMetal(billionId: String) {

            let db = Firestore.firestore()

            db.collection("bullion")
                             .document("billionId")
                             .collection("brands")
                             .document("brandId")
                             .collection(billionId) // 👈 دي
                             .getDocuments { snapshot, _ in
                                 snapshot?.documents.forEach { doc in
                                     print(doc.data())
                                     if let names = doc.data() as? [String:[String]] {
                                         print(names)
                                         self.bullionTypesArr.removeAll()
                                         for (key,value) in names {
                                             print(key,value)
                                             if let values = value as? [String] {
                                                 self.bullionTypesArr = values
                                                 self.tableView2.reloadData()
                                             }
                                         }
                                         
                                     }
                                 }
                }
        }
     
    func getBrands() {
        let db = Firestore.firestore()
        
        db.collection("bullion")
          .document("billionId")
          .collection("brands")
          .getDocuments { snapshot, _ in
              snapshot?.documents.forEach { doc in
                  print(doc.data())
                  let names = doc.data()
                  for (key,value) in names  {
                      let names = value as? [String]
                      self.bullionArr = names ?? []
                      self.tableView.reloadData()
                      print(self.bullionArr)
                      for name in names ?? [] {
                          print(name)
                      }
                  }
              }
        }
    }
}
extension BullionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView2 {
            return bullionTypesArr.count
        }else {
            return  bullionArr.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BullionCell", for: indexPath) as! BullionCell
        if tableView == self.tableView2 {
            cell.titleLabel.text = bullionTypesArr[indexPath.row]
        }else {
            cell.titleLabel.text = bullionArr[indexPath.row]
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            self.getMetal(billionId: self.bullionArr[indexPath.row])
        }
    }
}
