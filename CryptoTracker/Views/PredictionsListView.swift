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
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.predictions) { prediction in
                    PredictionRowView(prediction: prediction, viewModel: viewModel)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
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
            return formatPrice(price)
        }
        return "Loading..."
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price >= 1000 {
            return String(format: "$%.1fK", price / 1000)
        }
        return String(format: "$%.2f", price)
    }
    
    private var cryptoSymbol: String {
        viewModel.cryptocurrencies.first(where: { $0.id == prediction.cryptoId })?.symbol ?? ""
    }
    
    private var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: prediction.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Crypto Name and Time
            HStack(spacing: 12) {
                // Crypto Name and Symbol
                VStack(alignment: .leading, spacing: 4) {
                    Text(prediction.cryptoName)
                        .font(.headline)
                    Text(cryptoSymbol.uppercased())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time Remaining
                Text(prediction.timeRemaining)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Prices Grid
            HStack(spacing: 0) {
                // Initial Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("Initial")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text(formatPrice(prediction.startPrice))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Target Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text(formatPrice(prediction.predictedPrice))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Current Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text(currentPriceFormatted)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Profit/Loss Status
            if let currentPrice = currentPrice {
                let profitAmount = currentPrice - prediction.startPrice
                let profitPercentage = (profitAmount / prediction.startPrice) * 100
                let isProfit = profitAmount > 0
                
                HStack(spacing: 8) {
                    Image(systemName: isProfit ? "arrow.up.right" : "arrow.down.right")
                    Text(formatPrice(abs(profitAmount)))
                    Text(String(format: "(%.1f%%)", abs(profitPercentage)))
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isProfit ? .green : .red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isProfit ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                )
            }
            
            // Creation Date and Status
            HStack {
                Text("Made on \(formattedCreationDate)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let outcome = prediction.outcome {
                    Image(systemName: outcome == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(outcome == .correct ? .green : .red)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
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
