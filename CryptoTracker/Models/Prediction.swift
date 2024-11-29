import Foundation

struct Prediction: Identifiable, Codable, Equatable {
    let id: UUID
    let cryptoId: String
    let cryptoName: String
    let startPrice: Double
    let predictedPrice: Double
    let direction: PriceDirection
    let timeframe: Int
    let date: Date
    var outcome: PredictionOutcome?
    
    init(cryptoId: String, cryptoName: String, startPrice: Double, predictedPrice: Double, direction: PriceDirection, timeframe: Int, date: Date) {
        self.id = UUID()
        self.cryptoId = cryptoId
        self.cryptoName = cryptoName
        self.startPrice = startPrice
        self.predictedPrice = predictedPrice
        self.direction = direction
        self.timeframe = timeframe
        self.date = date
        self.outcome = nil
    }
    
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: timeframe, to: date) ?? date
    }
    
    var isActive: Bool {
        endDate > Date()
    }
    
    var timeRemaining: String {
        if !isActive {
            return "Completed"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: Date(), to: endDate)
        
        if let days = components.day, let hours = components.hour {
            if days > 0 {
                return "\(days)d \(hours)h"
            } else {
                return "\(hours)h"
            }
        }
        
        return "Unknown"
    }
    
    var priceChangePercentage: Double {
        ((predictedPrice - startPrice) / startPrice) * 100
    }
    
    var formattedPriceChange: String {
        String(format: "%.1f%%", abs(priceChangePercentage))
    }
    
    func evaluateOutcome(currentPrice: Double) -> PredictionOutcome {
        if isActive {
            return .pending
        }
        
        let actualChange = currentPrice - startPrice
        let predictedChange = predictedPrice - startPrice
        
        if (actualChange >= 0 && predictedChange >= 0) || (actualChange < 0 && predictedChange < 0) {
            return .correct
        } else {
            return .incorrect
        }
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case cryptoId
        case cryptoName
        case startPrice
        case predictedPrice
        case direction
        case timeframe
        case date
        case outcome
    }
    
    // MARK: - Equatable
    static func == (lhs: Prediction, rhs: Prediction) -> Bool {
        lhs.id == rhs.id &&
        lhs.cryptoId == rhs.cryptoId &&
        lhs.cryptoName == rhs.cryptoName &&
        lhs.startPrice == rhs.startPrice &&
        lhs.predictedPrice == rhs.predictedPrice &&
        lhs.direction == rhs.direction &&
        lhs.timeframe == rhs.timeframe &&
        lhs.date == rhs.date &&
        lhs.outcome == rhs.outcome
    }
}

enum PriceDirection: String, Codable {
    case up
    case down
}

enum PredictionOutcome: String, Codable {
    case correct
    case incorrect
    case pending
}
