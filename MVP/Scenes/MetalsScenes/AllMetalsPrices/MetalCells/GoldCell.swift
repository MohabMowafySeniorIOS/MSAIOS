//
//  GoldCell.swift
//  MSA
//
//  Created by Mohab Mowafy on 10/04/2026.
//

import UIKit
struct SilverPricesPortfolio {
    let price999: Double
    
    let price925: Double
    let price900: Double
    let price800: Double
    let price700: Double
    
    let ounce: Double      // 31.1 g
    let kilo: Double       // 1000 g
    
    let coin925: Double    // جنيه فضة (8g عيار 925)
}

class GoldCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var salePriceLabel: UILabel!
    @IBOutlet weak var BuyPriceLabel: UILabel!
    @IBOutlet weak var karatLAbel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configrationCell(buyGold21Price: String,saleGold21Price: String,index: Int,ounce: Double){
        let saleGold24Price = (Double(saleGold21Price) ?? 0.0) / 0.875
        let buyGold24Price = (Double(buyGold21Price) ?? 0.0) / 0.875
       
        if index == 0 {
            
            salePriceLabel.text = "Sale".localized
            BuyPriceLabel.text = "Buy".localized
            karatLAbel.text = "Karat".localized
            handleBGColor(isDark: true, isKarat21: false)
            salePriceLabel.backgroundColor = UIColor.clear
            BuyPriceLabel.backgroundColor = UIColor.clear
            karatLAbel.backgroundColor = UIColor.clear
            BuyPriceLabel.isHidden = false
        }else if index == 1 {
            handleBGColor(isDark: false, isKarat21: false)
            salePriceLabel.text = trimNumber(number: saleGold24Price)
            BuyPriceLabel.text =  trimNumber(number: buyGold24Price)
            karatLAbel.text = "24"
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.isHidden = false
        }else if index == 2 {
            handleBGColor(isDark: false, isKarat21: true)
            salePriceLabel.text = trimNumber(number: Double(saleGold21Price) ?? 0.0)
            BuyPriceLabel.text = trimNumber(number: Double(buyGold21Price) ?? 0.0 )
            karatLAbel.text = "21"
            salePriceLabel.backgroundColor = UIColor.MainColor
            BuyPriceLabel.backgroundColor = UIColor.MainColor
            karatLAbel.backgroundColor = UIColor.MainColor
            BuyPriceLabel.isHidden = false
        }else if index == 3 {
            handleBGColor(isDark: false, isKarat21: false)
            salePriceLabel.text = trimNumber(number: (saleGold24Price * 0.75))
            BuyPriceLabel.text = trimNumber(number: (buyGold24Price * 0.75))
            karatLAbel.text = "18"
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.isHidden = false
        }else if index == 4 {
            handleBGColor(isDark: false, isKarat21: false)
            salePriceLabel.text = trimNumber(number: ((Double(saleGold21Price) ?? 0.0) * 8))
            BuyPriceLabel.text = trimNumber(number: ((Double(buyGold21Price) ?? 0.0) * 8))
            karatLAbel.text = "Gold pound".localized
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.isHidden = false
        }else if index == 5 {
            handleBGColor(isDark: false, isKarat21: false)
            salePriceLabel.text = trimNumber(number: (saleGold24Price * 1000))
            BuyPriceLabel.text = trimNumber(number: (buyGold24Price * 1000))
            karatLAbel.text = "كيلو دهب".localized
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.isHidden = false
        }else if index == 6 {
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            handleBGColor(isDark: false, isKarat21: false)
            print("\(Double(salePriceLabel.text ?? "0.0") ?? 0.0)", "\(ounce)")
//            if !((Double(salePriceLabel.text ?? "0.0") ?? 0.0) < ounce) {
//                
//                bgView.backgroundColor = .green
//            }else {
//                bgView.backgroundColor = .red
//            }
            salePriceLabel.text = "\(ounce)"
            BuyPriceLabel.isHidden = true
            karatLAbel.text = "Ounce".localized
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//                self.bgView.backgroundColor = .white
//            }
        }else if index == 7 {
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
//            if !((Double(salePriceLabel.text ?? "0.0") ?? 0.0) < ounce) {
//                
//                bgView.backgroundColor = .green
//            }else {
//                bgView.backgroundColor = .red
//            }
            handleBGColor(isDark: false, isKarat21: false)
            salePriceLabel.text =  trimNumber(number: Double(calculateGoldDollarRate(
                ouncePriceUSD: ounce,
                localGramPrice24: saleGold24Price
            )) ?? 0.0)
            
        
            
            BuyPriceLabel.isHidden = true
            karatLAbel.text = "دولار الصاغة".localized
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//                self.bgView.backgroundColor = .white
//            }
        }
       
    }
    
   
    
    func handleBGColor(isDark: Bool,isKarat21: Bool) {
        if isDark {
            karatLAbel.textColor = .white
            salePriceLabel.textColor = .white
            BuyPriceLabel.textColor = .white
            
            karatLAbel.backgroundColor = .clear
            salePriceLabel.backgroundColor = .clear
            BuyPriceLabel.backgroundColor = .clear
        }else {
            if isKarat21 {
                karatLAbel.textColor = .white
                salePriceLabel.textColor = .white
                BuyPriceLabel.textColor = .white
            }else {
                karatLAbel.textColor = .black
                salePriceLabel.textColor = .black
                BuyPriceLabel.textColor = .black
            }
          
            
            karatLAbel.backgroundColor = .white
            salePriceLabel.backgroundColor = .white
            BuyPriceLabel.backgroundColor = .white
        }
    }
    
    func calculateGoldDollarRate(
        ouncePriceUSD: Double,
        localGramPrice24: Double
    ) -> String {
        return "\((localGramPrice24 * 31.1035) / ouncePriceUSD)"
    }
    
    func configrationSilverCell(buySilverPrice: String,saleSilverPrice: String,index: Int,ounce: Double){
        let saleSilverPrices = calculateSilverPrices(from: Double(saleSilverPrice) ?? 0.0)
        let buySilverPrices = calculateSilverPrices(from: Double(buySilverPrice) ?? 0.0)
       
        if index == 0 {
            BuyPriceLabel.isHidden = false
            salePriceLabel.text = "Sale".localized
            BuyPriceLabel.text = "Buy".localized
            karatLAbel.text = "Karat".localized
            salePriceLabel.backgroundColor = UIColor.clear
            BuyPriceLabel.backgroundColor = UIColor.clear
            karatLAbel.backgroundColor = UIColor.clear
        }else if index == 1 {
            BuyPriceLabel.isHidden = false
            salePriceLabel.text = trimNumber(number: saleSilverPrices.price999)
            BuyPriceLabel.text =  trimNumber(number: buySilverPrices.price999)
            karatLAbel.text = "999"
            salePriceLabel.backgroundColor = UIColor.MainColor
            BuyPriceLabel.backgroundColor = UIColor.MainColor
            karatLAbel.backgroundColor = UIColor.MainColor
        }else if index == 2 {
            BuyPriceLabel.isHidden = false
            salePriceLabel.text = trimNumber(number: saleSilverPrices.price925)
            BuyPriceLabel.text =  trimNumber(number: buySilverPrices.price925)
            karatLAbel.text = "925"
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
        }else if index == 3 {
            BuyPriceLabel.isHidden = false
            salePriceLabel.text = trimNumber(number: saleSilverPrices.price800)
            BuyPriceLabel.text =  trimNumber(number: buySilverPrices.price800)
            karatLAbel.text = "800"
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
        }else if index == 4 {
            BuyPriceLabel.isHidden = false
            salePriceLabel.text = trimNumber(number: saleSilverPrices.kilo)
            BuyPriceLabel.text =  trimNumber(number: buySilverPrices.kilo)
            karatLAbel.text = "One kilo of silver".localized
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
        }
//        else if index == 5 {
//            BuyPriceLabel.isHidden = false
//            salePriceLabel.text = trimNumber(number: saleSilverPrices.coin925)
//            BuyPriceLabel.text =  trimNumber(number: buySilverPrices.coin925)
//            karatLAbel.text = "Silver pound".localized
//            salePriceLabel.backgroundColor = UIColor.WhiteColor
//            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
//            karatLAbel.backgroundColor = UIColor.WhiteColor
//        }else if index == 6 {
//            BuyPriceLabel.isHidden = false
//            salePriceLabel.text = trimNumber(number: saleSilverPrices.ounce)
//            BuyPriceLabel.text =  trimNumber(number: buySilverPrices.ounce)
//            karatLAbel.text = "The ounce".localized
//            salePriceLabel.backgroundColor = UIColor.WhiteColor
//            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
//            karatLAbel.backgroundColor = UIColor.WhiteColor
//        }
        else if index == 5 {
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            print("\(Double(salePriceLabel.text ?? "0.0") ?? 0.0)", "\(ounce)")
//            if !((Double(salePriceLabel.text ?? "0.0") ?? 0.0) < ounce) {
//                bgView.backgroundColor = .green
//            }else {
//                bgView.backgroundColor = .red
//            }
            
            BuyPriceLabel.isHidden = true
            salePriceLabel.text = "\(ounce)"
            BuyPriceLabel.text = "\(ounce)"
            karatLAbel.text = "Ounce".localized
            
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//                self.bgView.backgroundColor = .white
//            }
        }else if index == 6 {
            salePriceLabel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.backgroundColor = UIColor.WhiteColor
            karatLAbel.backgroundColor = UIColor.WhiteColor
            BuyPriceLabel.isHidden = true
            salePriceLabel.text = trimNumber(number: Double(calculateGoldDollarRate(
                ouncePriceUSD: ounce,
                localGramPrice24: buySilverPrices.price900
            )) ?? 0.0)
          //BuyPriceLabel.text = trimNumber(number: (buyGold24Price * 1000))
            karatLAbel.text = "دولار الصاغة".localized
            bgView.backgroundColor = .white
        }
       
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
