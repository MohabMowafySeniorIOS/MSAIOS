//
//  NotificationCell.swift
//  zoud
//
//  Created by Mohab on 8/24/21.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var NotificationIcon: UIImageView!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    var Press_Delete : (()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func deleteNotifications(_ sender: Any) {
        Press_Delete?()
    }
    
//    func Configration_Cell(Model:NotificationModel){
//        messageLbl.text = " \(Model.body ?? "")"
//        
//       // messageLbl.colorString(text: (Model.title ?? "") + " \(Model.body ?? "")", coloredText: (Model.title ?? ""),color:.MainColor)
//        timeLbl.text = Model.date
//        
//        if Model.is_read == true {
//            NotificationIcon.image = #imageLiteral(resourceName: "notificationiconold")
//        }else {
//            
//            NotificationIcon.image = #imageLiteral(resourceName: "notificationiconnew")
//        }
//    }
    
}
