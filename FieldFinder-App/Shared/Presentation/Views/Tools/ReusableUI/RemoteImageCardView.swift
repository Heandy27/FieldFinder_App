import SwiftUI

struct RemoteImageCardView: View {
    let url: URL?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var adaptiveHeight: CGFloat {
        horizontalSizeClass == .regular ? 400 : 240
    }
    
    var adaptiveWidth: CGFloat? {
        if horizontalSizeClass == .regular {
            // iPad: ancho completo
            return nil
        } else {
            // iPhone: 80% del ancho
            return UIScreen.main.bounds.width * 0.8
        }
    }
    
    var body: some View {
        Group {
            if let imageURL = url {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: adaptiveWidth, height: adaptiveHeight)
                            .frame(maxWidth: horizontalSizeClass == .regular ? .infinity : nil)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: adaptiveWidth, height: adaptiveHeight)
                            .frame(maxWidth: horizontalSizeClass == .regular ? .infinity : nil)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                    case .failure:
                        VStack {
                            Text("No se pudo cargar la foto")
                        }
                        .frame(width: adaptiveWidth, height: adaptiveHeight)
                        .frame(maxWidth: horizontalSizeClass == .regular ? .infinity : nil)
                        .foregroundStyle(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                VStack {
                    Text("No hay fotos disponibles")
                        .foregroundStyle(.black)
                }
                .frame(width: adaptiveWidth, height: adaptiveHeight)
                .frame(maxWidth: horizontalSizeClass == .regular ? .infinity : nil)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    RemoteImageCardView(url: URL(string: "https://fieldfinder-uploads.s3.us-east-2.amazonaws.com/cancha/6E1285EF-35F3-4A85-BC8B-689C1E001404-image0.jpg"))
}
