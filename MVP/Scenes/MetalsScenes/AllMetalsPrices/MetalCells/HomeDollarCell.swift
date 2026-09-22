//
//  DollarCell.swift
//  MSA
//
//  Created by Mohab Mowafy on 07/05/2026.
//

import UIKit

class HomeDollarCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func ConfigrationCell(value: String) {
    
        
        if ((Double(valueLabel.text ?? "0.0") ?? 0.0) < (Double(value) ?? 0.0)) {
            bgView.backgroundColor = .green
        }else {
            bgView.backgroundColor = .red
        }
        
        keyLabel.text = "Screen".localized
        valueLabel.text = value
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
            self.bgView.backgroundColor = .white
        }
        
        
    }
    
}
