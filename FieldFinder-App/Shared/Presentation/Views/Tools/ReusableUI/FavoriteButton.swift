//
//  FavoriteButton.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//
import SwiftUI

struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    var onToggle: ((Bool) -> Void)? = nil
    @State private var animate = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isFavorite.toggle()
                animate = true
                onToggle?(isFavorite)
            }
            // Reinicia la animación después de un breve retraso
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animate = false
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 24))
                .foregroundStyle(.red)
                .padding(8)
                .background(Color.white)
                .clipShape(Circle())
                .scaleEffect(animate ? 1.1 : 1.0)
        }
    }
}
