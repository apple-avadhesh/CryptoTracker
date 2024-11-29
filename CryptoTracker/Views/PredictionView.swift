import SwiftUI

struct PredictionView: View {
    let cryptocurrency: Cryptocurrency
    @ObservedObject var viewModel: CryptoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var predictedPrice: String = ""
    @State private var selectedTimeframe: Prediction.PredictionType = .oneWeek
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Price")) {
                    Text("$\(String(format: "%.2f", cryptocurrency.currentPrice))")
                        .font(.headline)
                }
                
                Section(header: Text("Timeframe")) {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Prediction.PredictionType.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                }
                
                Section(header: Text("Target Price")) {
                    TextField("Enter target price", text: $predictedPrice)
                        .keyboardType(.decimalPad)
                }
                
                Section(footer: Text("Prediction will be evaluated after \(selectedTimeframe.rawValue)")) {
                    Button("Make Prediction") {
                        makePrediction()
                    }
                }
            }
            .navigationTitle("New Prediction")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingError) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func makePrediction() {
        guard let predictedPriceValue = Double(predictedPrice) else {
            errorMessage = "Please enter a valid price"
            showingError = true
            return
        }
        
        if predictedPriceValue <= 0 {
            errorMessage = "Predicted price must be greater than zero"
            showingError = true
            return
        }
        
        let prediction = Prediction(
            cryptoId: cryptocurrency.id,
            cryptoName: cryptocurrency.name,
            cryptoSymbol: cryptocurrency.symbol,
            predictedPrice: predictedPriceValue,
            initialPrice: cryptocurrency.currentPrice,
            type: selectedTimeframe
        )
        
        viewModel.addPrediction(prediction)
        presentationMode.wrappedValue.dismiss()
    }
}
