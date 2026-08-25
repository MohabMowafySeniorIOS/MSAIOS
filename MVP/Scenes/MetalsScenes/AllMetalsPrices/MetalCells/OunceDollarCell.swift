//
//  OunceDollarCell.swift
//  MSA
//
//  Created by Mohab Mowafy on 07/05/2026.
//

import Foundation
import UIKit

class OunceDollarCell: UITableViewCell {
    @IBOutlet weak var gabBGView: UIView!
    @IBOutlet weak var gabLabel: UILabel!
    var gab = 0.0
    /// كل الأرقام اللي شاشة "الفجوة السعرية" (PriceGapView) محتاجاها،
    /// بتتحدث كل مرة configrationCell (الذهب) تتنادى.
    var gapData = PriceGapData()
    var pressGap: ((PriceGapData) -> Void)?
    @IBOutlet weak var gapvalueLabel: UILabel!
    @IBOutlet weak var dollarBG: UIStackView!
      @IBOutlet weak var OunceBG: UIStackView!
      @IBOutlet weak var DollarLabel: UILabel!
      @IBOutlet weak var OunceLabel: UILabel!
      override func awakeFromNib() {
          super.awakeFromNib()
          // Initialization code
      }

      override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)

          // Configure the view for the selected state
      }
      
    func configrationCell(buyGold21Price: String,saleGold21Price: String,index: Int,ounce: Double, Dollar: String){
        gabBGView.isHidden = false
          let saleGold24Price = (Double(saleGold21Price) ?? 0.0) / 0.875
          let buyGold24Price = (Double(buyGold21Price) ?? 0.0) / 0.875
  
  
              print("\(Double(OunceLabel.text ?? "0.0") ?? 0.0)", "\(ounce)")
//              if ((Double(OunceLabel.text ?? "0.0") ?? 0.0) > ounce) {
//                  OunceBG.backgroundColor = .red
//                  dollarBG.backgroundColor = .red
//                
//              }else {
//                  OunceBG.backgroundColor = .green
//                  dollarBG.backgroundColor = .green
//              }
          OunceLabel.text = "\(Dollar)"
          DollarLabel.text =  trimNumber(number: Double(calculateGoldDollarRate(
              ouncePriceUSD: ounce,
              localGramPrice24: saleGold24Price
          )) ?? 0.0)
         
          var gapPrice = (Double( trimNumber(number: Double(calculateGoldDollarRate(
            ouncePriceUSD: ounce,
            localGramPrice24: saleGold24Price
          )) ?? 0.0)) ?? 0.0) - (Double(Dollar) ?? 0.0)
          var Karat24 = ounce * (Double(Dollar) ?? 0.0) / 31.1
        print(ounce,Karat24,(Double(Dollar) ?? 0.0),buyGold24Price)
           gab = round(Karat24 - saleGold24Price)
        gapvalueLabel.text = "جاري التحميل";
        if ounce > 0 {
            if gab > 0 {
                gapvalueLabel.textColor = .green
                gabLabel.textColor = .green
            }else {
                gapvalueLabel.textColor = .red
                gabLabel.textColor = .red
            }

            gapvalueLabel.text = "\(abs(gab)) " + "EGP".localized
        }
       // "\(trimNumber(number: gapPrice))"

        // MARK: - Price Gap screen data
        // نفس الحسابات اللي في Android (PriceGapDetailsViewModel) بالظبط:
        //   worldPerGramUsd = ounce / 31.1035
        //   gap21 = |gold21Local − (worldPerGramUsd * 21/24 * dollarBank)|
        let dollarBankValue = Double(Dollar) ?? 0.0
        let worldPerGramUsd = ounce > 0 ? ounce / 31.1035 : 0.0
        let dollarSaghaValue = Double(calculateGoldDollarRate(
            ouncePriceUSD: ounce,
            localGramPrice24: saleGold24Price
        )) ?? 0.0
        let gold21Local = Double(saleGold21Price) ?? 0.0
        let world21InEgp = worldPerGramUsd * (21.0 / 24.0) * dollarBankValue
        let gap21Signed = world21InEgp - gold21Local

        gapData = PriceGapData(
            worldPerGramUsd: worldPerGramUsd,
            gold24LocalEgp: saleGold24Price,
            dollarSagha: dollarSaghaValue,
            dollarBank: dollarBankValue,
            gaugeValue: gab,
            gap24Abs: abs(gab),
            gap24IsNegative: gab < 0,
            gap21Abs: abs(gap21Signed),
            gap21IsNegative: gap21Signed < 0
        )
  
//              UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//                  self.OunceBG.backgroundColor = .white
//                  self.dollarBG.backgroundColor = .white
//              }
  
             
              
  
  
  
         
      }
    
    @IBAction func pressGapAction(_ sender: Any) {
        pressGap?(gapData)
    }
    
    
    func configrationSilverCell(buySilverPrice: String,saleSilverPrice: String,index: Int,ounce: Double, Dollar: String){
        gabBGView.isHidden = false
        
        let saleSilverPrices = calculateSilverPrices(from: Double(saleSilverPrice) ?? 0.0)
        let buySilverPrices = calculateSilverPrices(from: Double(buySilverPrice) ?? 0.0)
        
//        print("\(Double(OunceLabel.text ?? "0.0") ?? 0.0)", "\(ounce)")
//                  if ((Double(OunceLabel.text ?? "0.0") ?? 0.0) > ounce) {
//                      OunceBG.backgroundColor = .red
//                      dollarBG.backgroundColor = .red
//                  }else {
//                      OunceBG.backgroundColor = .green
//                      dollarBG.backgroundColor = .green
//                     
//                  }
        
      
        
    OunceLabel.text = Dollar
        print(ounce)
        print(buySilverPrice)
    DollarLabel.text =  trimNumber(number: Double(calculateGoldDollarRate(
        ouncePriceUSD: ounce,
        localGramPrice24: Double(buySilverPrice) ?? 0.0
    )) ?? 0.0)
   
        var buySilverPrice999 = Double(saleSilverPrice) ?? 0.0
        var gapPrice = (Double( trimNumber(number: Double(calculateGoldDollarRate(
          ouncePriceUSD: ounce,
          localGramPrice24: Double(buySilverPrice) ?? 0.0
        )) ?? 0.0)) ?? 0.0) - (Double(Dollar) ?? 0.0)
        var Karat999 = ounce * (Double(Dollar) ?? 0.0) / 31.1
      print(ounce,Karat999,(Double(Dollar) ?? 0.0),buySilverPrice999)
         gab = round(Karat999 - buySilverPrice999)
        gapvalueLabel.text = "جاري التحميل";
        if ounce > 0 {
            if gab > 0 {
                gapvalueLabel.textColor = .green
                gabLabel.textColor = .green
            }else {
                gapvalueLabel.textColor = .red
                gabLabel.textColor = .red
            }
            
          gapvalueLabel.text = "\(abs(gab)) " + "EGP".localized
        }
        // "\(tri
        
//        var gapPrice = (Double( trimNumber(number: Double(calculateGoldDollarRate(
//            ouncePriceUSD: ounce,
//            localGramPrice24: Double(buySilverPrice) ?? 0.0
//        )) ?? 0.0)) ?? 0.0) - (Double(Dollar) ?? 0.0)
//        gapvalueLabel.text = "\(trimNumber(number: gapPrice))"
//        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
//            self.OunceBG.backgroundColor = .white
//            self.dollarBG.backgroundColor = .white
//        }


       
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
