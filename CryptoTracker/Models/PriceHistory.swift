import Foundation

struct PriceHistory: Codable {
    let prices: [[Double]]  // [[timestamp, price], ...]
    
    func toPricePoints() -> [PricePoint] {
        prices.map { dataPoint in
            let timestamp = Date(timeIntervalSince1970: dataPoint[0] / 1000)
            let price = dataPoint[1]
            return PricePoint(timestamp: timestamp, price: price)
        }
    }
}
