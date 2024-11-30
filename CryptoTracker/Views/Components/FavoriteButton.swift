import SwiftUI

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void
    let size: CGFloat
    
    init(isFavorite: Bool, size: CGFloat = 20, action: @escaping () -> Void) {
        self.isFavorite = isFavorite
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : .gray)
                .font(.system(size: size))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
