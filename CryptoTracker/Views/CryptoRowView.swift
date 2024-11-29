import SwiftUI

struct CryptoRowView: View {
    let cryptocurrency: Cryptocurrency
    @ObservedObject var viewModel: CryptoViewModel
    @State private var showingPredictionSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Main Content Button
            Button(action: { showingPredictionSheet = true }) {
                HStack(spacing: 12) {
                    // Ranking
                    Text("#\(cryptocurrency.marketCapRank)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .leading)
                    
                    // Coin Image
                    AsyncImage(url: URL(string: cryptocurrency.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 32, height: 32)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        case .failure:
                            Image(systemName: "questionmark.circle")
                                .frame(width: 32, height: 32)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // Name and Symbol
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cryptocurrency.name)
                            .font(.headline)
                        Text(cryptocurrency.symbol.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Price and Change
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "$%.2f", cryptocurrency.currentPrice))
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Image(systemName: cryptocurrency.priceChangePercentage24H >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text(String(format: "%.1f%%", abs(cryptocurrency.priceChangePercentage24H)))
                        }
                        .font(.caption)
                        .foregroundColor(cryptocurrency.priceChangePercentage24H >= 0 ? .green : .red)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Separate Favorite Button
            Button(action: {
                withAnimation {
                    viewModel.toggleFavorite(for: cryptocurrency.id)
                }
            }) {
                Image(systemName: viewModel.isFavorite(cryptocurrency.id) ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite(cryptocurrency.id) ? .yellow : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingPredictionSheet) {
            PredictionView(cryptocurrency: cryptocurrency, viewModel: viewModel)
        }
    }
}
