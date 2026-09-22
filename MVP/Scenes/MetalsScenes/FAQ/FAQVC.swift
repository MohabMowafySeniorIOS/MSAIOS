//
//  FAQVC.swift
//  MSA
//
//  Created by Mohab Mowafy on 14/04/2026.
//

import Foundation
import SwiftUI


struct FAQScreen: View {
    
    
    @ObservedObject private var viewModel: FAQViewModel
    
    init(viewModel: FAQViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
  
    @State private var rotation: Double = 0
    @State private var isLoading = true
    var body: some View {
        VStack {
            mainContent
            Spacer()
        }.background(
           BGSwiftUIView()
        )
       
        
    }
    
   
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.ModelFAQ,id: \.question) { item in
                    FAQRow(
                        item: item
                        
                    )
                    
                }
            }
            .padding([.top],16)
        }
        
    }
}

struct FAQRow: View {
    @State var item: FAQModel
    
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                Text(item.question ?? "")
                    .font(.body)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: item.isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .onTapGesture {
                item.togle()
            }
            
            if item.isExpanded {
                HStack {
                    Text(item.answer ?? "")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    Spacer()
                }
                
            }
        }.background(Color.white.opacity(0.08))
            .animation(.easeInOut(duration: 0.3), value: item.isExpanded)
            .cornerRadius(8)
            .padding(.horizontal)
        
    }
}

