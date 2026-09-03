//
//  bullionsScreenView.swift
//  MSA
//
//  Created by Mohab Mowafy on 25/04/2026.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Models

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
    let count: Double?
    let cashBack: Double?
    let Manufacturing: Double?
    let manufacturingPrice: Double?
}

// MARK: - Popup Type

enum BullionSelectionType: String, Identifiable {
    
    case metal
    case company
    case product
    
    var id: String {
        rawValue
    }
}

// MARK: - Bullions Screen

struct bullionsScreenView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Selected Values
    
    @State private var showSelectionAlert = false
    @State private var selectionAlertMessage = ""
    
    @State private var selectedMetal: MetalType?
    @State private var selectedCompany = ""
    @State private var selectedGrame: grameModel?
    
    // MARK: - Firebase Data
    
    @State private var metalArr: [MetalType] = []
    @State private var companiesArr: [String] = []
    @State private var gramesArr: [grameModel] = []
    
    // MARK: - UI
    
    @State private var imageName = "MSA"
    @State private var activeSelection: BullionSelectionType?
    
    var body: some View {
        
        ZStack {
            
            // MARK: Background
            
            BGSwiftUIView()
            
            // MARK: Main Content
            
            VStack(spacing: 20) {
                
                headerView(
                    title: "Billions".localized,
                    isBackShow: false
                ) {
                    dismiss()
                }
                .padding(.top, 60)
                
                ScrollView {
                    
                    productCard
                    
                    if selectedGrame != nil {
                        priceGrid
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            // MARK: Center Popup
            
            if let activeSelection = activeSelection {
                
                // Dark overlay
                Color.black
                    .opacity(0.58)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        
                        withAnimation(
                            .easeInOut(duration: 0.2)
                        ) {
                            self.activeSelection = nil
                        }
                    }
                
                // Popup
                bullionSelectionPopup(
                    type: activeSelection
                )
                .padding(.horizontal, 40)
                .transition(
                    .scale(scale: 0.92)
                    .combined(with: .opacity)
                )
                .zIndex(100)
            }
        }
        .animation(
            .easeInOut(duration: 0.2),
            value: activeSelection
        )
        .onAppear {
            getMetal()
        }
        .alert(
            "Alert".localized,
            isPresented: $showSelectionAlert
        ) {
            Button("Ok".localized, role: .cancel) {}
        } message: {
            Text(selectionAlertMessage)
        }
    }
}

// MARK: - Firebase

extension bullionsScreenView {
    
    // MARK: Get Metals
    
    func getMetal() {
        
        let db = Firestore.firestore()
        
        db.collection("Billions")
            .addSnapshotListener { snapshot, error in
                
                guard error == nil else {
                    print(
                        "Firebase Error:",
                        error?.localizedDescription ?? ""
                    )
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.metalArr.removeAll()
                    
                    for doc in documents {
                        
                        let type = doc.documentID
                        let data = doc.data()
                        
                        let name =
                        L102Language.currentAppleLanguage() == "en"
                        ? ((data["name_en"] as? String) ?? "")
                        : ((data["name_ar"] as? String) ?? "")
                        
                        self.metalArr.append(
                            MetalType(
                                id: type,
                                name: name,
                                type: type
                            )
                        )
                    }
                }
            }
    }
    
    // MARK: Get Companies
    
    func getCompanies(metalId: String) {
        
        let db = Firestore.firestore()
        
        db.collection("Billions")
            .document(metalId)
            .collection(metalId)
            .addSnapshotListener { snapshot, error in
                
                guard error == nil else {
                    print(
                        "Firebase Error:",
                        error?.localizedDescription ?? ""
                    )
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.companiesArr.removeAll()
                    
                    for doc in documents {
                        
                        let data = doc.data()
                        
                        var companies =
                            data["CompanyName"] as? [String]
                        
                        // Same logic as your original code
                        if metalId != "Silver",
                           let count = companies?.count,
                           count > 4 {
                            
                            companies?.swapAt(1, 4)
                        }
                        
                        self.companiesArr =
                            companies ?? []
                    }
                }
            }
    }
    
    // MARK: Get Grams
    
    func getgrames(
        metalId: String,
        company: String
    ) {
        
        let db = Firestore.firestore()
        
        print(
            "Getting grams:",
            metalId,
            company
        )
        
        db.collection("Billions")
            .document(metalId)
            .collection(metalId)
            .document(metalId)
            .collection(company)
            .addSnapshotListener { snapshot, error in
                
                guard error == nil else {
                    print(
                        "Firebase Error:",
                        error?.localizedDescription ?? ""
                    )
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.gramesArr.removeAll()
                    
                    for doc in documents {
                        
                        let dataAll = doc.data()
                        
                        let data =
                            dataAll["gram"]
                            as? [[String: Any]]
                        
                        for item in data ?? [] {
                            
                            let name =
                            L102Language.currentAppleLanguage() == "en"
                            ? ((item["name_en"] as? String) ?? "")
                            : ((item["name_ar"] as? String) ?? "")
                            
                            let count =
                                (item["count"] as? Double) ?? 0
                            
                            let manufacturing =
                                (item["Manufacturing"] as? Double) ?? 0
                            
                            let cashBack =
                                (item["cashBack"] as? Double) ?? 0
                            
                            self.gramesArr.append(
                                grameModel(
                                    name: name,
                                    count: count,
                                    cashBack: cashBack,
                                    Manufacturing: manufacturing,
                                    manufacturingPrice:
                                        manufacturing * count
                                )
                            )
                        }
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
            
            if !imageName.isEmpty {
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 80,
                        height: 80
                    )
            }
        }
        .padding()
        .background(
            Color.black.opacity(0.4)
        )
        .cornerRadius(12)
    }
    
    // MARK: Select Views
    
    var chooseViews: some View {

        VStack(spacing: 15) {

            // MARK: - 1. Karat

            Button {

                guard !metalArr.isEmpty else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.2)) {
                    activeSelection = .metal
                }

            } label: {

                label(
                    title: "Karat".localized,
                    value: selectedMetal?.name ?? ""
                )
            }

            // MARK: - 2. Manufacturer

            Button {

                // لازم العيار يتحدد الأول
                guard selectedMetal != nil else {

                    selectionAlertMessage =
                    "You must select the karat first.".localized

                    showSelectionAlert = true

                    return
                }

                // نستنى بيانات الشركات من Firebase
                guard !companiesArr.isEmpty else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.2)) {
                    activeSelection = .company
                }

            } label: {

                label(
                    title: "Manufacturer".localized,
                    value: selectedCompany
                )
            }

            // MARK: - 3. Product

            Button {

                // لازم العيار يتحدد الأول
                guard selectedMetal != nil else {

                    selectionAlertMessage =
                    "You must select the karat first.".localized

                    showSelectionAlert = true

                    return
                }

                // لازم الشركة تتحدد الأول
                guard !selectedCompany.isEmpty else {

                    selectionAlertMessage =
                    "You must select the manufacturer first.".localized

                    showSelectionAlert = true

                    return
                }

                // نستنى بيانات المنتجات من Firebase
                guard !gramesArr.isEmpty else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.2)) {
                    activeSelection = .product
                }

            } label: {

                label(
                    title: "Product".localized,
                    value: selectedGrame?.name ?? ""
                )
            }
        }
    }
    
    // MARK: Select Label
    
    func label(
        title: String,
        value: String
    ) -> some View {
        
        HStack {
            
            Text(
                value.isEmpty
                ? title
                : value
            )
            .foregroundColor(.white)
            .font(
                .system(
                    size: 15,
                    weight: .medium
                )
            )
            .lineLimit(1)
            
            Spacer()
            
            Image("down-White-Arrow")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 16,
                    height: 16
                )
        }
        .padding()
        .background(
            Color.black.opacity(0.4)
        )
        .cornerRadius(12)
    }
}

