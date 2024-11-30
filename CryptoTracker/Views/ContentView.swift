import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CryptoViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Market", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
            
            NavigationView {
                PredictionsListView(viewModel: viewModel)
            }
            .tabItem {
                Label("Predictions", systemImage: "chart.bar.fill")
            }
        }
    }
}
