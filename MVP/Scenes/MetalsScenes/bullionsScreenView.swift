//
//  bullionsScreenView.swift
//  MSA
//
//  Created by Mohab Mowafy on 25/04/2026.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct MetalType {
    var id: String?
    var name: String?
    var type: String?
    
    
}

struct productGrames {
    var productName: String?
    
}

struct grameModel {
    let name: String?
    let count : Double?
    let cashBack : Double?
    let Manufacturing : Double?
    let manufacturingPrice: Double?
}

struct bullionsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMetal: MetalType?
    @State private var selectedCompany = ""
    @State private var selectedProductIndex: Int?
    @State private var selectedGrame: grameModel?
  
    @State var metalArr : [MetalType] = []
    @State var companiesArr : [String] = []
    @State var gramesArr : [grameModel] = []
    @State var imageName : String = "MSA"
    
    var body: some View {

        ZStack {
            
            BGSwiftUIView()
                

            VStack(spacing: 20) {
               
                headerView(title: "Billions".localized, isBackShow: false) {
                    dismiss()
                }.padding(.top,60)

                ScrollView {

                    productCard

                    if selectedGrame != nil {
                        priceGrid
                    }

                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .onAppear {
            getMetal()
        }
    }
    
    func getMetal() {
        
        let db = Firestore.firestore()
        
        db.collection("Billions")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.metalArr.removeAll()
                for doc in documents {
                    var type = doc.documentID as? String
                    let data = doc.data()
                   print(type)
                    var name = L102Language.currentAppleLanguage() == "en" ? ((data["name_en"] as? String) ?? "") : ((data["name_ar"] as? String) ?? "")
                    metalArr.append(MetalType(id: type, name: name,type: type))
                }
                
            }
        
    }
    
    func getCompanies(metalId: String) {
        
        let db = Firestore.firestore()
        
        db.collection("Billions")
            .document(metalId)
            .collection(metalId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.companiesArr.removeAll()
                for doc in documents {
                    var type = doc.documentID as? String
                    let data = doc.data()
                   print(type)
                    var companies = data["CompanyName"] as? [String]
                    if metalId != "Silver" {
                        companies?.swapAt(1, 4)
                    }
                   print(metalId)
                   
                    companiesArr = companies ?? []
                }
                
                
            }
        
    }
    
    func getgrames(metalId: String, company: String) {
        
        let db = Firestore.firestore()
        print(metalId,company)
        db.collection("Billions")
            .document(metalId)
            .collection(metalId)
            .document(metalId)
            .collection(company)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.gramesArr.removeAll()
                for doc in documents {
                    var type = doc.documentID as? String
                    let dataAll = doc.data() as? NSDictionary
                  
                    let data = dataAll?["gram"] as? NSArray
                    gramesArr.removeAll()
                    for item in data ?? [] {
                        let data = item as? NSDictionary
                        let names = L102Language.currentAppleLanguage() == "en" ? ((data?["name_en"] as? String) ?? "") : ((data?["name_ar"] as? String) ?? "")
                        let counts = (data?["count"] as? Double) ?? 0
                        let Manufacturing = (data?["Manufacturing"] as? Double) ?? 0.0
                        let cashBack = (data?["cashBack"] as? Double) ?? 0.0
                       
                        gramesArr.append(grameModel(name: names, count: counts,cashBack: cashBack, Manufacturing: Manufacturing,manufacturingPrice: Manufacturing*Double(counts)))
                    }
                  
                }
                
                
            }
        
    }
}



