<!-- @format -->

# How to Walk Through Your Code in an Interview

## Overview

A code walkthrough should demonstrate:

1. **Architectural understanding** - Why you made certain decisions
2. **Problem-solving** - How you solved challenges
3. **Best practices** - What patterns you used and why
4. **Self-awareness** - What you'd improve given more time

---

## Walkthrough Structure (10-15 minutes)

### 1. High-Level Architecture (2 minutes)

### 2. Core Components (5-7 minutes)

### 3. Key Decisions & Patterns (3-4 minutes)

### 4. Areas for Improvement (2 minutes)

---

## 1. High-Level Architecture Overview

### What to Say:

> "Let me start with the overall architecture. I've organized this as a SwiftUI
> app using the **MVVM pattern** with clear separation of concerns.
>
> The structure is:
>
> - **App Layer**: Entry point and app configuration
> - **Core Layer**: Models, Views, and ViewModels (business logic)
> - **Services Layer**: Network calls and API interactions
>
> This separation makes the codebase maintainable and testable."

### Show:

- Project structure in Xcode/file explorer
- Point out the folder organization

### Key Points to Emphasize:

- ✅ Clean separation of concerns
- ✅ MVVM pattern
- ✅ Modular structure

---

## 2. Walk Through Core Components

### Start with: **Model Layer** (Coin.swift)

**What to Say:**

> "Let's start with the data model. The `Coin` struct represents a
> cryptocurrency with market data. I made several defensive coding decisions
> here."

**Highlight:**

```swift
// Point out the optional fields
let marketCap: Double?
let priceChangePercent24H: Double?

// Explain why:
"Some fields are optional because the API might not always return complete data.
This prevents crashes from unexpected nil values."
```

**Show the validation:**

```swift
var isValid: Bool {
    // Walk through the validation logic
    guard !id.isEmpty, !name.isEmpty, !symbol.isEmpty else { return false }
    guard price > 0 else { return false }
    // etc.
}
```

> "I added an `isValid` property to filter out coins with invalid data before
> they reach the UI. This is defensive programming - we validate at the model
> level."

**Show safe accessors:**

```swift
var safePriceChangePercent24H: Double {
    return priceChangePercent24H ?? 0.0
}
```

> "These safe accessors provide default values, so the UI never has to deal with
> optionals directly. This keeps the views clean."

---

### Next: **Service Layer** (CoinService.swift)

**What to Say:**

> "The service layer handles all network communication. I implemented this with
> **dependency injection** in mind."

**Show the protocol:**

```swift
protocol CoinServiceProtocol {
    func fetchCoins(page: Int, perPage: Int) async throws -> [Coin]
}
```

> "I created a protocol so the ViewModel doesn't depend on a concrete
> implementation. This makes testing possible - we can inject a mock service."

**Walk through the fetch method:**

```swift
func fetchCoins(page: Int = 1, perPage: Int = 20) async throws -> [Coin] {
    // Show URL construction
    var components = URLComponents(string: baseURL)
    components?.queryItems = [...]

    // Show error handling
    guard let url = components?.url else {
        throw NetworkError.invalidURL
    }

    // Show response validation
    switch httpResponse.statusCode {
    case 200...299: break
    case 400...499: throw NetworkError.requestFailed
    case 500...599: throw NetworkError.serverError
    // etc.
    }

    // Show data validation
    return coins.filter { $0.isValid }
}
```

**Key Points:**

- ✅ Protocol-based design for testability
- ✅ Comprehensive error handling
- ✅ Data validation before returning
- ✅ Proper use of async/await

---

### Next: **ViewModel** (CoinsViewModel.swift)

**What to Say:**

> "The ViewModel is the bridge between the view and the service. It manages
> state and business logic."

**Show dependency injection:**

```swift
private let service: CoinServiceProtocol

init(service: CoinServiceProtocol = CoinService()) {
    self.service = service
}
```

> "The ViewModel accepts a service via its initializer. It defaults to the real
> `CoinService` for production, but we can inject a mock for testing. This is
> dependency injection."

**Show state management:**

```swift
@Observable
class CoinsViewModel {
    var coins: [Coin] = []
    var loading = false
    var errorMessage: String?
}
```

> "I'm using SwiftUI's `@Observable` macro for state management. The view
> automatically updates when these properties change."

