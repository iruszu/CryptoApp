# Code Walkthrough Script - Exact Dialogue

## Opening (30 seconds)

> "Hi! I'm excited to walk you through my cryptocurrency market app. I've built this using SwiftUI with an MVVM architecture. The app fetches real-time cryptocurrency data from the CoinGecko API and displays it in a clean, user-friendly interface.
>
> I've organized the code into three main layers: Models for data structures, Services for network calls, and Views with ViewModels for the UI and business logic. I've also focused on defensive coding and proper error handling throughout.
>
> Would you like me to start with the overall architecture, or dive right into a specific component?"

---

## 1. Coin Model (Coin.swift) - 2 minutes

> "Let me start with the data model - this is `Coin.swift`. This struct represents a cryptocurrency with all its market data."

**[Scroll to show the struct definition]**

> "You'll notice that some fields are optional - like `marketCap`, `priceChangePercent24H`, and `high24H`. I made these optional because the API might not always return complete data for every coin. This is defensive programming - it prevents crashes from unexpected nil values."

**[Point to the optional fields]**

> "The essential fields like `id`, `name`, `symbol`, and `price` are required because we always need those. But market data can be missing sometimes."

**[Scroll down to the `isValid` property]**

> "I added an `isValid` computed property that validates the coin data. Let me walk through this:"

**[Read through the validation]**

> "First, it checks that essential fields aren't empty - the id, name, and symbol. Then it ensures the price is positive - coins can't have negative prices. If we have 24-hour high and low values, it validates that the high is greater than or equal to the low, which makes logical sense. And finally, if there's an image URL, it validates that it's a valid URL format."

**[Scroll to safe accessors]**

> "I also added these safe accessor properties - like `safePriceChangePercent24H`. These provide default values when the optional is nil. So instead of the view having to deal with optionals everywhere, it can just use `coin.safePriceChangePercent24H` and get zero if the value is missing. This keeps the views clean and prevents crashes."

**[Point to one of the safe accessors]**

> "The views never have to write `coin.priceChangePercent24H ?? 0` - that logic is encapsulated here in the model. This follows the principle of keeping business logic out of views."

---

## 2. CoinService (CoinService.swift) - 2.5 minutes

> "Now let's look at the service layer - `CoinService.swift`. This handles all the network communication with the CoinGecko API."

**[Scroll to the protocol]**

> "First, I defined a protocol called `CoinServiceProtocol`. This is important for dependency injection. The protocol defines the interface - it says 'anything that implements this must have a `fetchCoins` method that takes page and perPage parameters and returns an array of coins.'"

**[Point to the protocol]**

> "Then `CoinService` implements this protocol. The key benefit is that the ViewModel depends on the protocol, not the concrete class. This means in tests, we can create a mock service that implements the same protocol and returns predictable test data. In production, we use the real `CoinService`. Same interface, different implementations."

**[Scroll to the fetchCoins method]**

> "Let me walk through the `fetchCoins` method. This is where the actual network call happens."

**[Point to URL construction]**

> "First, I construct the URL using `URLComponents`. This is safer than string concatenation because it properly handles query parameters and encoding. I'm building the CoinGecko API endpoint with parameters for currency, ordering, page size, and page number."

**[Point to the guard statement]**

> "I validate that we have a valid URL before making the request. If the URL construction fails, we throw a `NetworkError.invalidURL`."

**[Scroll to the network call]**

> "Then I make the actual network request using `URLSession.shared.data`. This is async/await, which is the modern Swift way of handling asynchronous operations."

**[Scroll to response validation]**

> "After getting the response, I validate it. First, I check that we actually got an HTTP response by casting it to `HTTPURLResponse`. If not, we throw an `invalidResponse` error."

**[Point to the switch statement]**

> "Then I handle different HTTP status codes. 200-299 means success. 400-499 are client errors - like bad requests - so I throw `requestFailed`. 500-599 are server errors, so I throw `serverError` specifically. This gives us granular error handling."

**[Scroll to data validation]**

> "I also check that the data isn't empty before trying to decode it. If it is, we throw `noDataAvailable`."

**[Scroll to decoding]**

> "Then I decode the JSON into an array of `Coin` objects. If decoding fails, I catch the error and throw a `decodingError` instead. This wraps the generic decoding error in our typed error system."

**[Point to the filter]**

> "Finally, and this is important - I filter the decoded coins using that `isValid` property we saw earlier. So even if the API returns some invalid data, we filter it out before it reaches the UI. This is defensive coding at the service layer."

> "The method is marked as `throws`, so any errors propagate up to the ViewModel, which can then handle them appropriately and show user-friendly messages."

---

## 3. NetworkError (NetworkError.swift) - 1 minute

> "Before we move to the ViewModel, let me quickly show you the error handling. This is `NetworkError.swift`."

**[Show the enum]**

> "I created a custom error enum that conforms to `LocalizedError`. This gives us typed errors instead of generic error messages."

