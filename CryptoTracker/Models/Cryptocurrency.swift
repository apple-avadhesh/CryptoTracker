import Foundation

struct Cryptocurrency: Identifiable, Codable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    var description: String?
    var currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let totalVolume: Double?
    let high24H: Double?
    let low24H: Double?
    let priceChange24H: Double?
    var priceChangePercentage24H: Double?
    let lastUpdated: String?
    
    static func == (lhs: Cryptocurrency, rhs: Cryptocurrency) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var formattedCurrentPrice: String {
        if let price = currentPrice {
            return String(format: "$%.2f", price)
        }
        return "--"
    }
    
    var formattedPriceChange: String {
        if let change = priceChangePercentage24H {
            return String(format: "%.1f%%", abs(change))
        }
        return "--"
    }
    
    var isPriceChangePositive: Bool {
        priceChangePercentage24H ?? 0 >= 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case description
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case lastUpdated = "last_updated"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        image = try container.decode(String.self, forKey: .image)
        currentPrice = try? container.decode(Double.self, forKey: .currentPrice)
        marketCap = try? container.decode(Double.self, forKey: .marketCap)
        marketCapRank = try? container.decode(Int.self, forKey: .marketCapRank)
        totalVolume = try? container.decode(Double.self, forKey: .totalVolume)
        high24H = try? container.decode(Double.self, forKey: .high24H)
        low24H = try? container.decode(Double.self, forKey: .low24H)
        priceChange24H = try? container.decode(Double.self, forKey: .priceChange24H)
        priceChangePercentage24H = try? container.decode(Double.self, forKey: .priceChangePercentage24H)
        lastUpdated = try? container.decode(String.self, forKey: .lastUpdated)
        
        // Optional description, initialized as nil
        description = nil
    }
}
