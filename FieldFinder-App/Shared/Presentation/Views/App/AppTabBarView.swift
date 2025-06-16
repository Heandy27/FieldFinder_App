//
//  AppTabBarView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 9/5/25.
//
import SwiftUI

struct AppTabBarView: View {
    
    @State private var tabSelection: TabBarItem = .home
    @StateObject private var viewModel = PlayerGetNearbyEstablishmentsViewModel()
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemGroupedBackground

        // Deseleccionado: ícono y texto gris
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray
        ]

        // Seleccionado: ícono y texto verde
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryColorGreen)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryColorGreen) 
        ]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }


    
    var body: some View {
        TabView(selection: $tabSelection) {
           
            Tab("Inicio", systemImage: "house.fill", value: tabSelection) {
                PlayerView(viewModel: viewModel)
            }
            
            
            Tab("Mapa", systemImage: "map.fill", value: tabSelection) {
                MapEstablishmentsView()
            }
            
            Tab("Perfil", systemImage: "person.fill", value: tabSelection) {
                DefaultProfile()
            }
            
        }
        .tint(.primaryColorGreen)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    AppTabBarView()
        .environment(AppState())
}
