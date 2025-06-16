import Foundation


@Observable
final class RegisterFieldViewModel {
    
    var isLoading = false
    var alertMessage: String?
    var shouldDismissAfterAlert: Bool = false
    
    @ObservationIgnored
    let useCase: FieldServiceUseCaseProtocol
    
    init(useCase: FieldServiceUseCaseProtocol = FieldServiceUseCase()) {
        self.useCase = useCase
    }
    

    func registerCancha(_ canchaModel: FieldRequest, images: [Data], establishmentID: String) async {

        
        isLoading = true
        
        guard (canchaModel.precio != 0) else {
            alertMessage = "El campo precio es obligatorio"
            
            isLoading = false
            return
        }
        
        guard !images.isEmpty else {
            alertMessage = "Es obligatorio subir imágenes"
            
            isLoading = false
            return
        }
        
        
        do {
            let canchaID = try await useCase.createField(canchaModel, establishmentID: "")
            try await useCase.uploadFieldImages(fieldID: canchaID, images: images)
            
            alertMessage = "Cancha registrada con éxito"
            shouldDismissAfterAlert = true
            isLoading = false
        } catch {
            alertMessage = "Error al registrar la cancha"
            isLoading = false

        }
    }
    @MainActor
    func editCancha(canchaID: String, canchaModel: FieldRequest) async throws {
        do {
            let _ = try await useCase.updateField(fieldID: canchaID, fieldModel: canchaModel)
            alertMessage = "La cancha se ha actualizado correctamente."
        } catch {
            alertMessage = "Ocurrió un error al actualizar la cancha. Intenta nuevamente."
        }
        
    }
    @MainActor
    func deleteCancha(canchaID: String) async throws {
        do {
            let _ = try await useCase.deleteField(fieldID: canchaID)
            alertMessage = "La cancha se ha eliminado correctamente."
            print("Se elimino exitosamente")
        }
    }
    @MainActor
    func localCurrencySymbol() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.currencySymbol ?? "$"
    }
}
