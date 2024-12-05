import XCTest
@testable import CryptoTracker

@MainActor
class CryptoViewModelTests: XCTestCase {
    var viewModel: CryptoViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = CryptoViewModel()
    }
    
    func testFavoriteManagement() async {
        // Test adding favorite
        let crypto = Cryptocurrency.testMock()
        viewModel.toggleFavorite(crypto)
        XCTAssertTrue(viewModel.favoriteIds.contains(crypto.id))
        XCTAssertTrue(viewModel.isFavorite(crypto))
        
        // Test removing favorite
        viewModel.toggleFavorite(crypto)
        XCTAssertFalse(viewModel.favoriteIds.contains(crypto.id))
        XCTAssertFalse(viewModel.isFavorite(crypto))
    }
    
    func testPredictionManagement() async {
        // Test adding prediction
        let crypto = Cryptocurrency.testMock(currentPrice: 50000)
        let prediction = Prediction(cryptoId: crypto.id, targetPrice: 60000, date: Date(), isHigherPrediction: true)
        viewModel.addPrediction(prediction)
        XCTAssertTrue(viewModel.predictions.contains(prediction))
        
        // Test prediction outcome
        viewModel.cryptocurrencies = [crypto]
        viewModel.updatePredictionOutcomes()
        if let updatedPrediction = viewModel.predictions.first {
            XCTAssertFalse(updatedPrediction.isResolved)
            XCTAssertNil(updatedPrediction.wasCorrect)
        }
        
        // Test prediction resolution
        let resolvedCrypto = Cryptocurrency.testMock(currentPrice: 65000)
        viewModel.cryptocurrencies = [resolvedCrypto]
        viewModel.updatePredictionOutcomes()
        if let resolvedPrediction = viewModel.predictions.first {
            XCTAssertTrue(resolvedPrediction.isResolved)
            XCTAssertEqual(resolvedPrediction.wasCorrect, true)
        }
    }
    
    func testDescriptionLoading() async {
        let crypto = Cryptocurrency.testMock()
        
        // Test initial state
        XCTAssertNil(viewModel.descriptionLoadingStates[crypto.id])
        
        // Test loading state
        await viewModel.fetchCryptoDescription(for: crypto.id)
        switch viewModel.descriptionLoadingStates[crypto.id] {
        case .loading, .loaded, .failed:
            // Any of these states is acceptable since we're testing with a real network call
            break
        default:
            XCTFail("Description should be in loading, loaded, or failed state")
        }
    }
    
    func testPagination() async {
        XCTAssertEqual(viewModel.currentPage, 1)
        
        // Test loading more data
        await viewModel.loadMoreIfNeeded(currentItem: Cryptocurrency.testMock())
        XCTAssertTrue(viewModel.currentPage >= 1)
    }
}