// MARK: - Product Card
extension bullionsScreenView {
    var productCard: some View {
        HStack {
           
            
            chooseViews
            
            if imageName.count > 0 {
                Image(imageName) // حط صورتك
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
            
        }
        .padding()
            .background(.black.opacity(0.4))
            .cornerRadius(12)
        
            
    }
    
    var chooseViews: some View {
        VStack(spacing: 15) {
    
            Menu {
                ForEach(metalArr, id: \.id) { metal in
                    Button(metal.name ?? "") {
                        selectedMetal = metal
                        selectedCompany = ""
                        imageName = "MSA"
                        selectedGrame = nil
                        self.getCompanies(metalId: selectedMetal?.id ?? "")
                    }
                }
            } label: {
                label(title: "Karat".localized, value: selectedMetal?.name ?? "")
            }
            
            Menu {
               
                    ForEach(companiesArr, id: \.self) { company in
                        Button(company) {
                            selectedCompany = company
                            imageName = company
                            self.getgrames(metalId: selectedMetal?.id ?? "", company: selectedCompany)
                        }
                        
                    }
              
            } label: {
                
                label(title: "Manufacturer".localized, value: selectedCompany)
            }
            
            Menu {
               
                ForEach(gramesArr, id: \.name) { grame in
                        Button(grame.name ?? "") {
                            selectedGrame = grame
                        }
                        
                    }
                
                
            } label: {
                label(title: "المنتج", value: selectedGrame?.name ?? "")
            }
            
        }
       

    }
    
    func label(title: String, value: String) -> some View {
        VStack {
            HStack {
                if value.count > 0 {
                    Text(value)
                        .foregroundColor(.white)
                }else {
                    Text(title)
                        .foregroundColor(.white)
                }
               
               
                Spacer()
                Image("arrow-down")
               
            }
            
           
        }
      
        .padding()
        .background(.black.opacity(0.4))
        .cornerRadius(12)
    }
}

// MARK: - Price Grid
extension bullionsScreenView {
    var priceGrid: some View {
        LazyVStack(spacing: 15) {
            
            let gramSalePrice = handleGramePrice().gramSalePrice
            let gramBuyPrice =  handleGramePrice().gramBuyPrice
        
            let total = ((selectedGrame?.Manufacturing ?? 0.0) + gramSalePrice)
            let count = Double((selectedGrame?.count ?? 0))
            let cashBack = ((selectedGrame?.cashBack ?? 0.0))
            let resale = ((selectedGrame?.cashBack ?? 0.0) + gramBuyPrice)
            
            Text("Important note: The manufacturing costs listed are the lowest according to the latest update from the producing company. The price per gram of gold is updated according to the latest price in the gold market and is not derived from the producing company.".localized)
                .bold()
                .foregroundColor(.white)
            priceCard(title: "Price per gram".localized, value: "\(gramSalePrice)")
            priceCard(title: "Manufacturing".localized, value: "\((selectedGrame?.Manufacturing ?? 0.0))")
           
            priceCard(title: "Total".localized, value: "\(round(total*count))")
            priceCard(title: "Cash Back".localized, value: "\(cashBack)")
           
            priceCard(title: "Resale".localized, value: "\(round(resale * count))")
        }
    }
    
   
    func handleGramePrice() -> (gramSalePrice:Double,gramBuyPrice:Double) {
        var gramSalePrice = (Double(metalPriceValue.goldPrice?.salePrice ?? "0.0") ?? 0.0)
        var gramBuyPrice = (Double(metalPriceValue.goldPrice?.buyPrice ?? "0.0") ?? 0.0)
        
        if selectedMetal?.type == "Karat24" {
            gramSalePrice = gramSalePrice * 24 / 21
            gramBuyPrice = gramBuyPrice * 24 / 21
        }else if  selectedMetal?.type == "Silver" {
            gramSalePrice = (Double(metalPriceValue.silverPrice?.salePrice ?? "0.0") ?? 0.0)
            gramBuyPrice = (Double(metalPriceValue.silverPrice?.buyPrice ?? "0.0") ?? 0.0)
        }
        print(trimNumber(number: gramSalePrice),trimNumber(number: gramBuyPrice))
        
        
        return (trimNumber(number: gramSalePrice),trimNumber(number: gramBuyPrice))
    }
    
    func trimNumber(number: Double) -> Double {
        let formatted = String(format: "%.2f", number)
        return round(number)
    }
    
    
    func priceCard(title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .bold()
                .foregroundColor(.white)
            Spacer()
            Text("\(value) " + "Pound".localized)
                .bold()
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(glowCard)
    }
}

// MARK: - Styles
extension bullionsScreenView {
    
    
    var glass: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.4))
            .background(.ultraThinMaterial)
    }
    
    var glowCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.yellow.opacity(0.3), radius: 10)
    }
}