**[Point to the cases]**

> "We have specific cases for different failure scenarios - invalid URL, request failed, server error, no data, decoding error, and an unknown case that wraps other errors."

**[Scroll to userMessage]**

> "Each error has a `userMessage` property that returns a user-friendly description. So instead of showing 'NetworkError.requestFailed' to the user, we show 'Request failed. Please check your internet connection and try again.' This is much better UX."

> "The ViewModel uses these messages directly, so users always see helpful, actionable error messages."

---

## 4. CoinsViewModel (CoinsViewModel.swift) - 3 minutes

> "Now let's look at the ViewModel - `CoinsViewModel.swift`. This is the bridge between the view and the service. It manages state and contains business logic."

**[Point to @Observable]**

> "I'm using SwiftUI's `@Observable` macro. This automatically makes the class observable, so when these properties change, the view automatically updates. It's the modern SwiftUI way of managing state."

**[Point to the properties]**

> "The ViewModel has three main state properties: `coins` - the array of coins we're displaying, `loading` - a boolean for loading state, and `errorMessage` - an optional string for error messages."

**[Scroll to the service property]**

> "Here's the key part - the service is stored as `CoinServiceProtocol`, not `CoinService`. This is dependency injection. The ViewModel doesn't know or care about the concrete implementation."

**[Scroll to the initializer]**

> "The initializer takes a `CoinServiceProtocol` parameter, but it defaults to `CoinService()` for production use. So in normal usage, we just create `CoinsViewModel()` and it works. But in tests, we can inject a mock service. This is dependency injection with a default parameter - it's convenient but still testable."

**[Scroll to fetchCoins]**

> "Let me walk through the `fetchCoins` method. This is where the ViewModel orchestrates the data fetching."

**[Point to the guard]**

> "First, there's a guard statement that prevents multiple simultaneous requests. If we're already loading, we just return early. This prevents race conditions and unnecessary network calls."

**[Point to loading state]**

> "Then I set `loading = true` and clear any previous error messages. This updates the UI to show a loading state."

**[Point to the do-catch]**

> "I call the service's `fetchCoins` method inside a do-catch block. If it succeeds, I get an array of coins."

**[Point to MainActor.run]**

> "I update the state on the main thread using `MainActor.run`. This is important because UI updates must happen on the main thread, and the network call happens on a background thread. This ensures thread safety."

**[Point to error handling]**

> "If there's an error, I check if it's a `NetworkError` specifically. If it is, I use the `userMessage` property we saw earlier to get a user-friendly message. If it's some other unexpected error, I show a generic message."

**[Scroll to getTrendingCoins]**

> "Here's another important method - `getTrendingCoins`. This calculates which coins are trending based on 24-hour price change percentage."

**[Read through the method]**

> "It checks if we have coins, then sorts them by price change percentage in descending order, and takes the top 5. This is business logic, and it lives in the ViewModel, not in the view. This maintains separation of concerns."

**[Point to the optional handling]**

> "Notice I'm using the nil-coalescing operator here - `priceChangePercent24H ?? 0`. This handles the optional safely. If a coin doesn't have a price change percentage, it's treated as zero for sorting purposes."

> "The view just calls `viewModel.getTrendingCoins()` - it doesn't know or care how the calculation works. That's proper separation of concerns."

---

## 5. ContentView (ContentView.swift) - 3 minutes

> "Now let's look at the main view - `ContentView.swift`. This is where the UI is defined."

**[Point to the ViewModel]**

> "The view creates a ViewModel as a `@State` property. This is the view's connection to the business logic."

**[Scroll to trendingCoins]**

> "I have a computed property called `trendingCoins` that calls `viewModel.getTrendingCoins()`. This delegates to the ViewModel - the view doesn't contain any sorting or filtering logic. It just asks the ViewModel for the data it needs."

**[Scroll to the body]**

> "The body of the view is a `NavigationStack` with a `ScrollView`. Inside, I conditionally show either an error section or the content."

**[Point to the if-else]**

> "If there's an error message, we show the error section with a retry button. Otherwise, we show the trending coins and the full coin list. This is reactive - the view automatically updates when `viewModel.errorMessage` changes because of the `@Observable` macro."

**[Point to refreshable]**

> "I added a `refreshable` modifier, so users can pull to refresh the data. This calls `viewModel.fetchCoins()` again."

**[Point to .task]**

> "The `.task` modifier automatically calls `fetchCoins()` when the view appears. This is SwiftUI's way of handling async work on view appearance."

**[Scroll to errorSection]**

> "Let me show you the error section. If there's an error, we display an icon, the error message, and a retry button. The retry button creates a new Task and calls `fetchCoins()` again. This gives users a way to recover from errors."

**[Scroll to CoinRowView]**

> "I extracted the coin row into a separate component called `CoinRowView`. This keeps the main view clean and makes the code more reusable."

**[Point to CoinImageView]**