// MARK: - Center Popup

extension bullionsScreenView {
    
    @ViewBuilder
    func bullionSelectionPopup(
        type: BullionSelectionType
    ) -> some View {
        
        VStack(spacing: 0) {
            
            // MARK: Popup Title
            
            Text(
                popupTitle(type)
            )
            .font(
                .system(
                    size: 22,
                    weight: .medium
                )
            )
            .foregroundColor(.black)
            .frame(
                height: 62
            )
            .background(Color.white)
            
            Divider()
            
            // MARK: Options
            
            ScrollView(
                showsIndicators: false
            ) {
                
                LazyVStack(spacing: 0) {
                    
                    switch type {
                        
                    // MARK: Metals
                        
                    case .metal:
                        
                        ForEach(
                            metalArr,
                            id: \.id
                        ) { metal in
                            
                            popupRow(
                                title:
                                    metal.name ?? "",
                                isSelected:
                                    selectedMetal?.id
                                    == metal.id
                            ) {
                                
                                selectedMetal = metal
                                
                                // Reset dependent data
                                selectedCompany = ""
                                selectedGrame = nil
                                companiesArr.removeAll()
                                gramesArr.removeAll()
                                
                                imageName = "MSA"
                                
                                // Close
                                closePopup()
                                
                                // Load companies
                                getCompanies(
                                    metalId:
                                        metal.id ?? ""
                                )
                            }
                        }
                        
                    // MARK: Companies
                        
                    case .company:
                        
                        ForEach(
                            companiesArr,
                            id: \.self
                        ) { company in
                            
                            popupRow(
                                title: company,
                                isSelected:
                                    selectedCompany
                                    == company
                            ) {
                                
                                selectedCompany =
                                    company
                                
                                selectedGrame = nil
                                gramesArr.removeAll()
                                
                                imageName = company
                                
                                // Close
                                closePopup()
                                
                                // Load products
                                getgrames(
                                    metalId:
                                        selectedMetal?.id
                                        ?? "",
                                    company:
                                        company
                                )
                            }
                        }
                        
                    // MARK: Products
                        
                    case .product:
                        
                        ForEach(
                            gramesArr,
                            id: \.name
                        ) { grame in
                            
                            popupRow(
                                title:
                                    grame.name ?? "",
                                isSelected:
                                    selectedGrame?.name
                                    == grame.name
                            ) {
                                
                                selectedGrame =
                                    grame
                                
                                closePopup()
                            }
                        }
                    }
                }
            }
        }
        // MARK: Popup Width
        
        .frame(
            maxWidth: 620
        )
        
        // MARK: Popup Height
        
        .frame(
            maxHeight: 310
        )
        
        // MARK: White Background
        
        .background(
            Color.white
        )
        
        // MARK: Rounded Corners
        
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        
        // MARK: Shadow
        
        .shadow(
            color: .black.opacity(0.35),
            radius: 25,
            x: 0,
            y: 12
        )
    }
    
