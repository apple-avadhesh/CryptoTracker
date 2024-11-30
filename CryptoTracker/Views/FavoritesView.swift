import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: CryptoViewModel
    @State private var searchText = ""
    
    var filteredFavorites: [Cryptocurrency] {
        if searchText.isEmpty {
            return viewModel.favoriteCryptos
        } else {
            return viewModel.favoriteCryptos.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if filteredFavorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.yellow)
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add cryptocurrencies to your favorites\nto track them here")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredFavorites) { crypto in
                                HStack(spacing: 0) {
                                    NoArrowNavigationLink(destination: CryptoDetailView(cryptocurrency: crypto, viewModel: viewModel)) {
                                        CryptoRowContent(cryptocurrency: crypto)
                                            .contentShape(Rectangle())
                                    }
                                    
                                    FavoriteButton(
                                        isFavorite: viewModel.isFavorite(crypto.id),
                                        action: { viewModel.toggleFavorite(for: crypto.id) }
                                    )
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Favorites")
            .searchable(text: $searchText, prompt: "Search favorites")
        }
    }
}