> "Notice we're using `CoinImageView` here instead of `AsyncImage` directly. This is a reusable component I created that handles all the edge cases for image loading - invalid URLs, loading states, failures. The view just passes the URL and size, and the component handles everything else."

**[Point to PriceFormatter]**

> "Similarly, we're using `PriceFormatter.formatPrice` and `formatPercentChange` instead of inline formatting. This ensures consistency - if we need to change how prices are displayed, we change it in one place. This follows the DRY principle - Don't Repeat Yourself."

**[Scroll to emptyStateView]**

> "I also added an empty state view. If we have no coins and we're not loading, we show a friendly message. This handles the edge case gracefully instead of showing a blank screen."

---

## 6. Reusable Components - 1.5 minutes

> "Let me quickly show you a couple of the reusable components I created."

**[Open CoinImageView.swift if possible, or describe it]**

> "`CoinImageView` is a wrapper around `AsyncImage` that handles all the edge cases. It checks if the URL is valid before trying to load it. It handles the different phases of `AsyncImage` - empty, success, and failure - and shows a placeholder for failures or invalid URLs. This component is used in three different places in the app, so extracting it eliminated code duplication."

**[Open PriceFormatter.swift if possible, or describe it]**

> "`PriceFormatter` is a utility enum with static methods for formatting prices and percentages. All price formatting goes through these methods, so if we need to change the format - say, add thousand separators or change decimal places - we change it in one place. This ensures consistency across the entire app."

---

## 7. Key Decisions Summary - 2 minutes

> "Let me summarize the key architectural decisions I made:"

> "**First, dependency injection.** The ViewModel accepts a service protocol, not a concrete class. This makes the code testable. We can inject a mock service in tests and the real service in production."

> "**Second, protocol-oriented design.** I used protocols for abstraction. The `CoinServiceProtocol` defines the interface, and `CoinService` implements it. This follows the Dependency Inversion Principle - we depend on abstractions, not concretions."

> "**Third, defensive coding.** I added validation at multiple layers. The model has an `isValid` property. The service validates HTTP responses and filters invalid data. The views handle empty states and errors gracefully. This prevents crashes from unexpected data."

> "**Fourth, separation of concerns.** Business logic lives in the ViewModel. Views are purely declarative. Services handle network calls. Models handle data validation. Each layer has a single responsibility."

> "**Fifth, error handling.** I created a typed error system with user-friendly messages. Errors are handled at the appropriate layer and surfaced to users in a helpful way."

> "**Sixth, code reusability.** I extracted common patterns into reusable components and utilities. This follows DRY principles and makes the codebase more maintainable."

---

## 8. Areas for Improvement - 1.5 minutes

> "Given more time, there are a few things I'd add:"

> "**First, comprehensive unit tests.** Now that we have dependency injection, testing is straightforward. I'd write tests for the ViewModel logic, network error scenarios, and data validation."

> "**Second, network resilience.** I'd add retry logic with exponential backoff for transient network failures. Currently, users have to manually retry, but automatic retries would improve the experience."

> "**Third, performance optimization.** I'd add image caching to reduce bandwidth and improve load times. I'd also consider pagination if we scale beyond 20 coins."

> "**Fourth, localization.** I'd extract all hardcoded strings to a localization system for internationalization support."

> "**Fifth, accessibility.** I'd add VoiceOver labels to all interactive elements for inclusive design."

> "But the current implementation has a solid foundation - good architecture, proper error handling, and defensive coding. These improvements would build on that foundation."

---

## Closing (30 seconds)

> "That's the core architecture of the app. The key strengths are dependency injection for testability, defensive coding for reliability, and clear separation of concerns for maintainability. The code is production-ready and follows Swift and SwiftUI best practices."

> "Are there any specific areas you'd like me to dive deeper into, or any questions about the implementation?"

---

## Tips for Delivery

1. **Speak naturally** - Don't read this word-for-word. Use it as a guide.
2. **Point to code** - Actually scroll and point to the lines you're discussing.
3. **Pause for questions** - If they ask something, answer it, then continue.
4. **Show enthusiasm** - You're proud of your work - let it show!
5. **Be confident** - You made good decisions. Explain them with confidence.

---

## If They Ask Questions During Walkthrough

**"Why did you use optionals?"**
> "The API might not always return complete data. Making fields optional prevents crashes. I added safe accessors so views don't have to handle optionals everywhere."

**"Why a protocol?"**
> "Protocols enable dependency injection and testing. We can inject a mock in tests and the real service in production. It follows the Dependency Inversion Principle."

**"What about testing?"**
> "The architecture is set up for testing. With dependency injection, we can mock the service. Given more time, I'd add unit tests for error scenarios and edge cases."

**"How would you handle offline?"**
> "I'd add a repository pattern between the ViewModel and Service. The repository would check local cache first, then fetch from API if needed, and update the cache. This gives offline support."

---

**Remember: You've built solid code. Walk through it with confidence!** 🚀

