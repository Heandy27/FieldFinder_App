import Foundation
import Combine
import StoreKit

@Observable
final class AppState {
    // Published
    var status = StatusModel.login
    var tokenJWT: String = ""
    
    var userRole: UserRole? {
        didSet {
            // 🔒 Guarda el valor en UserDefaults cuando cambia
            if let role = userRole {
                defaults.set(role.rawValue, forKey: "userRole")
            } else {
                defaults.removeObject(forKey: "userRole")
            }
        }
    }
    
    var userID: String? {
        didSet {
            // 🔒 Guarda el valor en UserDefaults cuando cambia
            if let id = userID {
                defaults.set(id, forKey: "userID")
            } else {
                defaults.removeObject(forKey: "userID")
            }
        }
    }
    
    var messageAlert: String = ""
    var showAlert: Bool = false
    var isLoading: Bool = false
    var selectedEstablishmentID: String?
    
    // No Published
    @ObservationIgnored
    var isLogged: Bool = false
    
    private var storeTask: Task<Void, Never>?
    
    /// The StoreKit products we've loaded for the store.
    var products = [Product]()
    let defaults: UserDefaults
    
    @ObservationIgnored
    private var loginUseCase: UserAuthServiceUseCaseProtocol
    
    init(loginUseCase: UserAuthServiceUseCaseProtocol = UserAuthServiceUseCase(), defaults: UserDefaults = .standard) {
        self.loginUseCase = loginUseCase
        self.defaults = defaults
        
        // ✅ Recupera userRole y userID al iniciar la app
        if let savedRole = defaults.string(forKey: "userRole"),
           let role = UserRole(rawValue: savedRole) {
            self.userRole = role
        }
        self.userID = defaults.string(forKey: "userID")
        
        Task {
            await validateToken()
        }
        
        storeTask = Task {
            await monitorTransactions()
        }
    }
    
    @MainActor
    func login(email: String, password: String) async throws {
        guard !email.isEmpty || !password.isEmpty else {
            messageAlert = "Los campos son requeridos."
            showAlert = true
            return
        }

        do {
            isLoading = true
            let loginApp = try await loginUseCase.login(email: email, password: password)
            
            if loginApp == true {
                self.status = .loading
                
                let user = try await UserProfileServiceUseCase().fetchUser()
                self.userID = user.id
                self.userRole = user.userRole
                
                self.status = .loaded
                self.isLoading = false
            } else {
                showAlert = true
                messageAlert = "El email o la contraseña son inválidos."
                isLoading = false
                status = .error(error: "¡Ups! Algo salió mal")
            }
        } catch {
            print("Error al iniciar sesión. \(error.localizedDescription)")
        }
        showAlert = false
    }
    
    @MainActor
    func closeSessionUser() {
        Task {
            try await loginUseCase.logout()
            self.status = .login
            
            // 💥 Limpia los datos guardados al cerrar sesión
            self.userRole = nil
            self.userID = nil
        }
    }
    
    @MainActor
    func validateToken() async {
        Task {
            if (await loginUseCase.validateToken() == true) {
                let user = try await UserProfileServiceUseCase().fetchUser()
                self.userRole = user.userRole
                self.userID = user.id
                self.status = .loaded
            } else {
                self.status = .login
                NSLog("Login Error")
            }
        }
    }
    
    /// Detectar si está suscrito o en prueba gratuita
    @MainActor
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            print("🔁 Verificando estado de suscripción...")
            if case .verified(let transaction) = result,
               transaction.productID == Self.unlockPremiumProductID {
                print("📦 Producto: \(transaction.productID)")
                print("🔒 Activa: \(transaction.revocationDate == nil)")
                print("🧪 Free Trial: \(transaction.offer?.type == .introductory)")
                fullVersionUnlocked = transaction.revocationDate == nil
                isOnFreeTrial = transaction.offer?.type == .introductory
                return
            }
        }
        
        fullVersionUnlocked = false
        isOnFreeTrial = false
    }
    
    @MainActor
    func requestReviewIfAppropriate() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        AppStore.requestReview(in: scene)
    }
}
