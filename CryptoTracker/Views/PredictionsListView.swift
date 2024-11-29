import SwiftUI

struct PredictionsListView: View {
    @ObservedObject var viewModel: CryptoViewModel
    
    var body: some View {
        List {
            if viewModel.predictions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        Text("No Predictions Yet")
                            .font(.headline)
                        Text("Make predictions for cryptocurrencies to see them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.predictions) { prediction in
                    PredictionRowView(prediction: prediction, viewModel: viewModel)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.removePrediction(at: index)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Predictions")
    }
}

struct PredictionRowView: View {
    let prediction: Prediction
    @ObservedObject var viewModel: CryptoViewModel
    
    var currentPrice: Double? {
        viewModel.getCrypto(by: prediction.cryptoId)?.currentPrice
    }
    
    var profitLossPercentage: Double? {
        guard let current = currentPrice else { return nil }
        return ((current - prediction.initialPrice) / prediction.initialPrice) * 100
    }
    
    var profitLossAmount: Double? {
        guard let current = currentPrice else { return nil }
        return current - prediction.initialPrice
    }
    
    var isProfitable: Bool? {
        guard let amount = profitLossAmount else { return nil }
        return amount > 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Coin Info and Duration
            HStack {
                Text(prediction.cryptoName)
                    .font(.headline)
                Text(prediction.cryptoSymbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(prediction.type.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Price Information
            HStack {
                // Initial Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("Initial")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", prediction.initialPrice))
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Target Price
                VStack(alignment: .center, spacing: 4) {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", prediction.predictedPrice))
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Current Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let current = currentPrice {
                        Text(String(format: "$%.2f", current))
                            .font(.subheadline)
                    } else {
                        Text("--")
                            .font(.subheadline)
                    }
                }
            }
            
            // Profit/Loss Information
            if let percentage = profitLossPercentage, let amount = profitLossAmount {
                HStack {
                    // Profit/Loss Label with Icon
                    HStack(spacing: 4) {
                        Image(systemName: isProfitable ?? false ? "arrow.up.right" : "arrow.down.right")
                        Text(isProfitable ?? false ? "Profit" : "Loss")
                    }
                    .font(.caption.bold())
                    .foregroundColor(isProfitable ?? false ? .green : .red)
                    
                    Spacer()
                    
                    // Amount and Percentage
                    HStack(spacing: 8) {
                        Text(String(format: "$%.2f", abs(amount)))
                        Text("(\(String(format: "%.1f%%", abs(percentage))))")
                    }
                    .font(.caption.bold())
                    .foregroundColor(isProfitable ?? false ? .green : .red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (isProfitable ?? false ? Color.green : Color.red)
                        .opacity(0.1)
                )
                .cornerRadius(8)
            }
            
            // Status and Date
            HStack {
                Text("Made on \(prediction.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(prediction.outcome?.rawValue ?? "Pending")
                    .font(.caption.bold())
                    .foregroundColor(predictionColor)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var predictionColor: Color {
        guard let outcome = prediction.outcome else {
            return .orange
        }
        switch outcome {
        case .correct:
            return .green
        case .incorrect:
            return .red
        case .expired:
            return .gray
        case .pending:
            return .orange
        }
    }
}
