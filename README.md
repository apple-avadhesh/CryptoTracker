# CryptoTracker iOS App

A SwiftUI iOS application built with SwiftUI for tracking cryptocurrency market trends and prices in real-time.

## Features

- Real-time cryptocurrency price tracking
- Search functionality for cryptocurrencies by name or symbol
- Favorite cryptocurrencies with persistent storage
- Price prediction system with win/loss tracking
- Multiple category views:
  - All Cryptocurrencies
  - Favorites
  - Predictions
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

## Screen

<img src="https://github.com/user-attachments/assets/163eb8fc-66d8-4284-8934-e9522fe4f3c7" width="200" alt="CryptoTracker Home Screen">&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://github.com/user-attachments/assets/662d278d-e29f-4da6-85b3-ffb68e6737b6" width="200" alt="CryptoTracker Home Screen">&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://github.com/user-attachments/assets/34847355-b1ae-494b-ab52-0e0fda1a5de0" width="200" alt="CryptoTracker Home Screen">&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://github.com/user-attachments/assets/d5653894-c5ea-4482-8b87-6ced6dcac8ad" width="200" alt="CryptoTracker Home Screen">

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

## Future Improvements

- Offline mode support
- Historical price charts
- Portfolio tracking
- Additional sorting options
- Localization support

## Acknowledgments

- CoinGecko API for cryptocurrency data
- SwiftUI framework
- The iOS developer community
