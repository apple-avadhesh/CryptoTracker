import SwiftUI
import Charts
import WebKit

@available(iOS 16.0, *)
struct CryptoDetailView: View {
  let cryptocurrency: Cryptocurrency
  @ObservedObject var viewModel: CryptoViewModel

  private var marketCapFormatted: String {
    if let marketCap = cryptocurrency.marketCap {
      if marketCap >= 1_000_000_000 {
        return String(format: "$%.1fB", marketCap / 1_000_000_000)
      } else if marketCap >= 1_000_000 {
        return String(format: "$%.1fM", marketCap / 1_000_000)
      }
      return String(format: "$%.0f", marketCap)
    }
    return "--"
  }

  private var volumeFormatted: String {
    if let volume = cryptocurrency.totalVolume {
      if volume >= 1_000_000_000 {
        return String(format: "$%.1fB", volume / 1_000_000_000)
      } else if volume >= 1_000_000 {
        return String(format: "$%.1fM", volume / 1_000_000)
      }
      return String(format: "$%.0f", volume)
    }
    return "--"
  }

  @State private var showingPredictionSheet = false

  var marketCapFormattedForTesting: String {
    marketCapFormatted
  }

  var volumeFormattedForTesting: String {
    volumeFormatted
  }

  var showingPredictionSheetForTesting: Binding<Bool> {
    $showingPredictionSheet
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        // Header Section with Shadow
        ZStack {
          HStack(alignment: .center, spacing: 12) {
            // Icon and Name
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
                    .offset(x: -8, y: -8)
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
            }

            Spacer()

            // Price Info
            VStack(alignment: .trailing, spacing: 2) {
              Text(cryptocurrency.formattedCurrentPrice)
                .font(.headline)

              HStack(spacing: 2) {
                Image(systemName: cryptocurrency.isPriceChangePositive ? "arrow.up.right" : "arrow.down.right")
                  .font(.caption)
                Text(cryptocurrency.formattedPriceChange)
                  .font(.subheadline)
              }
              .foregroundColor(cryptocurrency.isPriceChangePositive ? .green : .red)
            }

            // Favorite Button
            FavoriteButton(
              isFavorite: viewModel.isFavorite(cryptocurrency.id),
              size: 24,
              action: { viewModel.toggleFavorite(for: cryptocurrency.id) }
            )
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
          .background(Color(.systemBackground))
        }
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)

        // Chart
        TradingViewChartContainer(symbol: cryptocurrency.symbol.uppercased(), height: 300)
          .frame(height: 300)

        // Add Prediction Button Section with Shadow
        ZStack {
          Button(action: {
            showingPredictionSheet = true
          }) {
            HStack {
              Image(systemName: "chart.line.uptrend.xyaxis")
              Text("Make Price Prediction")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
        }
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)

        // Stats Grid Section with Shadow
        ZStack(alignment: .leading) {
          LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
          ], spacing: 4) { // Reduce in-between item spacing
            StatView(title: "Market Cap", value: marketCapFormatted)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.vertical, 8)
            StatView(title: "Volume (24h)", value: volumeFormatted)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.vertical, 8)
            StatView(title: "24h High", value: cryptocurrency.high24H.map { String(format: "$%.2f", $0) } ?? "--")
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.vertical, 8)
            StatView(title: "24h Low", value: cryptocurrency.low24H.map { String(format: "$%.2f", $0) } ?? "--")
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.vertical, 8)
            if let rank = cryptocurrency.marketCapRank {
              StatView(title: "Market Cap Rank", value: "#\(rank)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading) // Align with About section
          .padding(.horizontal, 16)
          .background(Color(.systemBackground))
        }
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)

        // Description Section with Shadow
        ZStack {
          VStack(alignment: .leading, spacing: 8) {
            Text("About \(cryptocurrency.name)")
              .font(.headline)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 0) // Ensure alignment with description

            switch viewModel.descriptionState(for: cryptocurrency.id) {
            case .loaded(let description):
              TextWithLinks(description: description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure alignment with title

            case .loading:
              HStack {
                ProgressView()
                Text("Loading description...")
                  .foregroundColor(.secondary)
              }
              .frame(maxWidth: .infinity, alignment: .leading)

            case .failed(let error):
              VStack(alignment: .leading, spacing: 4) {
                Text("Failed to load description")
                  .foregroundColor(.red)
                Text(error.localizedDescription)
                  .font(.caption)
                  .foregroundColor(.secondary)
                Button("Retry") {
                  Task {
                    await viewModel.fetchCryptoDescription(for: cryptocurrency.id)
                  }
                }
                .padding(.top, 4)
              }
              .frame(maxWidth: .infinity, alignment: .leading)

            case .notLoaded:
              Text("No description available")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .padding(.horizontal)
          .padding(.top, 16)
        }
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .background(Color(.systemGray6))
    .sheet(isPresented: $showingPredictionSheet) {
      AddPredictionView(cryptocurrency: cryptocurrency, viewModel: viewModel, isPresented: $showingPredictionSheet)
    }
    .task {
      await viewModel.fetchCryptoDescription(for: cryptocurrency.id)
    }
  }
}

struct TextWithLinks: View {
  let description: String

  var body: some View {
    let attributedString = NSMutableAttributedString()
    if let data = description.data(using: .utf8) {
      if let htmlString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
        attributedString.append(htmlString)
      }
    }

    // Override font attributes
    let fullRange = NSRange(location: 0, length: attributedString.length)
    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: fullRange)

    return Text(AttributedString(attributedString))
      .foregroundColor(.primary)
      .padding(.horizontal, 0)
      .padding(.vertical, 4)
  }
}

struct StatView: View {
  let title: String
  let value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundColor(.gray)
      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
