//
//  ImageCard.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 25/09/2023.
//

import SwiftUI

struct ImageCard: View {
    var image: UIImage
    var title: String
    var accuracy: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 16.0) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 260, maxHeight: 300)
            
            cardText
                .padding(.horizontal, 0)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24.0))
        .shadow(radius: 8.0)
    }
    
    var cardText: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                
           Spacer()
            
            HStack(spacing: 4.0) {
                Image(systemName: "hands.and.sparkles")
                Text(accuracy)
            }
            .foregroundColor(.gray)
        }
        .frame(maxWidth: 220, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 32.0) {
            ImageCard(image: UIImage(named: "taylor2")!, title: "Evening Dance, when probable is Taylor Swift and this is not being accurate at all.", accuracy: "0.49591")
            ImageCard(image: UIImage(named: "mustang1")!, title: "Sports Car, Sport Car, Super Sport Car", accuracy: "0.49591")
            ImageCard(image: UIImage(named: "mustang1")!, title: "Sports Car, Sport Car, Super Sport Car", accuracy: "0.49591")
        }
    }
}
