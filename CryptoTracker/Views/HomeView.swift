import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CryptoViewModel
    @State private var selectedCategory: CryptoCategory = .all
    @State private var searchText = ""
    
    var filteredCryptos: [Cryptocurrency] {
        var cryptos = viewModel.cryptocurrencies
        
        // Apply category filter
        switch selectedCategory {
        case .all:
            break
        case .favorites:
            cryptos = viewModel.getFavorites()
        case .gainers:
            cryptos = cryptos.filter { $0.priceChangePercentage24H > 0 }
                .sorted { $0.priceChangePercentage24H > $1.priceChangePercentage24H }
        case .losers:
            cryptos = cryptos.filter { $0.priceChangePercentage24H < 0 }
                .sorted { $0.priceChangePercentage24H < $1.priceChangePercentage24H }
        case .marketCap:
            cryptos = cryptos.sorted { $0.marketCap > $1.marketCap }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            cryptos = cryptos.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return cryptos
    }
    
    var body: some View {
        List {
            Section {
                // Search Bar
                TextField("Search cryptocurrencies...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CryptoCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)
            }
            
            if viewModel.isLoading && viewModel.cryptocurrencies.isEmpty {
                HStack {
                    Spacer()
                    ProgressView("Loading cryptocurrencies...")
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        try await viewModel.fetchData()
                    }
                }
                .listRowBackground(Color.clear)
            } else {
                // Cryptocurrencies
                ForEach(filteredCryptos) { crypto in
                    CryptoRowView(cryptocurrency: crypto, viewModel: viewModel)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Crypto Tracker")
        .task {
            if viewModel.cryptocurrencies.isEmpty {
                try? await viewModel.fetchData()
            }
        }
    }
}
