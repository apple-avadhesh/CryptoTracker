import SwiftUI

struct PredictionsListView: View {
    @ObservedObject var viewModel: CryptoViewModel
    
    var body: some View {
        List {
            if viewModel.predictions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No predictions yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Add predictions from the Market tab")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            } else {
                ForEach(viewModel.predictions) { prediction in
                    PredictionRowView(prediction: prediction, viewModel: viewModel)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deletePrediction)
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Predictions")
        .onAppear {
            print("PredictionsListView appeared")
            Task {
                await viewModel.fetchData()
            }
        }
        .onDisappear {
            print("PredictionsListView disappeared")
        }
        .onChange(of: viewModel.predictions) { newPredictions in
            print("Predictions updated: \(newPredictions.count) items")
        }
        .refreshable {
            print("Manual refresh triggered")
            await viewModel.fetchData()
        }
    }
    
    private func deletePrediction(at offsets: IndexSet) {
        for index in offsets {
            viewModel.removePrediction(at: index)
        }
    }
}

struct PredictionRowView: View {
    let prediction: Prediction
    @ObservedObject var viewModel: CryptoViewModel
    
    private var currentPrice: Double? {
        viewModel.cryptocurrencies.first(where: { $0.id == prediction.cryptoId })?.currentPrice
    }
    
    private var currentPriceFormatted: String {
        if let price = currentPrice {
            return String(format: "$%.2f", price)
        }
        return "Loading..."
    }
    
    private var currentPercentageChange: String {
        guard let current = currentPrice else { return "" }
        let change = ((current - prediction.startPrice) / prediction.startPrice) * 100
        return String(format: "%+.1f%%", change)
    }
    
    private var targetPercentageChange: String {
        let change = ((prediction.predictedPrice - prediction.startPrice) / prediction.startPrice) * 100
        return String(format: "%+.1f%%", change)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(prediction.direction == .up ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(prediction.cryptoName)
                        .font(.headline)
                }
                Spacer()
                Text(prediction.timeRemaining)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Prices with equal spacing
            GeometryReader { geometry in
                HStack(alignment: .top, spacing: 0) {
                    // Start Price
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "$%.2f", prediction.startPrice))
                            .font(.subheadline)
                    }
                    .frame(width: geometry.size.width / 3, alignment: .topLeading)
                    
                    // Current Price
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(currentPriceFormatted)
                            .font(.subheadline)
                        if !currentPercentageChange.isEmpty {
                            Text(currentPercentageChange)
                                .font(.caption)
                                .foregroundColor(currentPrice ?? 0 >= prediction.startPrice ? .green : .red)
                        }
                    }
                    .frame(width: geometry.size.width / 3, alignment: .topLeading)
                    
                    // Target Price
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "$%.2f", prediction.predictedPrice))
                            .font(.subheadline)
                        Text(targetPercentageChange)
                            .font(.caption)
                            .foregroundColor(prediction.predictedPrice >= prediction.startPrice ? .green : .red)
                    }
                    .frame(width: geometry.size.width / 3, alignment: .topLeading)
                }
            }
            .frame(height: 65)
            
            // Outcome with improved alignment
            if let outcome = prediction.outcome {
                HStack {
                    HStack(spacing: 6) {
                        switch outcome {
                        case .correct:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Prediction Correct")
                                .foregroundColor(.green)
                        case .incorrect:
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Prediction Incorrect")
                                .foregroundColor(.red)
                        case .pending:
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            Text("Prediction Pending")
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.subheadline)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
    }
}

struct PriceColumn: View {
    let title: String
    let price: String
    var percentageChange: String? = nil
    var changeColor: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(price)
                .font(.subheadline)
            if let change = percentageChange {
                Text(change)
                    .font(.caption)
                    .foregroundColor(changeColor)
            }
        }
    }
}
