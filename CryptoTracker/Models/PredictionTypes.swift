import Foundation

enum PriceDirection: String, Codable {
    case up
    case down
}

enum PredictionOutcome: String, Codable {
    case correct
    case incorrect
    case pending
}
