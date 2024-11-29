import Foundation
import SwiftUI

@MainActor
class CryptoViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var favoriteIds: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "FavoriteIds") ?? [])
    @Published var predictions: [Prediction] = []
    @Published var error: Error?
    @Published var isLoading = false
    
    var favoriteCryptos: [Cryptocurrency] {
        cryptocurrencies.filter { favoriteIds.contains($0.id) }
    }
    
    init() {
        loadFavorites()
        loadPredictions()
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        isLoading = true
        error = nil
        
        do {
            let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&sparkline=false&price_change_percentage=24h")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 429 {
                throw URLError(.init(rawValue: 429))
            }
            
            guard httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // Print the raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString.prefix(1000))") // Print first 1000 chars to see structure
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys // Changed to use default keys
            
            do {
                let cryptos = try decoder.decode([Cryptocurrency].self, from: data)
                print("Decoded \(cryptos.count) cryptocurrencies")
                if let first = cryptos.first {
                    print("First crypto details:")
                    print("- ID: \(first.id)")
                    print("- Name: \(first.name)")
                    print("- Symbol: \(first.symbol)")
                    print("- Current Price: \(String(describing: first.currentPrice))")
                    print("- Market Cap Rank: \(String(describing: first.marketCapRank))")
                    print("- Price Change 24h: \(String(describing: first.priceChangePercentage24H))")
                }
                self.cryptocurrencies = cryptos
            } catch {
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key.stringValue)' not found at path: \(context.codingPath.map { $0.stringValue })")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type) at path: \(context.codingPath.map { $0.stringValue })")
                    case .valueNotFound(let type, let context):
                        print("Value of type \(type) not found at path: \(context.codingPath.map { $0.stringValue })")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context)")
                    @unknown default:
                        print("Unknown decoding error: \(error)")
                    }
                }
                throw error
            }
            
            updatePredictionOutcomes()
        } catch let error as URLError where error.code.rawValue == 429 {
            self.error = NSError(domain: "CryptoTracker", code: 429, userInfo: [
                NSLocalizedDescriptionKey: "Rate limit exceeded. Please try again later."
            ])
        } catch {
            self.error = error
            print("Error fetching data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func toggleFavorite(for id: String) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteIds), forKey: "FavoriteIds")
    }
    
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    func addPrediction(_ prediction: Prediction) {
        print("Adding new prediction for \(prediction.cryptoName)")
        predictions.append(prediction)
        objectWillChange.send()  // Explicitly notify observers
        savePredictions()
        Task {
            await fetchData()  // Refresh data after adding prediction
        }
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
    
    private func loadFavorites() {
        favoriteIds = Set(UserDefaults.standard.stringArray(forKey: "FavoriteIds") ?? [])
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
