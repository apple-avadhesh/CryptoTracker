# CryptoTracker iOS App

A SwiftUI iOS application built with SwiftUI for tracking cryptocurrency market trends and prices in real-time.

## Features

- Real-time cryptocurrency price tracking
- Multiple category views:
  - All Cryptocurrencies
  - All Gainers (sorted by highest gain)
  - All Losers (sorted by highest loss)
  - New Listings
  - Market Cap Categories:
    * Large Cap (>$10B)
    * Mid Cap ($1B-$10B)
    * Small Cap (<$1B)
- Clean, modern UI with dark mode support
- Price change indicators with color coding
- Market cap and 24h price change tracking

## Screenshots

<img src="https://github.com/user-attachments/assets/e4b75494-9596-408f-add4-698d5b18a030" width="300" alt="CryptoTracker Home Screen" style="margin-right: 20px"><img src="https://github.com/user-attachments/assets/692845bb-301c-4465-940e-760575fd7b57" width="300" alt="CryptoTracker Home Screen">

## Technical Details

- Platform: iOS 16.6+
- Framework: SwiftUI
- Architecture: MVVM
- API: CoinGecko Public API
- Data Updates: Auto-refresh with rate limit protection

## API Integration

The app uses the CoinGecko API v3 with the following features:
- Rate limit handling with 30-second cooldown
- Proper HTTP headers for API respect
- Error handling with user-friendly messages
- Market data endpoint for efficient data fetching

## Requirements

- iOS 16.6 or later
- Xcode 14.0 or later
- Swift 5.0 or later
- Internet connection for real-time data

## Installation

1. Clone the repository
2. Open `CryptoTracker.xcodeproj` in Xcode
3. Build and run the project

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: `Cryptocurrency.swift` - Data model for cryptocurrency information
- **Views**: 
  - `ContentView.swift` - Main view with category tabs and list
  - `CryptoRowView.swift` - Individual cryptocurrency row display
- **ViewModels**: 
  - `CryptoViewModel.swift` - Handles data fetching and business logic

## Error Handling

- Network error handling with user-friendly messages
- Rate limit detection and automatic cooldown
- Loading states with proper UI feedback

## Performance Considerations

- Efficient API usage with rate limiting
- Optimized list rendering
- Minimal network requests
- Smart data caching

## Future Improvements

- Offline mode support
- Favorite cryptocurrencies
- Price alerts
- Historical price charts
- Portfolio tracking
- Additional sorting options
- Search functionality
- Localization support

## Acknowledgments

- CoinGecko API for cryptocurrency data
- SwiftUI framework
- The iOS developer community