**Show the fetch method:**

```swift
func fetchCoins() async {
    guard !loading else { return }  // Prevent multiple requests

    loading = true
    errorMessage = nil

    do {
        let fetchedCoins = try await service.fetchCoins(...)
        await MainActor.run {
            self.coins = fetchedCoins
            self.loading = false
        }
    } catch let error as NetworkError {
        await MainActor.run {
            self.errorMessage = error.userMessage
            self.loading = false
        }
    }
}
```

> "I ensure UI updates happen on the main thread using `MainActor.run`. The
> guard prevents multiple simultaneous requests. Error handling is specific - we
> show user-friendly messages."

**Show business logic:**

```swift
func getTrendingCoins() -> [Coin] {
    guard !coins.isEmpty else { return [] }
    return Array(coins
        .sorted { ($0.priceChangePercent24H ?? 0) > ($1.priceChangePercent24H ?? 0) }
        .prefix(trendingCount))
}
```

> "Business logic like 'trending coins' lives in the ViewModel, not the view.
> This maintains separation of concerns."

---

### Next: **View Layer** (ContentView.swift)

**What to Say:**

> "The views are declarative and focused on presentation. They don't contain
> business logic."

**Show the structure:**

```swift
struct ContentView: View {
    @State private var viewModel = CoinsViewModel()

    private var trendingCoins: [Coin] {
        viewModel.getTrendingCoins()  // Delegates to ViewModel
    }
}
```

> "The view creates a ViewModel and delegates all logic to it. The
> `trendingCoins` computed property calls the ViewModel method - no sorting
> logic in the view."

**Show error handling UI:**

```swift
if let errorMessage = viewModel.errorMessage {
    errorSection(errorMessage)  // Show error UI
} else {
    trendingSection
    coinsListSection
}
```

> "The view reacts to ViewModel state. If there's an error, we show an error
> section with a retry button. Otherwise, we show the content."

**Show reusable components:**

```swift
CoinImageView(imageURL: coin.image, size: 40)
PriceFormatter.formatPrice(coin.price)
```

> "I extracted reusable components like `CoinImageView` and `PriceFormatter` to
> avoid code duplication. This follows DRY principles."

---

### Show: **Reusable Components**

**CoinImageView:**

```swift
struct CoinImageView: View {
    let imageURL: String
    let size: CGFloat

    var body: some View {
        Group {
            if let url = URL(string: imageURL), !imageURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable()
                    case .failure: placeholderView
                    // etc.
                    }
                }
            } else {
                placeholderView
            }
        }
    }
}
```

> "This component handles all image loading edge cases - invalid URLs, loading
> states, failures. The views just pass the URL and size."

**PriceFormatter:**

```swift
enum PriceFormatter {
    static func formatPrice(_ price: Double) -> String {
        return "$\(price.formatted(.number.precision(.fractionLength(2))))"
    }
}
```

> "Centralized formatting ensures consistency. If we need to change the format,
> we change it in one place."

---

## 3. Key Decisions & Patterns

### Decision 1: Dependency Injection

**What to Say:**

> "One key decision was using dependency injection. The ViewModel doesn't create
> its own service - it receives one. This makes the code testable."

**Show the benefit:**

> "In tests, we can create a mock service that returns predictable data. In
> production, we use the real service. Same interface, different
> implementations."

---

### Decision 2: Protocol-Oriented Design

**What to Say:**

> "I used protocols for abstraction. `CoinServiceProtocol` defines the
> interface, and `CoinService` implements it. This follows the Dependency
> Inversion Principle."

---

### Decision 3: Defensive Coding

**What to Say:**

> "I added validation at multiple layers:
>
> - Model level: `isValid` property filters bad data
> - Service level: Validates HTTP responses and data
> - View level: Handles empty states and errors gracefully"

**Show examples:**

- Coin validation
- URL validation in CoinImageView
- Empty state UI

---

### Decision 4: Error Handling

**What to Say:**

> "I created a custom `NetworkError` enum with user-friendly messages. Errors
> are typed, so we can handle them specifically."

