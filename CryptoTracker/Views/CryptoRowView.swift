import SwiftUI

struct CryptoRowView: View {
    let cryptocurrency: Cryptocurrency
    @ObservedObject var viewModel: CryptoViewModel
    @State private var showingPredictionSheet = false
    
    var body: some View {
        Button(action: {
            showingPredictionSheet = true
        }) {
            ZStack(alignment: .topLeading) {
                // Main Content
                HStack(spacing: 12) {
                    // Crypto Icon
                    AsyncImage(url: URL(string: cryptocurrency.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 40, height: 40)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                        case .failure:
                            Image(systemName: "questionmark.circle")
                                .frame(width: 40, height: 40)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 40, height: 40)
                    
                    // Crypto Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cryptocurrency.name)
                            .font(.headline)
                        Text(cryptocurrency.symbol.uppercased())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Price Info
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(cryptocurrency.formattedCurrentPrice)
                            .font(.headline)
                        
                        HStack(spacing: 2) {
                            Image(systemName: cryptocurrency.isPriceChangePositive ? "arrow.up.right" : "arrow.down.right")
                            Text(cryptocurrency.formattedPriceChange)
                        }
                        .font(.subheadline)
                        .foregroundColor(cryptocurrency.isPriceChangePositive ? .green : .red)
                    }
                    
                    // Favorite Button
                    Button(action: {
                        viewModel.toggleFavorite(for: cryptocurrency.id)
                    }) {
                        Image(systemName: viewModel.isFavorite(cryptocurrency.id) ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavorite(cryptocurrency.id) ? .yellow : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Rank Badge
                if let rank = cryptocurrency.marketCapRank {
                    Text("#\(rank)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                        .padding(4)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showingPredictionSheet) {
            NavigationView {
                AddPredictionView(viewModel: viewModel, crypto: cryptocurrency)
            }
        }
    }
}
