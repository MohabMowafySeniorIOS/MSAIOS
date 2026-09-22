//
//  NewsCell.swift
//  MSA
//
//  Created by Mohab Mowafy on 15/04/2026.
//

import UIKit

class NewsCell: UITableViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgCell: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configrationCell(Model: NewsItem){
        imgCell.loadImage(Model.urlToImage ?? "")
        titleLabel.text = Model.title
        desLabel.text = Model.description ?? ""
        let isoFormatter = ISO8601DateFormatter()

        if let date = isoFormatter.date(from: Model.publishedAt ?? "") {

            let displayFormatter = DateFormatter()

            displayFormatter.dateFormat = "dd MMM yyyy - hh:mm a"

            let result = displayFormatter.string(from: date)
            dateLabel.text = result
            print(result)

        }
        
    }
    
}
