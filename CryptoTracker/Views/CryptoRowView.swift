import SwiftUI

extension Double {
    func currencyFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        
        // For very small numbers, use scientific notation
        if self < 0.01 {
            formatter.numberStyle = .scientific
            formatter.positiveFormat = "$#.######E+0"
            formatter.exponentSymbol = "e"
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

struct CryptoRowContent: View {
    let cryptocurrency: Cryptocurrency
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: cryptocurrency.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "questionmark.circle")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 36, height: 36)
                
                if let rank = cryptocurrency.marketCapRank {
                    Text("#\(rank)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(4)
                        .offset(x: -5, y: -8)
                }
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(cryptocurrency.name)
                    .font(.headline)
                Text(cryptocurrency.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text((cryptocurrency.currentPrice ?? 0).currencyFormatted())
                    .font(.headline)
                
                HStack(spacing: 2) {
                    Image(systemName: cryptocurrency.priceChangePercentage24H ?? 0 >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    Text("\(abs(cryptocurrency.priceChangePercentage24H ?? 0), specifier: "%.1f")%")
                        .font(.subheadline)
                }
                .foregroundColor(cryptocurrency.priceChangePercentage24H ?? 0 >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CryptoRowView: View {
    let cryptocurrency: Cryptocurrency
    @ObservedObject var viewModel: CryptoViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            CryptoRowContent(cryptocurrency: cryptocurrency)
            
            // Favorite Button
            Button(action: {
                viewModel.toggleFavorite(for: cryptocurrency.id)
            }) {
                Image(systemName: viewModel.isFavorite(cryptocurrency.id) ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite(cryptocurrency.id) ? .yellow : .gray)
                    .font(.system(size: 20))
            }
            .padding(.leading, 12)
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

// Custom navigation button style to remove the arrow
struct PlainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
    }
}
