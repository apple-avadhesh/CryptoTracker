import SwiftUI

struct PredictionView: View {
  @ObservedObject var viewModel: CryptoViewModel
  let prediction: Prediction

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(prediction.cryptoName)
          .font(.headline)
        Spacer()
        Text(prediction.timeRemaining)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      HStack {
        VStack(alignment: .leading) {
          Text("Start Price")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(String(format: "$%.2f", prediction.startPrice))
        }

        Spacer()

        VStack(alignment: .trailing) {
          Text("Target Price")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(String(format: "$%.2f", prediction.predictedPrice))
        }
      }

      HStack {
        Text("Direction: \(prediction.direction == .up ? "Up" : "Down")")
          .font(.subheadline)
          .foregroundColor(prediction.direction == .up ? .green : .red)

        Spacer()

        if let outcome = prediction.outcome {
          switch outcome {
          case .correct:
            Label("Correct", systemImage: "checkmark.circle.fill")
              .foregroundColor(.green)
          case .incorrect:
            Label("Incorrect", systemImage: "xmark.circle.fill")
              .foregroundColor(.red)
          case .pending:
            Label("Pending", systemImage: "clock.fill")
              .foregroundColor(.orange)
          }
        }
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(10)
    .shadow(radius: 2)
  }
}
