import SwiftUI

struct AddPredictionView: View {
  let cryptocurrency: Cryptocurrency
  @ObservedObject var viewModel: CryptoViewModel
  @Binding var isPresented: Bool

  @State private var predictedPrice: String = ""
  @State private var selectedTimeframe = 7
  @State private var showError = false
  @State private var errorMessage = ""

  private let timeframes = [1, 7, 14, 30]

  private var currentPrice: Double {
    cryptocurrency.currentPrice ?? 0
  }

  private var predictedPriceDouble: Double? {
    Double(predictedPrice.replacingOccurrences(of: ",", with: ""))
  }

  private var priceChange: Double? {
    guard let predicted = predictedPriceDouble else { return nil }
    return ((predicted - currentPrice) / currentPrice) * 100
  }

  private var direction: PriceDirection? {
    guard let change = priceChange else { return nil }
    return change >= 0 ? .up : .down
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Current Price")) {
          HStack {
            Text(cryptocurrency.formattedCurrentPrice)
              .font(.headline)
            Spacer()
            Text(cryptocurrency.symbol.uppercased())
              .foregroundColor(.secondary)
          }
        }

        Section(header: Text("Your Prediction")) {
          HStack {
            Text("$")
            TextField("Enter predicted price", text: $predictedPrice)
              .keyboardType(.decimalPad)
          }

          if let change = priceChange {
            HStack {
              Text("Price Change")
              Spacer()
              Text(String(format: "%.1f%%", change))
                .foregroundColor(change >= 0 ? .green : .red)
            }
          }
        }

        Section(header: Text("Timeframe")) {
          Picker("Prediction Duration", selection: $selectedTimeframe) {
            ForEach(timeframes, id: \.self) { days in
              Text("\(days) \(days == 1 ? "day" : "days")")
            }
          }
          .pickerStyle(.segmented)
        }

        Section {
          Button(action: submitPrediction) {
            Text("Submit Prediction")
              .frame(maxWidth: .infinity)
              .foregroundColor(.white)
          }
          .listRowBackground(Color.blue)
        }
      }
      .navigationTitle("New Prediction")
      .navigationBarItems(
        trailing: Button("Cancel") {
          isPresented = false
        }
      )
      .alert("Error", isPresented: $showError) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(errorMessage)
      }
    }
  }

  private func submitPrediction() {
    guard let predictedPrice = predictedPriceDouble,
          let direction = direction else {
      showError = true
      errorMessage = "Please enter a valid price"
      return
    }

    let prediction = Prediction(
      cryptoId: cryptocurrency.id,
      cryptoName: cryptocurrency.name,
      startPrice: currentPrice,
      predictedPrice: predictedPrice,
      direction: direction,
      timeframe: selectedTimeframe,
      date: Date()
    )

    viewModel.addPrediction(prediction)
    isPresented = false
  }
}
