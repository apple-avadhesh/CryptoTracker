import Foundation
import Combine

@MainActor
class CryptoViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var predictions: [Prediction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var favorites = Set<String>()
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteCryptos"
    private let predictionsKey = "CryptoPredictions"
    private var lastFetchTime: Date?
    private let minFetchInterval: TimeInterval = 30 // 30 seconds between fetches
    
    init() {
        loadFavorites()
        loadPredictions()
    }
    
    func getFavorites() -> [Cryptocurrency] {
        cryptocurrencies.filter { isFavorite($0.id) }
    }
    
    func isFavorite(_ cryptoId: String) -> Bool {
        favorites.contains(cryptoId)
    }
    
    func toggleFavorite(for cryptoId: String) {
        if favorites.contains(cryptoId) {
            favorites.remove(cryptoId)
        } else {
            favorites.insert(cryptoId)
        }
        saveFavorites()
        objectWillChange.send()
    }
    
    private func loadFavorites() {
        if let savedFavorites = userDefaults.stringArray(forKey: favoritesKey) {
            favorites = Set(savedFavorites)
        }
    }
    
    private func saveFavorites() {
        userDefaults.set(Array(favorites), forKey: favoritesKey)
        userDefaults.synchronize()
    }
    
    // MARK: - Predictions Management
    
    func loadPredictions() {
        if let data = userDefaults.data(forKey: predictionsKey),
           let savedPredictions = try? JSONDecoder().decode([Prediction].self, from: data) {
            predictions = savedPredictions
            updatePredictionOutcomes()
        }
    }
    
    private func savePredictions() {
        if let encoded = try? JSONEncoder().encode(predictions) {
            userDefaults.set(encoded, forKey: predictionsKey)
            userDefaults.synchronize()
        }
    }
    
    func addPrediction(_ prediction: Prediction) {
        predictions.append(prediction)
        updatePredictionOutcomes()
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
    
    private func updatePredictionOutcomes() {
        var needsUpdate = false
        predictions = predictions.map { prediction in
            var updatedPrediction = prediction
            
            // Get current price
            guard let currentPrice = getCrypto(by: prediction.cryptoId)?.currentPrice else {
                return prediction
            }
            
            // Evaluate the outcome
            let newOutcome = prediction.evaluateOutcome(currentPrice: currentPrice)
            if updatedPrediction.outcome != newOutcome {
                updatedPrediction.outcome = newOutcome
                needsUpdate = true
            }
            
            return updatedPrediction
        }
        
        if needsUpdate {
            savePredictions()
        }
    }
    
    // MARK: - Data Fetching
    
    func fetchData() async throws {
        // Check if we need to wait before making another request
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < minFetchInterval {
            let waitTime = minFetchInterval - Date().timeIntervalSince(lastFetch)
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
        
        isLoading = true
        error = nil
        
        do {
            let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            cryptocurrencies = try decoder.decode([Cryptocurrency].self, from: data)
            lastFetchTime = Date()
            updatePredictionOutcomes()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

// Helper struct to decode coin details
struct CoinDetail: Codable {
    let id: String
    let categories: [String]?
}
