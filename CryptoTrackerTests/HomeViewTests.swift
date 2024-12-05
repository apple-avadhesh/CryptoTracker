import XCTest
@testable import CryptoTracker

@MainActor
class HomeViewTests: XCTestCase {
    var viewModel: CryptoViewModel!
    var homeView: HomeView!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = CryptoViewModel()
        homeView = HomeView(viewModel: viewModel)
    }
    
    func testCategoryFiltering() {
        // Create test data
        viewModel.cryptocurrencies = [
            .testMock(id: "bitcoin", name: "Bitcoin", marketCap: 500_000_000_000, priceChangePercentage24H: 5.0),
            .testMock(id: "ethereum", name: "Ethereum", marketCap: 200_000_000_000, priceChangePercentage24H: -3.0),
            .testMock(id: "dogecoin", name: "Dogecoin", marketCap: 5_000_000_000, priceChangePercentage24H: 10.0),
            .testMock(id: "solana", name: "Solana", marketCap: 500_000_000, priceChangePercentage24H: -8.0)
        ]
        
        // Test All category
        homeView.selectedCategory = .all
        XCTAssertEqual(homeView.filteredCryptos.count, 4)
        
        // Test Large Cap (>= 10B)
        homeView.selectedCategory = .largeCap
        XCTAssertEqual(homeView.filteredCryptos.count, 2)
        XCTAssertTrue(homeView.filteredCryptos.contains(where: { $0.id == "bitcoin" }))
        XCTAssertTrue(homeView.filteredCryptos.contains(where: { $0.id == "ethereum" }))
        
        // Test Mid Cap (1B-10B)
        homeView.selectedCategory = .midCap
        XCTAssertEqual(homeView.filteredCryptos.count, 1)
        XCTAssertTrue(homeView.filteredCryptos.contains(where: { $0.id == "dogecoin" }))
        
        // Test Small Cap (< 1B)
        homeView.selectedCategory = .smallCap
        XCTAssertEqual(homeView.filteredCryptos.count, 1)
        XCTAssertTrue(homeView.filteredCryptos.contains(where: { $0.id == "solana" }))
    }
    
    func testPriceChangeSorting() {
        // Create test data
        viewModel.cryptocurrencies = [
            .testMock(id: "bitcoin", name: "Bitcoin", priceChangePercentage24H: 5.0),
            .testMock(id: "ethereum", name: "Ethereum", priceChangePercentage24H: -3.0),
            .testMock(id: "dogecoin", name: "Dogecoin", priceChangePercentage24H: 10.0),
            .testMock(id: "solana", name: "Solana", priceChangePercentage24H: -8.0)
        ]
        
        // Test Top Gainers
        homeView.selectedCategory = .gainers
        XCTAssertEqual(homeView.filteredCryptos.first?.id, "dogecoin")
        XCTAssertEqual(homeView.filteredCryptos[1].id, "bitcoin")
        
        // Test Top Losers
        homeView.selectedCategory = .losers
        XCTAssertEqual(homeView.filteredCryptos.first?.id, "solana")
        XCTAssertEqual(homeView.filteredCryptos[1].id, "ethereum")
    }
    
    func testSearchFunctionality() {
        // Create test data
        viewModel.cryptocurrencies = [
            .testMock(id: "bitcoin", name: "Bitcoin", symbol: "btc"),
            .testMock(id: "ethereum", name: "Ethereum", symbol: "eth"),
            .testMock(id: "bitcoin-cash", name: "Bitcoin Cash", symbol: "bch")
        ]
        
        // Test search by name
        homeView.searchText = "Bitcoin"
        XCTAssertEqual(homeView.filteredCryptos.count, 2)
        XCTAssertTrue(homeView.filteredCryptos.contains(where: { $0.name.contains("Bitcoin") }))
        
        // Test search by symbol
        homeView.searchText = "eth"
        XCTAssertEqual(homeView.filteredCryptos.count, 1)
        XCTAssertTrue(homeView.filteredCryptos.contains(where: { $0.symbol == "eth" }))
        
        // Test empty search
        homeView.searchText = ""
        XCTAssertEqual(homeView.filteredCryptos.count, 3)
        
        // Test case insensitive search
        homeView.searchText = "bitcoin"
        XCTAssertEqual(homeView.filteredCryptos.count, 2)
    }
}
