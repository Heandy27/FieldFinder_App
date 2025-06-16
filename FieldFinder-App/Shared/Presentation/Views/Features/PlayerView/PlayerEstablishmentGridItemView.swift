//
//  EstablishmentRowView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import SwiftUI

struct PlayerEstablishmentGridItemView: View {
    
    let establishment: EstablishmentResponse
    
    @State private var animateFavorite = false
    
    @State var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var isFavorite: Bool
    @State var viewModelUser = ProfileUserViewModel()

    init(establishment: EstablishmentResponse, viewModel: PlayerGetNearbyEstablishmentsViewModel = PlayerGetNearbyEstablishmentsViewModel()) {

        self.establishment = establishment
        self.viewModel = viewModel
        _isFavorite = State(initialValue: viewModel.isFavorite(establishmentId: establishment.id))
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RemoteImageCardView(url: establishment.photoEstablishment.first)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)
                    
                
                if case .success(let user) = viewModelUser.status, user.rol == "jugador" {
                    
                    FavoriteButton(isFavorite: $isFavorite ) { newValue in
                        Task {
                            isFavorite = newValue
                            try await viewModel.toggleFavorite(establishmentId: establishment.id, isFavorite: newValue)
                            try await viewModel.getFavoritesUser()
                            await MainActor.run {
                                isFavorite = viewModel.isFavorite(establishmentId: establishment.id)
                            }
                        }
                        
                    }
                    .padding(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(establishment.name)
                    .font(.headline)
                    .foregroundStyle(.primaryColorGreen)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(.primaryColorGreen)
                    Text(establishment.address)
                        .font(.subheadline)
                        .foregroundStyle(Color.colorBlack)
                        .lineLimit(2)
                }
            }
            
            .padding(.horizontal, 4)
            
        }
        .frame(maxWidth: .infinity)
        .onChange(of: viewModel.favoritesData) { _, _ in
            isFavorite = viewModel.isFavorite(establishmentId: establishment.id)
        }
        .onAppear {
            Task {
                isFavorite = viewModel.isFavorite(establishmentId: establishment.id)
                try await viewModelUser.getMe()
            }
        }
        .padding()
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .padding(.horizontal)
        
    }
}

#Preview {
    PlayerEstablishmentGridItemView(establishment: .sample, viewModel: PlayerGetNearbyEstablishmentsViewModel())
}



