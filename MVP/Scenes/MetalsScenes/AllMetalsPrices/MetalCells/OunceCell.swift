//
//  GoldCell.swift
//  MSA
//
//  Created by Mohab Mowafy on 10/04/2026.
//

import UIKit


class OunceCell: UITableViewCell {
  
//   
//    @IBOutlet weak var dollarBG: UIStackView!
//    @IBOutlet weak var OunceBG: UIStackView!
//    @IBOutlet weak var DollarLabel: UILabel!
//    @IBOutlet weak var OunceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configrationCell(buyGold21Price: String,saleGold21Price: String,index: Int,ounce: Double){
//        let saleGold24Price = (Double(saleGold21Price) ?? 0.0) / 0.875
//        let buyGold24Price = (Double(buyGold21Price) ?? 0.0) / 0.875
//       
//       
//            print("\(Double(OunceLabel.text ?? "0.0") ?? 0.0)", "\(ounce)")
//            if !((Double(OunceLabel.text ?? "0.0") ?? 0.0) < ounce) {
//                
//                OunceBG.backgroundColor = .green
//            }else {
//                OunceBG.backgroundColor = .red
//            }
//        OunceLabel.text = "\(ounce)"
//        OunceLabel.isHidden = true
//           
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//                self.OunceBG.backgroundColor = .white
//            }
//      
//            if !((Double(DollarLabel.text ?? "0.0") ?? 0.0) < ounce) {
//                
//                dollarBG.backgroundColor = .green
//            }else {
//                dollarBG.backgroundColor = .red
//            }
//          
//            DollarLabel.text =  trimNumber(number: Double(calculateGoldDollarRate(
//                ouncePriceUSD: ounce,
//                localGramPrice24: saleGold24Price
//            )) ?? 0.0)
//            
//        
//          
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//                self.dollarBG.backgroundColor = .white
//            }
//       
       
    }
    
    
    
    func calculateGoldDollarRate(
        ouncePriceUSD: Double,
        localGramPrice24: Double
    ) -> String {
        return "\((localGramPrice24 * 31.1035) / ouncePriceUSD)"
    }
    
  
    
    func trimNumber(number: Double) -> String {
        let formatted = String(format: "%.2f", number)
        return formatted
    }
    
    func calculateSilverPrices(from base999: Double) -> SilverPricesPortfolio {
        
        func calc(_ purity: Double) -> Double {
            return base999 * (purity / 999)
        }
        
        let price925 = calc(925)
        let price900 = calc(900)
        let price800 = calc(800)
        let price700 = calc(700)
        
        let ounce = base999 * 31.1
        let kilo = base999 * 1000
        
        let coin925 = price925 * 8 // جنيه فضة
        
        return SilverPricesPortfolio(
            price999: base999,
            price925: price925,
            price900: price900,
            price800: price800,
            price700: price700,
            ounce: ounce,
            kilo: kilo,
            coin925: coin925
        )
    }
    
}
