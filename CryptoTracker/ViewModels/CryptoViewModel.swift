import Foundation
import Combine

@MainActor
class CryptoViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var lastFetchTime: Date?
    private let minFetchInterval: TimeInterval = 30 // 30 seconds between fetches
    
    func fetchData() async throws {
        // Check if we need to wait before making another request
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < minFetchInterval {
            let waitTime = minFetchInterval - Date().timeIntervalSince(lastFetch)
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
        
        isLoading = true
        error = nil
        
        // Use simple markets endpoint with essential parameters
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=false&price_change_percentage=24h&locale=en"
        
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                error = "Invalid response"
                isLoading = false
                return
            }
            
            if httpResponse.statusCode == 429 {
                error = "Rate limit exceeded. Please wait 30 seconds and try again."
                isLoading = false
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                error = "Server error: \(httpResponse.statusCode)"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            cryptocurrencies = try decoder.decode([Cryptocurrency].self, from: data)
            lastFetchTime = Date()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            throw error
        }
    }
}

// Helper struct to decode coin details
struct CoinDetail: Codable {
    let id: String
    let categories: [String]?
}
