import SwiftUI

@main
struct CryptoTrackerApp: App {
    @StateObject private var viewModel = CryptoViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    HomeView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Market", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                NavigationView {
                    PredictionsListView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Predictions", systemImage: "chart.bar.xaxis")
                }
            }
        }
    }
}
