import SwiftUI
import CoreLocation


struct PlayerView: View {
    @State private var searchText = ""
    @State private var didLoad = false
    
    @State var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var shownItems: Set<String> = []
    
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.status {
                case .idle, .loading:
                    LoadingProgressView()
                    
                case .success:
                    if viewModel.filterEstablishments.isEmpty {
                        ContentUnavailableView {
                            Label("No hay establecimientos cerca de ti", systemImage: "mappin.slash.circle.fill")
                                .foregroundStyle(.primaryColorGreen)
                        } description: {
                            Text("Intenta buscar en otra ubicación o actualiza la búsqueda.")
                        } actions: {
                            CustomButtonView(title: "Intentar denuevo", color: .primaryColorGreen, textColor: .white) {
                                Task {
                                    do {
                                        try await viewModel.loadData()
                                        try await viewModel.getFavoritesUser()
                                        
                                        if !didLoad {
                                            shownItems = []
                                            didLoad = true
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                for establishment in viewModel.filterEstablishments {
                                                    shownItems.insert(establishment.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                Text("Todos")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                                if !viewModel.establishmentSearch.isEmpty {
                                    Text("Mostrando \(viewModel.filterEstablishments.count) resultados")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal)
                                }
                                
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(viewModel.filterEstablishments) { establishment in
                                        NavigationLink {
                                            EstablishmentDetailView(establishmentID: establishment.id)
                                        } label: {
                                            AnimatedAppearRow(item: establishment, shownItems: $shownItems, content: {
                                                PlayerEstablishmentGridItemView(establishment: establishment, viewModel: viewModel)
                                            })
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                        }
                        .refreshable {
                            do {
                                try await viewModel.loadData()
                                try await viewModel.getFavoritesUser()
                                shownItems = []
                                for establishment in viewModel.filterEstablishments {
                                    shownItems.insert(establishment.id)
                                }
                            } catch {
                                print("Error al refrescar: \(error)")
                            }
                        }
                        .scrollIndicators(.hidden)
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                    
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.primaryColorGreen)
                        Text("Error al cargar los establecimientos")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        CustomButtonView(title: "Intentar denuevo", color: .primaryColorGreen, textColor: .white) {
                            Task {
                                do {
                                    try await viewModel.loadData()
                                    try await viewModel.getFavoritesUser()
                                    
                                    if !didLoad {
                                        shownItems = []
                                        didLoad = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            for establishment in viewModel.filterEstablishments {
                                                shownItems.insert(establishment.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Establecimientos")
            .searchable(text: $viewModel.establishmentSearch)
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadData()
                        try await viewModel.getFavoritesUser()
                        
                        if !didLoad {
                            shownItems = []
                            didLoad = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                for establishment in viewModel.filterEstablishments {
                                    shownItems.insert(establishment.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PlayerView(viewModel: PlayerGetNearbyEstablishmentsViewModel())
}
