//
//  DollarCell.swift
//  MSA
//
//  Created by Mohab Mowafy on 16/04/2026.
//

import UIKit

class DollarCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bankImage: UIImageView!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var buyPriceLAbel: UILabel!
    @IBOutlet weak var salePriceLAbel: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var arrowIcon2: UIImageView!

    /// الصف السفلي اللي فيه سويتش تفعيل/تعطيل إشعار تغيّر السعر. بيظهر بس
    /// وإحنا في تبويب الدولار (USD)، لإن ده الوحيد اللي بيبعتله السيرفر
    /// إشعارات تغيّر سعر لكل بنك (index.js).
    @IBOutlet weak var notificationRow: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!

    /// بيتنادى لما المستخدم يغيّر السويتش يدويًا، وبيرجع اسم البنك وحالة
    /// السويتش الجديدة.
    var onNotificationToggle: ((String, Bool) -> Void)?

    private var currentBankName: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        notificationSwitch?.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        guard !currentBankName.isEmpty else { return }
        onNotificationToggle?(currentBankName, sender.isOn)
    }

    func ConfigrationCell(Model: CurrencyBankModel){
        bankImage.loadImage(Model.logo)
        bankNameLabel.text = Model.bank
        buyPriceLAbel.text = "\(Model.buy)"
        salePriceLAbel.text = "\(Model.sell)"
        currentBankName = Model.bank

        if ((bankNameLabel.text?.contains("المركزى"))) == true {
            bgView.backgroundColor = .MainColor
        }else {
            bgView.backgroundColor = .clear
        }

        if Model.trend == "up" {
            arrowIcon.image = UIImage(named: "ArrowUp")?.withTintColor(.green)
            arrowIcon2.image = UIImage(named: "ArrowUp")?.withTintColor(.green)
        }else if Model.trend == "down" {
            arrowIcon.image = UIImage(named: "ArrowDown")?.withTintColor(.red)
            arrowIcon2.image = UIImage(named: "ArrowDown")?.withTintColor(.red)

        }else if Model.trend == "same" {
            arrowIcon.image = UIImage(named: "ArrowUp")?.withTintColor(.green)
            arrowIcon2.image = UIImage(named: "ArrowUp")?.withTintColor(.green)
        }

        // إشعارات تغيّر سعر الدولار متاحة بس على تبويب الدولار (USD)، فالسويتش
        // بيظهر بس هناك. أول مرة يظهر فيها البنك ده، BankNotificationSettings
        // بتحدد القيمة الافتراضية بنفسها (المركزي = مفعّل، غيره = معطّل).
        if Model.currency == "USD" {
            notificationRow.isHidden = false
            notificationSwitch.isOn = BankNotificationSettings.ensureDefault(for: Model.bank)
        } else {
            notificationRow.isHidden = true
        }
    }

}
