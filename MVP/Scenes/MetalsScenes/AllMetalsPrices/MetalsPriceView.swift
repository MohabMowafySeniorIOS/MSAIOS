//
//  MetalsPriceView.swift
//  MSA
//
//  Created by Mohab Mowafy on 10/04/2026.
//

import UIKit

class MetalsPriceView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.RegisterNib(cell: GoldCell.self)
    }
    

    @IBAction func GoldAction(_ sender: Any) {
    }
    
    @IBAction func SilverAction(_ sender: Any) {
    }
}
extension MetalsPriceView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoldCell", for: indexPath) as! GoldCell
        return cell
    }
}
