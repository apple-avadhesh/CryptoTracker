import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CryptoViewModel
    @State private var selectedCategory: CryptoCategory = .all
    @State private var searchText = ""
    
    private var filteredCryptos: [Cryptocurrency] {
        let categoryFiltered: [Cryptocurrency] = {
            switch selectedCategory {
            case .all:
                return viewModel.cryptocurrencies
            case .favorites:
                return viewModel.favoriteCryptos
            case .gainers:
                return viewModel.cryptocurrencies.sorted { ($1.priceChangePercentage24H ?? 0) < ($0.priceChangePercentage24H ?? 0) }
            case .losers:
                return viewModel.cryptocurrencies.sorted { ($0.priceChangePercentage24H ?? 0) < ($1.priceChangePercentage24H ?? 0) }
            }
        }()
        
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Categories ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CryptoCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            
            List {
                if viewModel.isLoading && viewModel.cryptocurrencies.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView("Loading cryptocurrencies...")
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else if let error = viewModel.error {
                    ErrorView(error: error.localizedDescription) {
                        Task {
                            await viewModel.fetchData()
                        }
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredCryptos) { crypto in
                        CryptoRowView(cryptocurrency: crypto, viewModel: viewModel)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.fetchData()
            }
        }
        .searchable(text: $searchText, prompt: "Search cryptocurrencies")
        .navigationTitle("CryptoTracker")
    }
}
