//
//  StoreView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 27/5/25.
//

import StoreKit
import SwiftUI

struct StoreView: View {
    
    enum LoadState {
        case loading, loaded, error
    }
    
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var loadState = LoadState.loading
    @State private var showingPurchaseError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack {
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()
                    
                    Text("¡Actualiza hoy!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    
                    Text("Aprovecha al máximo nuestra app")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.blue.gradient)
                
                ScrollView {
                    VStack {
                        switch loadState {
                        case .loading:
                            Text("Obteniendo ofertas...")
                                .font(.title2.bold())
                                .padding(.top, 50)
                            
                            ProgressView()
                                .controlSize(.large)
                        case .loaded:
                            ForEach(appState.products) { product in
                                VStack(alignment: .leading) {
                                    Button {
                                        purchase(product)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(product.displayName)
                                                    .font(.title2.bold())
                                                
                                                Text(product.description)
                                            }
                                            Spacer()
                                            
                                            Text(product.displayPrice)
                                                .font(.title)
                                                .fontDesign(.rounded)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                                        .contentShape(.rect)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            

                        case .error:
                            Text("Lo sentimos, hubo un error cargando nuestra tienda.")
                                .padding(.top, 50)
                            
                            Button("Intentar denuevo") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                }
                Button("Restaurar compras", action: restore)
                
                Button("Cancel") {
                    dismiss()
                }
                .padding(.top, 20)
            }
        }
        .alert("In-app Compras estan desabilitadas", isPresented: $showingPurchaseError) {
        } message: {
            Text("""
                No puedes comprar el desbloqueo Premium porque las compras dentro de la app están deshabilitadas en este dispositivo. 
                Por favor, consulta con quien administre tu dispositivo para obtener asistencia.
                """)
        }
        .onChange(of: appState.fullVersionUnlocked) { oldValue, newValue in
            checkForPurchase()
        }
        .task {
            await load()
        }
    }
    
    func checkForPurchase() {
        if appState.fullVersionUnlocked {
            dismiss()
        }
    }
    
    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            showingPurchaseError.toggle()
            return
        }
        
        Task { @MainActor in
            try await appState.purchase(product)
        }
    }
    
    func load() async {
        loadState = .loading
        do {
            try await appState.loadProducts()
            
            if appState.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
    
    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
}

#Preview {
    StoreView()
        .environment(AppState())
}
