import SwiftUI

struct NoArrowNavigationLink<Label: View, Destination: View>: View {
  let destination: Destination
  let label: Label

  init(destination: Destination, @ViewBuilder label: () -> Label) {
    self.destination = destination
    self.label = label()
  }

  var body: some View {
    NavigationLink(destination: destination) {
      label
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct HomeView: View {
  @ObservedObject var viewModel: CryptoViewModel
  @State private var searchText = ""
  @State private var showingPredictionSheet = false
  @State private var selectedCategory: Category = .all

  enum Category: String, CaseIterable {
    case all = "All"
    case gainers = "Top Gainers"
    case losers = "Top Losers"
    case largeCap = "Large Cap"
    case midCap = "Mid Cap"
    case smallCap = "Small Cap"
  }

  var filteredCryptos: [Cryptocurrency] {
    var cryptos = viewModel.cryptocurrencies

    // First filter by category
    switch selectedCategory {
    case .all:
      break // Keep all cryptos
    case .gainers:
      cryptos = cryptos.sorted { ($0.priceChangePercentage24H ?? 0) > ($1.priceChangePercentage24H ?? 0) }
        .prefix(20).map { $0 }
    case .losers:
      cryptos = cryptos.sorted { ($0.priceChangePercentage24H ?? 0) < ($1.priceChangePercentage24H ?? 0) }
        .prefix(20).map { $0 }
    case .largeCap:
      cryptos = cryptos.filter { ($0.marketCap ?? 0) >= 10_000_000_000 }
    case .midCap:
      cryptos = cryptos.filter {
        let cap = $0.marketCap ?? 0
        return cap >= 1_000_000_000 && cap < 10_000_000_000
      }
    case .smallCap:
      cryptos = cryptos.filter {
        let cap = $0.marketCap ?? 0
        return cap > 0 && cap < 1_000_000_000
      }
    }

    // Then filter by search text
    if !searchText.isEmpty {
      cryptos = cryptos.filter {
        $0.name.localizedCaseInsensitiveContains(searchText) ||
        $0.symbol.localizedCaseInsensitiveContains(searchText)
      }
    }

    return cryptos
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color(.systemBackground)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          // Categories ScrollView
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach(Category.allCases, id: \.self) { category in
                Button(action: {
                  withAnimation {
                    selectedCategory = category
                  }
                }) {
                  Text(category.rawValue)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(selectedCategory == category ? .bold : .medium)
                    .foregroundColor(selectedCategory == category ? .white : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                      selectedCategory == category ?
                      Color.blue :
                        Color(.systemGray6)
                    )
                    .cornerRadius(20)
                }
              }
            }
            .padding(.horizontal)
          }
          .padding(.vertical, 8)
          .background(Color(.systemBackground))

          ScrollView {
            LazyVStack(spacing: 0) {
              if viewModel.isLoading {
                ProgressView("Loading cryptocurrencies...")
                  .padding()
              } else if let error = viewModel.error {
                VStack(spacing: 16) {
                  Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                  Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }
                .padding()
              } else if filteredCryptos.isEmpty {
                VStack(spacing: 16) {
                  Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                  Text("No results found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                  Text("Try searching with different criteria")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }
                .padding(.top, 40)
              } else {
                ForEach(filteredCryptos) { crypto in
                  HStack(spacing: 0) {
                    NoArrowNavigationLink(destination: CryptoDetailView(cryptocurrency: crypto, viewModel: viewModel)) {
                      CryptoRowContent(cryptocurrency: crypto)
                        .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity)

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
            }
            .padding(.vertical, 8)
          }
        }
      }
      .navigationTitle("Market")
      .searchable(text: $searchText, prompt: "Search cryptocurrencies")
    }
  }
}
