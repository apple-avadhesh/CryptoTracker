import SwiftUI

struct AddPredictionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CryptoViewModel
    let crypto: Cryptocurrency
    
    @State private var predictedPrice = ""
    @State private var timeframe = 7
    @State private var customTimeframe = ""
    @State private var showCustomTimeframe = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let timeframePresets = [1, 7, 30, 90, 180, 365]
    
    private var isValidInput: Bool {
        guard let price = Double(predictedPrice),
              price > 0,
              timeframe > 0 else {
            return false
        }
        return true
    }
    
    private var percentageChange: Double {
        guard let predictedPriceValue = Double(predictedPrice),
              let currentPrice = crypto.currentPrice else {
            return 0
        }
        return ((predictedPriceValue - currentPrice) / currentPrice) * 100
    }
    
    private var percentageChangeFormatted: String {
        let prefix = percentageChange >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", percentageChange))%"
    }
    
    private var percentageColor: Color {
        if percentageChange > 0 {
            return .green
        } else if percentageChange < 0 {
            return .red
        }
        return .primary
    }
    
    private var direction: PriceDirection {
        percentageChange >= 0 ? .up : .down
    }
    
    private func formatLargeNumber(_ number: Double) -> String {
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0
        
        switch number {
        case let x where x >= billion:
            return String(format: "$%.1fB", x/billion)
        case let x where x >= million:
            return String(format: "$%.1fM", x/million)
        case let x where x >= thousand:
            return String(format: "$%.1fK", x/thousand)
        default:
            return String(format: "$%.2f", number)
        }
    }
    
    private func formatTimeframe(_ days: Int) -> String {
        if days == 1 {
            return "1 day"
        } else if days == 7 {
            return "1 week"
        } else if days == 30 {
            return "1 month"
        } else if days == 90 {
            return "3 months"
        } else if days == 180 {
            return "6 months"
        } else if days == 365 {
            return "1 year"
        } else {
            return "\(days) days"
        }
    }
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // Crypto Icon
                        AsyncImage(url: URL(string: crypto.image)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            case .failure:
                                Image(systemName: "questionmark.circle")
                                    .frame(width: 40, height: 40)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        // Crypto Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(crypto.name)
                                .font(.headline)
                            Text(crypto.symbol.uppercased())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Market Cap Rank
                        if let rank = crypto.marketCapRank {
                            Text("#\(rank)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Price Stats
                    VStack(spacing: 12) {
                        HStack {
                            Text("Current Price")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(crypto.formattedCurrentPrice)
                                .bold()
                        }
                        
                        HStack {
                            Text("24h Change")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(crypto.formattedPriceChange)
                                .foregroundColor(crypto.isPriceChangePositive ? .green : .red)
                        }
                        
                        if let marketCap = crypto.marketCap {
                            HStack {
                                Text("Market Cap")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatLargeNumber(marketCap))
                            }
                        }
                    }
                }
            } header: {
                Text("Coin Details")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prediction Details")
                        .font(.headline)
                    
                    HStack {
                        TextField("Predicted Price", text: $predictedPrice)
                            .keyboardType(.decimalPad)
                        
                        if !predictedPrice.isEmpty, isValidInput {
                            Text(percentageChangeFormatted)
                                .foregroundColor(percentageColor)
                                .font(.subheadline)
                                .bold()
                        }
                    }
                    
                    Text("Time Frame")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(timeframePresets, id: \.self) { days in
                                Button(action: {
                                    timeframe = days
                                    showCustomTimeframe = false
                                }) {
                                    Text(formatTimeframe(days))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(timeframe == days && !showCustomTimeframe ? percentageColor : Color.secondary.opacity(0.2))
                                        .foregroundColor(timeframe == days && !showCustomTimeframe ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Button(action: {
                                showCustomTimeframe = true
                                customTimeframe = ""
                            }) {
                                Text("Custom")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(showCustomTimeframe ? percentageColor : Color.secondary.opacity(0.2))
                                    .foregroundColor(showCustomTimeframe ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if showCustomTimeframe {
                        HStack {
                            TextField("Days", text: $customTimeframe)
                                .keyboardType(.numberPad)
                                .onChange(of: customTimeframe) { newValue in
                                    if let days = Int(newValue), days > 0 {
                                        timeframe = days
                                    } else if newValue.isEmpty {
                                        timeframe = 0
                                    }
                                }
                            Text("days")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text("Prediction Details")
            }
            
            Section {
                Button(action: submitPrediction) {
                    HStack {
                        Spacer()
                        Image(systemName: direction == .up ? "arrow.up.right" : "arrow.down.right")
                        Text("Submit \(abs(percentageChange) > 0 ? percentageChangeFormatted : "Prediction")")
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(isValidInput ? percentageColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(!isValidInput)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Add Prediction")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func submitPrediction() {
        guard let predictedPriceValue = Double(predictedPrice),
              let currentPrice = crypto.currentPrice else {
            alertMessage = "Please enter a valid price"
            showAlert = true
            return
        }
        
        guard timeframe > 0 else {
            alertMessage = "Please select a valid timeframe"
            showAlert = true
            return
        }
        
        print("Creating prediction for \(crypto.name)")
        let prediction = Prediction(
            cryptoId: crypto.id,
            cryptoName: crypto.name,
            startPrice: currentPrice,
            predictedPrice: predictedPriceValue,
            direction: direction,
            timeframe: timeframe,
            date: Date()
        )
        
        viewModel.addPrediction(prediction)
        print("Prediction added, dismissing view")
        dismiss()
    }
}