    // MARK: Popup Row
    
    func popupRow(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        
        Button {
            onTap()
        } label: {
            
            HStack {
                
                Spacer()
                
                Text(title)
                    .font(
                        .system(
                            size: 20,
                            weight: .regular
                        )
                    )
                    .foregroundColor(.black)
                    .multilineTextAlignment(
                        .center
                    )
                
                Spacer()
            }
            .frame(
                height: 70
            )
            .background(
                Color.white
            )
            .overlay(
                Rectangle()
                    .fill(
                        Color.gray.opacity(0.22)
                    )
                    .frame(height: 1),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Popup Title
    
    func popupTitle(
        _ type: BullionSelectionType
    ) -> String {
        
        switch type {
            
        case .metal:
            return "Karat".localized
            
        case .company:
            return "Manufacturer".localized
            
        case .product:
            return "المنتج".localized
        }
    }
    
    // MARK: Close Popup
    
    func closePopup() {
        
        withAnimation(
            .easeInOut(duration: 0.2)
        ) {
            activeSelection = nil
        }
    }
}

// MARK: - Price Grid

extension bullionsScreenView {
    
    var priceGrid: some View {
        
        LazyVStack(spacing: 15) {
            
            let prices =
                handleGramePrice()
            
            let gramSalePrice =
                prices.gramSalePrice
            
            let gramBuyPrice =
                prices.gramBuyPrice
            
            let total =
                (
                    (selectedGrame?.Manufacturing ?? 0.0)
                    + gramSalePrice
                )
            
            let count =
                Double(
                    selectedGrame?.count ?? 0
                )
            
            let cashBack =
                selectedGrame?.cashBack ?? 0.0
            
            let resale =
                cashBack + gramBuyPrice
            
            Text(
                "Important note: The manufacturing costs listed are the lowest according to the latest update from the producing company. The price per gram of gold is updated according to the latest price in the gold market and is not derived from the producing company."
                    .localized
            )
            .bold()
            .foregroundColor(.white)
            
            priceCard(
                title: "Price per gram".localized,
                value:
                    "\(gramSalePrice)"
            )
            
            priceCard(
                title: "Manufacturing".localized,
                value:
                    "\(selectedGrame?.Manufacturing ?? 0.0)"
            )
            
            priceCard(
                title: "Total".localized,
                value:
                    "\(round(total * count))"
            )
            
            priceCard(
                title: "Cash Back".localized,
                value:
                    "\(cashBack)"
            )
            
            priceCard(
                title: "Resale".localized,
                value:
                    "\(round(resale * count))"
            )
        }
    }
    
    // MARK: Handle Price
    
    func handleGramePrice()
    -> (
        gramSalePrice: Double,
        gramBuyPrice: Double
    ) {
        
        var gramSalePrice =
            Double(
                metalPriceValue
                    .goldPrice?
                    .salePrice ?? "0.0"
            ) ?? 0.0
        
        var gramBuyPrice =
            Double(
                metalPriceValue
                    .goldPrice?
                    .buyPrice ?? "0.0"
            ) ?? 0.0
        
        if selectedMetal?.type == "Karat24" {
            
            gramSalePrice =
                gramSalePrice * 24 / 21
            
            gramBuyPrice =
                gramBuyPrice * 24 / 21
            
        } else if selectedMetal?.type == "Silver" {
            
            gramSalePrice =
                Double(
                    metalPriceValue
                        .silverPrice?
                        .salePrice ?? "0.0"
                ) ?? 0.0
            
            gramBuyPrice =
                Double(
                    metalPriceValue
                        .silverPrice?
                        .buyPrice ?? "0.0"
                ) ?? 0.0
        }
        
        return (
            trimNumber(
                number: gramSalePrice
            ),
            trimNumber(
                number: gramBuyPrice
            )
        )
    }
    
    func trimNumber(
        number: Double
    ) -> Double {
        
        return round(number)
    }
    
    // MARK: Price Card
    
    func priceCard(
        title: String,
        value: String
    ) -> some View {
        
        HStack(spacing: 10) {
            
            Text(title)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            Text(
                "\(value) "
                + "Pound".localized
            )
            .bold()
            .foregroundColor(.white)
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            minHeight: 40
        )
        .background(glowCard)
    }
}

// MARK: - Styles

extension bullionsScreenView {
    
    var glass: some View {
        
        RoundedRectangle(
            cornerRadius: 20
        )
        .fill(
            Color.black.opacity(0.4)
        )
        .background(
            .ultraThinMaterial
        )
    }
    
    var glowCard: some View {
        
        RoundedRectangle(
            cornerRadius: 20
        )
        .fill(
            Color.black.opacity(0.4)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20
            )
            .stroke(
                Color.yellow.opacity(0.3),
                lineWidth: 1
            )
        )
        .shadow(
            color:
                Color.yellow.opacity(0.3),
            radius: 10
        )
    }
}
