import Foundation
import SwiftUI

@MainActor
class CryptoViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var favoriteIds: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "FavoriteIds") ?? [])
    @Published var predictions: [Prediction] = []
    @Published var error: Error?
    @Published var isLoading = false
    @Published var currentPage = 1
    private let pageSize = 250
    private var isFetching = false
    
    // Description-related state management
    @Published var descriptionLoadingStates: [String: DescriptionLoadState] = [:]
    
    enum DescriptionLoadState: Equatable {
        case notLoaded
        case loading
        case loaded(String)
        case failed(Error)
        
        // Implement Equatable
        static func == (lhs: DescriptionLoadState, rhs: DescriptionLoadState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded):
                return true
            case (.loading, .loading):
                return true
            case (.loaded(let lhsDesc), .loaded(let rhsDesc)):
                return lhsDesc == rhsDesc
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    var favoriteCryptos: [Cryptocurrency] {
        cryptocurrencies.filter { favoriteIds.contains($0.id) }
    }
    
    init() {
        loadFavorites()
        loadPredictions()
        Task {
            await fetchData()
            startPeriodicUpdates()
        }
    }
    
    private func startPeriodicUpdates() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchData()
            }
        }
    }
    
    func fetchData() async {
        guard !isFetching else { return }
        isFetching = true
        isLoading = cryptocurrencies.isEmpty
        error = nil
        
        do {
            let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=false&price_change_percentage=24h")!
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 429 {
                throw NSError(domain: "CryptoTracker", code: 429, userInfo: [
                    NSLocalizedDescriptionKey: "Rate limit reached. Please try again in a minute."
                ])
            }
            
            guard httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            self.cryptocurrencies = try decoder.decode([Cryptocurrency].self, from: data)
            
            updatePredictionOutcomes()
        } catch {
            self.error = error
        }
        
        isFetching = false
        isLoading = false
    }
    
    func fetchCryptoDescription(for id: String) async {
        // Check if description is already loaded or currently loading
        guard descriptionLoadingStates[id] == nil || descriptionLoadingStates[id] == .notLoaded else { 
            return 
        }
        
        // Set loading state
        descriptionLoadingStates[id] = .loading
        
        do {
            let urlString = "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false"
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (detailData, detailResponse) = try await URLSession.shared.data(from: url)
            
            guard let detailHttpResponse = detailResponse as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("Description Fetch URL: \(urlString)")
            print("Description Fetch Status Code: \(detailHttpResponse.statusCode)")
            
            guard detailHttpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            struct CoinDetail: Codable {
                struct Description: Codable {
                    let en: String?
                }
                let description: Description
            }
            
            let coinDetail = try JSONDecoder().decode(CoinDetail.self, from: detailData)
            
            // Safely unwrap description, use default if nil
            let description = coinDetail.description.en ?? "No description available for this cryptocurrency."
            
            // Update description loading state
            descriptionLoadingStates[id] = .loaded(description)
            
            // Update cryptocurrency description
            if let index = cryptocurrencies.firstIndex(where: { $0.id == id }) {
                cryptocurrencies[index].description = description
                print("✅ Updated description for \(id): \(description.prefix(50))...")
            }
            
        } catch {
            print("❌ Error fetching description for \(id): \(error)")
            
            // Update description loading state with error
            descriptionLoadingStates[id] = .failed(error)
        }
    }
    
    // Helper method to get description state
    func descriptionState(for cryptoId: String) -> DescriptionLoadState {
        return descriptionLoadingStates[cryptoId] ?? .notLoaded
    }
    
    // MARK: - Favorites Management
    
    func toggleFavorite(for id: String) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
        saveFavorites()
    }
    
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: "FavoriteIds")
    }
    
    private func loadFavorites() {
        favoriteIds = Set(UserDefaults.standard.stringArray(forKey: "FavoriteIds") ?? [])
    }
    
    func addPrediction(_ prediction: Prediction) {
        print("Adding new prediction for \(prediction.cryptoName)")
        predictions.append(prediction)
        objectWillChange.send()  // Explicitly notify observers
        savePredictions()
    }
    
    func removePrediction(_ prediction: Prediction) {
        predictions.removeAll { $0.id == prediction.id }
        savePredictions()
    }
    
    func removePrediction(at index: Int) {
        predictions.remove(at: index)
        savePredictions()
    }
    
    func getCrypto(by id: String) -> Cryptocurrency? {
        cryptocurrencies.first { $0.id == id }
    }
    
    private func loadPredictions() {
        if let data = UserDefaults.standard.data(forKey: "CryptoPredictions"),
           let savedPredictions = try? JSONDecoder().decode([Prediction].self, from: data) {
            print("Loaded \(savedPredictions.count) predictions from UserDefaults")
            predictions = savedPredictions
        } else {
            print("No predictions found in UserDefaults")
        }
    }
    
    private func savePredictions() {
        if let encoded = try? JSONEncoder().encode(predictions) {
            UserDefaults.standard.set(encoded, forKey: "CryptoPredictions")
            UserDefaults.standard.synchronize()  // Force immediate save
            print("Saved \(predictions.count) predictions to UserDefaults")
        } else {
            print("Failed to encode predictions")
        }
    }
    
    private func updatePredictionOutcomes() {
        var updatedPredictions = [Prediction]()
        
        for prediction in predictions {
            if let currentPrice = cryptocurrencies.first(where: { $0.id == prediction.cryptoId })?.currentPrice {
                var updatedPrediction = prediction
                updatedPrediction.outcome = prediction.evaluateOutcome(currentPrice: currentPrice)
                updatedPredictions.append(updatedPrediction)
            } else {
                updatedPredictions.append(prediction)
            }
        }
        
        if predictions != updatedPredictions {
            predictions = updatedPredictions
            savePredictions()
        }
    }
}