**Show NetworkError:**

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed
    case serverError
    // etc.

    var userMessage: String {
        // Returns friendly messages
    }
}
```

---

## 4. Areas for Improvement

**What to Say:**

> "Given more time, I'd add:
>
> 1. **Unit tests** - Now that we have dependency injection, testing is
>    straightforward
> 2. **Retry logic** - Automatic retry with exponential backoff for network
>    failures
> 3. **Image caching** - To improve performance and reduce bandwidth
> 4. **Localization** - Extract hardcoded strings for internationalization"

**Be specific:**

> "For example, I'd wrap the URLSession call in a retry mechanism. And I'd use
> URLCache or a library like Kingfisher for image caching."

---

## Handling Questions During Walkthrough

### If Asked: "Why did you choose MVVM?"

**Answer:**

> "MVVM fits SwiftUI well. The ViewModel manages state and business logic, while
> views are purely declarative. It's testable because ViewModels don't depend on
> views, and it scales well as the app grows."

---

### If Asked: "Why optionals in the Coin model?"

**Answer:**

> "The API might not always return complete data. Making fields optional
> prevents crashes. I added safe accessors so views don't have to handle
> optionals everywhere. This is defensive programming - we assume the API might
> be inconsistent."

---

### If Asked: "Why a protocol instead of just using CoinService directly?"

**Answer:**

> "Protocols enable dependency injection and testing. In production, we use
> `CoinService`. In tests, we can inject a mock that returns predictable data.
> This follows the Dependency Inversion Principle - depend on abstractions, not
> concretions."

---

### If Asked: "What about testing?"

**Answer:**

> "The architecture is set up for testing. With dependency injection, we can
> mock the service. The ViewModel is testable because it doesn't depend on
> SwiftUI. Given more time, I'd add unit tests for:
>
> - Network error scenarios
> - Data validation logic
> - Trending coins calculation
> - Edge cases like empty responses"

---

### If Asked: "How would you handle offline support?"

**Answer:**

> "I'd add a repository pattern that sits between the ViewModel and Service. The
> repository would:
>
> 1. Check local cache first (Core Data or SwiftData)
> 2. Fetch from API if needed
> 3. Update cache with fresh data This gives us offline support and a single
>    source of truth."

---

## Common Pitfalls to Avoid

### ❌ Don't:

1. **Apologize excessively** - "I know this is bad, but..."
2. **Read code line-by-line** - Explain concepts, not syntax
3. **Skip error handling** - This is important!
4. **Ignore edge cases** - Show you thought about them
5. **Rush through** - Take time to explain decisions

### ✅ Do:

1. **Explain the 'why'** - Not just the 'what'
2. **Show patterns** - Point out design patterns you used
3. **Acknowledge trade-offs** - "I chose X because Y, though Z would also work"
4. **Be confident** - You made good decisions, explain them
5. **Engage** - Ask if they want more detail on any part

---

## Sample Opening (30 seconds)

> "I've built a cryptocurrency market app using SwiftUI and MVVM architecture.
> Let me walk you through the key components.
>
> The app is organized into three layers:
>
> - **Models** define the data structure with defensive validation
> - **Services** handle network calls with proper error handling
> - **Views and ViewModels** manage UI state and business logic
>
> I've used dependency injection throughout to make the code testable, and I've
> focused on defensive coding to handle edge cases gracefully.
>
> Should I start with the architecture overview, or dive into a specific
> component?"

---

## Time Management

- **2 min**: Architecture overview
- **5-7 min**: Walk through key files (Model → Service → ViewModel → View)
- **3-4 min**: Explain key decisions and patterns
- **2 min**: Areas for improvement
- **2-3 min**: Q&A

**Total: ~15 minutes**

---

## Key Files to Highlight (In Order)

1. ✅ **Coin.swift** - Model with validation
2. ✅ **CoinService.swift** - Protocol and implementation
3. ✅ **NetworkError.swift** - Error handling
4. ✅ **CoinsViewModel.swift** - Dependency injection and state management
5. ✅ **ContentView.swift** - View structure
6. ✅ **CoinImageView.swift** - Reusable component example
7. ✅ **PriceFormatter.swift** - Utility pattern

---

## Remember

The goal is to show:

- ✅ **You understand architecture** - Why you organized it this way
- ✅ **You make thoughtful decisions** - Not just "it works"
- ✅ **You know best practices** - Patterns, principles, defensive coding
- ✅ **You're self-aware** - What you'd improve

You've built solid code. Now show them you understand **why** it's solid and
**how** you'd make it even better.
