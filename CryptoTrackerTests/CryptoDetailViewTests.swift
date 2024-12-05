import XCTest
import SwiftUI
@testable import CryptoTracker

// Test helper extension
extension Cryptocurrency {
  static func testMock(
    id: String = "bitcoin",
    symbol: String = "btc",
    name: String = "Bitcoin",
    image: String = "https://example.com/image.png",
    description: String? = nil,
    currentPrice: Double? = nil,
    marketCap: Double? = nil,
    marketCapRank: Int? = nil,
    totalVolume: Double? = nil,
    high24H: Double? = nil,
    low24H: Double? = nil,
    priceChange24H: Double? = nil,
    priceChangePercentage24H: Double? = nil,
    lastUpdated: String? = nil
  ) -> Cryptocurrency {
    let json = """
        {
            "id": "\(id)",
            "symbol": "\(symbol)",
            "name": "\(name)",
            "image": "\(image)",
            "current_price": \(currentPrice?.description ?? "null"),
            "market_cap": \(marketCap?.description ?? "null"),
            "market_cap_rank": \(marketCapRank?.description ?? "null"),
            "total_volume": \(totalVolume?.description ?? "null"),
            "high_24h": \(high24H?.description ?? "null"),
            "low_24h": \(low24H?.description ?? "null"),
            "price_change_24h": \(priceChange24H?.description ?? "null"),
            "price_change_percentage_24h": \(priceChangePercentage24H?.description ?? "null"),
            "last_updated": \(lastUpdated.map { "\"\($0)\"" } ?? "null")
        }
        """

    let data = json.data(using: .utf8)!
    return try! JSONDecoder().decode(Cryptocurrency.self, from: data)
  }
}

@available(iOS 16.0, *)
class CryptoDetailViewTests: XCTestCase {
  var viewModel: CryptoViewModel!
  var cryptocurrency: Cryptocurrency!

  override func setUp() async throws {
    try await super.setUp()
    // Initialize the view model and cryptocurrency with mock data
    viewModel = await CryptoViewModel()
    cryptocurrency = .testMock(marketCap: 1_500_000_000, totalVolume: 750_000_000)
  }

  func testMarketCapFormatting() {
    let view = CryptoDetailView(cryptocurrency: cryptocurrency, viewModel: viewModel)
    XCTAssertEqual(view.marketCapFormattedForTesting, "$1.5B")

    let cryptocurrency2 = Cryptocurrency.testMock(marketCap: 500_000, totalVolume: 750_000_000)
    let view2 = CryptoDetailView(cryptocurrency: cryptocurrency2, viewModel: viewModel)
    XCTAssertEqual(view2.marketCapFormattedForTesting, "$500000")

    let cryptocurrency3 = Cryptocurrency.testMock(marketCap: nil, totalVolume: 750_000_000)
    let view3 = CryptoDetailView(cryptocurrency: cryptocurrency3, viewModel: viewModel)
    XCTAssertEqual(view3.marketCapFormattedForTesting, "--")
  }

  func testVolumeFormatting() {
    let view = CryptoDetailView(cryptocurrency: cryptocurrency, viewModel: viewModel)
    XCTAssertEqual(view.volumeFormattedForTesting, "$750.0M")

    let cryptocurrency2 = Cryptocurrency.testMock(marketCap: 1_500_000_000, totalVolume: 500_000)
    let view2 = CryptoDetailView(cryptocurrency: cryptocurrency2, viewModel: viewModel)
    XCTAssertEqual(view2.volumeFormattedForTesting, "$500000")

    let cryptocurrency3 = Cryptocurrency.testMock(marketCap: 1_500_000_000, totalVolume: nil)
    let view3 = CryptoDetailView(cryptocurrency: cryptocurrency3, viewModel: viewModel)
    XCTAssertEqual(view3.volumeFormattedForTesting, "--")
  }

  func testPriceFormatting() {
    // Test regular price
    let crypto1 = Cryptocurrency.testMock(currentPrice: 45678.90)
    XCTAssertEqual(crypto1.formattedCurrentPrice, "$45678.90")

    // Test large price
    let crypto2 = Cryptocurrency.testMock(currentPrice: 1234567.89)
    XCTAssertEqual(crypto2.formattedCurrentPrice, "$1234567.89")

    // Test small price
    let crypto3 = Cryptocurrency.testMock(currentPrice: 0.12345)
    XCTAssertEqual(crypto3.formattedCurrentPrice, "$0.12")

    // Test nil price
    let crypto4 = Cryptocurrency.testMock(currentPrice: nil)
    XCTAssertEqual(crypto4.formattedCurrentPrice, "--")
  }

  func testPriceChangeFormatting() {
    // Test positive change
    let crypto1 = Cryptocurrency.testMock(priceChangePercentage24H: 5.67)
    XCTAssertEqual(crypto1.formattedPriceChange, "5.7%")
    XCTAssertTrue(crypto1.isPriceChangePositive)

    // Test negative change
    let crypto2 = Cryptocurrency.testMock(priceChangePercentage24H: -3.21)
    XCTAssertEqual(crypto2.formattedPriceChange, "3.2%")
    XCTAssertFalse(crypto2.isPriceChangePositive)

    // Test nil change (should be considered positive as it defaults to 0)
    let crypto3 = Cryptocurrency.testMock(priceChangePercentage24H: nil)
    XCTAssertEqual(crypto3.formattedPriceChange, "--")
    XCTAssertTrue(crypto3.isPriceChangePositive)

    // Test zero change (should be considered positive)
    let crypto4 = Cryptocurrency.testMock(priceChangePercentage24H: 0.0)
    XCTAssertEqual(crypto4.formattedPriceChange, "0.0%")
    XCTAssertTrue(crypto4.isPriceChangePositive)
  }

  func testMarketCapRankFormatting() throws {
    let view1 = CryptoDetailView(cryptocurrency: Cryptocurrency.testMock(marketCapRank: 1), viewModel: viewModel)
    let rank1 = try XCTUnwrap(view1.cryptocurrency.marketCapRank)
    XCTAssertEqual("#\(rank1)", "#1")

    let view2 = CryptoDetailView(cryptocurrency: Cryptocurrency.testMock(marketCapRank: nil), viewModel: viewModel)
    XCTAssertNil(view2.cryptocurrency.marketCapRank)
  }

  func testSymbolFormatting() {
    let view = CryptoDetailView(cryptocurrency: cryptocurrency, viewModel: viewModel)
    XCTAssertEqual(view.cryptocurrency.symbol.uppercased(), "BTC")

    let view2 = CryptoDetailView(cryptocurrency: Cryptocurrency.testMock(symbol: "eth"), viewModel: viewModel)
    XCTAssertEqual(view2.cryptocurrency.symbol.uppercased(), "ETH")
  }
}
