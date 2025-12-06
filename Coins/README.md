<!-- @format -->

# Coins

A native iOS cryptocurrency market tracking application built with SwiftUI.
Displays real-time cryptocurrency prices, market data, and historical
information from the CoinGecko API.

## Features

- **Market Overview**: Browse cryptocurrencies sorted by market capitalization
- **Search**: Real-time search across the entire CoinGecko database with
  debounced API calls
- **Filtering**: Filter coins by top gainers, top losers, highest/lowest price
- **Trending Coins**: Horizontal scrollable cards showing top trending
  cryptocurrencies
- **Coin Details**: Detailed view with price, market statistics, and historical
  data
- **Glass Morphism UI**: Modern glass effect styling using native SwiftUI APIs
- **Dark Mode Support**: Semantic color usage for automatic light/dark mode
  adaptation

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern with clear separation of
concerns:

- **Models**: `Coin`, `SearchResult` - Data structures representing
  cryptocurrency information
- **Views**: SwiftUI views organized by feature (`ContentView`,
  `CoinDetailView`, reusable components)
- **ViewModels**: `CoinsViewModel` - Business logic and state management using
  Swift's `@Observable` macro
- **Services**: `CoinService` - Protocol-based networking layer for API
  interactions
- **Utilities**: `PriceFormatter` - Formatting utilities for prices and
  percentages

## Technical Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **iOS Version**: iOS 17+ (uses native `@Observable` and `glassEffect` APIs)
- **API**: CoinGecko API v3
- **Architecture**: MVVM with protocol-oriented design
- **Testing**: Unit tests for models, view models, and utilities

## Project Structure

```
Coins/
├── App/
│   └── CoinsApp.swift          # App entry point
├── Core/
│   ├── Model/                  # Data models
│   ├── View/                   # SwiftUI views
│   │   ├── Components/         # Reusable UI components
│   │   └── ContentView.swift   # Main market view
│   ├── ViewModel/              # ViewModels
│   └── Utilities/              # Helper utilities
├── Services/
│   └── CoinService.swift       # API service layer
└── CoinTests/                  # Unit tests
```

## API Integration

The app integrates with CoinGecko's free API:

- `/coins/markets` - Fetch market data for cryptocurrencies
- `/search` - Search for coins by name or symbol
- `/coins/{id}/market_chart` - Historical price, market cap, and volume data

All network requests use async/await with proper error handling and
user-friendly error messages.

## Key Components

- **HeaderCard**: Glass effect card displaying trending coin information
- **CoinRowView**: List item showing coin name, symbol, price, and 24h change
- **CardView**: Reusable card component for displaying key-value statistics
- **CoinDetailView**: Comprehensive detail view with market statistics

## Testing

Unit tests are provided for:

- Model validation (`CoinModelTests`)
- ViewModel logic (`CoinsViewModelTests`)
- Price formatting (`PriceFormatterTests`)
- Coin data validation (`CoinTests`)

## Requirements

- Xcode 15.4 or later
- iOS 17.0 or later
- Swift 5.9 or later

## License

Copyright (c) 2025 Kellie Ho
