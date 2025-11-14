# Project Folder Structure

## Overview

The project is organized using a **layered architecture** with clear separation of concerns. Here's the complete folder structure:

```
Coins/
├── App/                          # App entry point and assets
│   ├── Assets.xcassets/          # App icons and colors
│   │   ├── AccentColor.colorset/
│   │   └── AppIcon.appiconset/
│   └── CoinsApp.swift            # @main app entry point
│
├── Core/                         # Core application layer (MVVM)
│   ├── Model/                    # Data models
│   │   └── Coin.swift            # Coin data structure
│   │
│   ├── ViewModel/                 # Business logic and state management
│   │   └── CoinsViewModel.swift   # Main ViewModel for coin data
│   │
│   ├── View/                      # SwiftUI views
│   │   ├── ContentView.swift      # Main screen view
│   │   ├── CoinDetailView.swift  # Coin detail screen
│   │   └── Components/           # Reusable UI components
│   │       ├── CardView.swift     # Card component for stats
│   │       ├── CoinImageView.swift # Reusable image component
│   │       └── HeaderCard.swift   # Trending coin card
│   │
│   └── Utilities/                 # Helper utilities
│       └── PriceFormatter.swift   # Price formatting utilities
│
├── Services/                      # Service layer (network, API)
│   ├── CoinService.swift         # Coin API service implementation
│   └── Network/                   # Network-related code
│       └── NetworkError.swift    # Custom error types
│
└── Documentation/                 # Project documentation (optional)
    ├── CODE_REVIEW.md
    ├── CODE_WALKTHROUGH_GUIDE.md
    ├── IMPROVEMENTS_IF_MORE_TIME.md
    ├── WALKTHROUGH_CHECKLIST.md
    └── WALKTHROUGH_SCRIPT.md
```

---

## Layer Breakdown

### 1. **App Layer** (`App/`)
**Purpose:** Application entry point and assets

- `CoinsApp.swift` - The `@main` entry point that creates the app
- `Assets.xcassets/` - App icons, colors, and visual assets

**Key Point:** This is where the app starts. It's minimal and just sets up the window.

---

### 2. **Core Layer** (`Core/`)
**Purpose:** Main application logic following MVVM pattern

#### **Model** (`Core/Model/`)
- `Coin.swift` - The data model representing a cryptocurrency
  - Defines the structure of coin data
  - Contains validation logic (`isValid`)
  - Provides safe accessors for optional fields

#### **ViewModel** (`Core/ViewModel/`)
- `CoinsViewModel.swift` - Manages coin data state and business logic
  - Handles data fetching orchestration
  - Manages loading and error states
  - Contains business logic (e.g., trending coins calculation)
  - Uses dependency injection for the service

#### **View** (`Core/View/`)
- `ContentView.swift` - Main screen showing coin list and trending coins
- `CoinDetailView.swift` - Detail screen for individual coins
- `Components/` - Reusable UI components
  - `CardView.swift` - Card component for displaying stats
  - `CoinImageView.swift` - Handles image loading with error handling
  - `HeaderCard.swift` - Card for trending coins in horizontal scroll

#### **Utilities** (`Core/Utilities/`)
- `PriceFormatter.swift` - Centralized price and percentage formatting
  - Ensures consistent formatting across the app
  - Follows DRY (Don't Repeat Yourself) principle

---

### 3. **Services Layer** (`Services/`)
**Purpose:** External service integration (API calls, network)

- `CoinService.swift` - Implements `CoinServiceProtocol`
  - Handles network requests to CoinGecko API
  - Validates responses
  - Filters invalid data
  - Uses async/await for modern Swift concurrency

- `Network/NetworkError.swift` - Custom error types
  - Typed errors for different failure scenarios
  - Provides user-friendly error messages
  - Conforms to `LocalizedError`

---

## Architecture Principles

### ✅ **Separation of Concerns**
- Each layer has a single, clear responsibility
- Models handle data, ViewModels handle logic, Views handle UI
- Services handle external communication

### ✅ **Dependency Injection**
- ViewModel depends on `CoinServiceProtocol`, not `CoinService`
- Makes code testable and flexible

### ✅ **Reusability**
- Components are extracted into reusable pieces
- Utilities centralize common functionality

### ✅ **Scalability**
- Easy to add new views, models, or services
- Clear structure makes navigation simple

---

## How to Explain This Structure

### In an Interview:

> "I've organized the project using a **layered architecture** with clear separation of concerns.
>
> The **App layer** contains just the entry point and assets - it's minimal.
>
> The **Core layer** follows the **MVVM pattern**:
> - **Models** define data structures with validation
> - **ViewModels** manage state and business logic
> - **Views** are purely declarative UI
> - **Utilities** provide shared functionality
>
> The **Services layer** handles all external communication - network calls, API integration, and error handling.
>
> This structure makes the codebase maintainable, testable, and scalable. Each layer has a single responsibility, and dependencies flow in one direction - Views depend on ViewModels, ViewModels depend on Services, but Services don't depend on anything above them."

---

## File Count Summary

- **Models:** 1 file
- **ViewModels:** 1 file
- **Views:** 5 files (2 main views + 3 components)
- **Services:** 2 files
- **Utilities:** 1 file
- **App:** 1 file
- **Total:** ~11 Swift files

This is a clean, focused structure that's easy to navigate and understand.




