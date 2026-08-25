//
//  FAQVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 23/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Model
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - View999
struct FAQVCSWIFTUI: View {
    @Environment(\.dismiss) var dismiss
    @State private var expandedIndex: Int? = nil
    @ObservedObject private var viewModel: FAQViewModel
    
    init(viewModel: FAQViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
       
            
            VStack(spacing: 16) {

                // MARK: Header
                headerView(title: "FAQ".localized, isBackShow: true) {
                    dismiss()
                }

                // MARK: List
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(viewModel.ModelFAQ.enumerated(), id: \.offset) { index, item in
                            FAQCard(
                                item: item,
                                isExpanded: expandedIndex == index,
                                onTap: {
                                    withAnimation(.spring()) {
                                        expandedIndex = expandedIndex == index ? nil : index
                                    }
                                }
                            )
                        }
                    }
                   
                    
                }.padding(20)
            }.background(BGSwiftUIView())
            
           
        
    }
}

class headerViewUIKit: UIHostingController<headerView> {
  var titleLabel: String = ""
    var isBackShow: Bool = false
    var onTapBack: (() -> Void)?
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: headerView(title: titleLabel, isBackShow: isBackShow,onDismiss: onTapBack))
    }
}




// MARK: - Card
struct FAQCard: View {

    let item: FAQModel
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                // Question Icon
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color(hex: "#D8BE8A"))
               

                Text(item.question ?? "")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    
               Spacer()
                
                // Chevron
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(Color(hex: "#D8BE8A"))
               
            }
            .padding()
            .onTapGesture {
                onTap()
            }

            if isExpanded {
                Text(item.answer ?? "")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cornerRadius(16)
        .background(
            Color.black.opacity(0.4)
        )
        .cornerRadius(16)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#D8BE8A").opacity(0.5), lineWidth: 1)
        )
    }
}

