import SwiftUI

enum CryptoCategory: String, CaseIterable {
    case all = "All"
    case gainers = "Top Gainers"
    case losers = "Top Losers"
    case new = "New Listings"
    case largeCap = "Large Cap"
    case midCap = "Mid Cap"
    case smallCap = "Small Cap"
}

struct ContentView: View {
    @StateObject private var viewModel = CryptoViewModel()
    @State private var selectedCategory: CryptoCategory = .all
    @State private var searchText = ""
    
    private func getTopGainers() -> [Cryptocurrency] {
        let sorted = viewModel.cryptocurrencies
            .filter { $0.priceChangePercentage24H > 0 }
            .sorted { $0.priceChangePercentage24H > $1.priceChangePercentage24H }
        return sorted
    }
    
    private func getTopLosers() -> [Cryptocurrency] {
        let sorted = viewModel.cryptocurrencies
            .filter { $0.priceChangePercentage24H < 0 }
            .sorted { $0.priceChangePercentage24H < $1.priceChangePercentage24H }
        return sorted
    }
    
    private func filterByCategory(_ category: String) -> [Cryptocurrency] {
        // For now, we'll use tags since we're not fetching detailed categories
        viewModel.cryptocurrencies.filter { crypto in
            crypto.tags?.contains(where: { $0.lowercased().contains(category.lowercased()) }) ?? false
        }
    }
    
    private func filterByMarketCap(min: Double?, max: Double?) -> [Cryptocurrency] {
        viewModel.cryptocurrencies.filter { crypto in
            let aboveMin = min.map { crypto.marketCap >= $0 } ?? true
            let belowMax = max.map { crypto.marketCap < $0 } ?? true
            return aboveMin && belowMax
        }
    }
    
    private func getNewlyListed() -> [Cryptocurrency] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return viewModel.cryptocurrencies
            .compactMap { crypto -> (Cryptocurrency, Date)? in
                guard let lastUpdatedStr = crypto.lastUpdated,
                      let date = dateFormatter.date(from: lastUpdatedStr) else {
                    return nil
                }
                return (crypto, date)
            }
            .sorted { $0.1 > $1.1 } // Sort by date descending
            .prefix(20)
            .map { $0.0 } // Get just the cryptocurrency
    }
    
    var filteredCryptos: [Cryptocurrency] {
        let categoryFiltered: [Cryptocurrency] = {
            switch selectedCategory {
            case .all:
                return viewModel.cryptocurrencies
            case .gainers:
                return getTopGainers()
            case .losers:
                return getTopLosers()
            case .new:
                return getNewlyListed()
            case .largeCap:
                return filterByMarketCap(min: 10_000_000_000, max: nil)
            case .midCap:
                return filterByMarketCap(min: 1_000_000_000, max: 10_000_000_000)
            case .smallCap:
                return filterByMarketCap(min: nil, max: 1_000_000_000)
            }
        }()
        
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter { crypto in
            let searchQuery = searchText.lowercased()
            return crypto.name.lowercased().contains(searchQuery) ||
                   crypto.symbol.lowercased().contains(searchQuery)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search cryptocurrencies...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CryptoCategory.allCases, id: \.self) { category in
                            CategoryButton(category: category, isSelected: category == selectedCategory) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(uiColor: .systemBackground))
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            try? await viewModel.fetchData()
                        }
                    }
                } else {
                    List {
                        ForEach(filteredCryptos) { crypto in
                            CryptoRowView(cryptocurrency: crypto)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Crypto Tracker")
            .refreshable {
                try? await viewModel.fetchData()
            }
        }
        .task {
            try? await viewModel.fetchData()
        }
    }
}

struct CategoryButton: View {
    let category: CryptoCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry", action: retryAction)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
