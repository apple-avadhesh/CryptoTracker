import SwiftUI

struct CryptoRowView: View {
    let cryptocurrency: Cryptocurrency
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: cryptocurrency.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(cryptocurrency.name)
                    .font(.headline)
                Text(cryptocurrency.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", cryptocurrency.currentPrice))")
                    .font(.headline)
                
                HStack {
                    Image(systemName: cryptocurrency.priceChangePercentage24H > 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(String(format: "%.1f", abs(cryptocurrency.priceChangePercentage24H)))%")
                }
                .foregroundColor(cryptocurrency.priceChangePercentage24H > 0 ? .green : .red)
                .font(.subheadline)
            }
        }
        .padding(.vertical, 8)
    }
}
