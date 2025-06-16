//
//  AnimatedAppearRow.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 16/5/25.
//

import SwiftUI

/// Vista reutilizable que anima la aparición de un ítem cuando entra en pantalla.
struct AnimatedAppearRow<Item: Identifiable, Content: View>: View {
    let item: Item
    @Binding var shownItems: Set<Item.ID>
    let content: () -> Content

    var body: some View {
        let isShown = shownItems.contains(item.id)

        content()
            .opacity(isShown ? 1 : 1) // Usa 0.01 para evitar glitches de layout
            .offset(y: isShown ? 0 : 15)
            .animation(.easeOut(duration: 0.35), value: isShown)
            .onAppear {
                guard !shownItems.contains(item.id) else { return }
                shownItems.insert(item.id)
            }
    }
}
