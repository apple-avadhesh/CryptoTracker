import Foundation

struct Prediction: Identifiable, Codable {
    let id: UUID
    let cryptoId: String
    let cryptoName: String
    let cryptoSymbol: String
    let predictedPrice: Double
    let initialPrice: Double
    let timestamp: Date
    let targetDate: Date
    let type: PredictionType
    var outcome: PredictionOutcome?
    
    enum PredictionType: String, Codable, CaseIterable {
        case oneDay = "1 Day"
        case oneWeek = "1 Week"
        case oneMonth = "1 Month"
        case threeMonths = "3 Months"
        
        var timeInterval: TimeInterval {
            switch self {
            case .oneDay:
                return 24 * 60 * 60
            case .oneWeek:
                return 7 * 24 * 60 * 60
            case .oneMonth:
                return 30 * 24 * 60 * 60
            case .threeMonths:
                return 90 * 24 * 60 * 60
            }
        }
    }
    
    enum PredictionOutcome: String, Codable {
        case pending = "⏳"
        case correct = "✅"
        case incorrect = "❌"
        case expired = "⌛️"
    }
    
    init(cryptoId: String, cryptoName: String, cryptoSymbol: String, predictedPrice: Double, initialPrice: Double, type: PredictionType) {
        self.id = UUID()
        self.cryptoId = cryptoId
        self.cryptoName = cryptoName
        self.cryptoSymbol = cryptoSymbol
        self.predictedPrice = predictedPrice
        self.initialPrice = initialPrice
        self.timestamp = Date()
        self.type = type
        self.targetDate = Date().addingTimeInterval(type.timeInterval)
        self.outcome = .pending
    }
    
    func evaluateOutcome(currentPrice: Double) -> PredictionOutcome {
        let now = Date()
        if now > targetDate {
            return .expired
        }
        
        if currentPrice >= predictedPrice {
            return .correct
        } else {
            return now >= targetDate ? .incorrect : .pending
        }
    }
    
    var timeRemaining: String {
        let now = Date()
        if now >= targetDate {
            return "Expired"
        }
        
        let components = Calendar.current.dateComponents([.day, .hour], from: now, to: targetDate)
        if let days = components.day, days > 0 {
            return "\(days)d left"
        } else if let hours = components.hour {
            return "\(hours)h left"
        }
        return "< 1h left"
    }
}
