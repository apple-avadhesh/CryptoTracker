import SwiftUI
import Charts

struct PricePoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let price: Double
}

struct CryptoPriceChart: View {
    let priceHistory: [PricePoint]
    let priceChangeColor: Color
    
    var body: some View {
        Chart(priceHistory) { point in
            LineMark(
                x: .value("Time", point.timestamp),
                y: .value("Price", point.price)
            )
            .foregroundStyle(priceChangeColor)
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 200)
        .padding(.vertical, 8)
    }
}

#Preview {
    CryptoPriceChart(
        priceHistory: [
            PricePoint(timestamp: Date().addingTimeInterval(-3600 * 24), price: 30000),
            PricePoint(timestamp: Date().addingTimeInterval(-3600 * 12), price: 31000),
            PricePoint(timestamp: Date(), price: 32000)
        ],
        priceChangeColor: .green
    )
}
