<!-- @format -->

# Retry Logic Implementation Examples

## Option 1: Simple Retry in CoinService (Recommended)

This is the simplest and most common approach - retry logic directly in the
service layer.

```swift
class CoinService: CoinServiceProtocol {
    // MARK: - Configuration
    private let baseURL = "https://api.coingecko.com/api/v3/coins/markets"
    private let defaultCurrency = "usd"
    private let defaultOrder = "market_cap_desc"
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0 // 1 second

    func fetchCoins(page: Int = 1, perPage: Int = 20) async throws -> [Coin] {
        // Construct URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "vs_currency", value: defaultCurrency),
            URLQueryItem(name: "order", value: defaultOrder),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        // Retry logic wrapper
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                // Perform network request
                let (data, response) = try await URLSession.shared.data(from: url)

                // Validate HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                // Handle HTTP status codes
                switch httpResponse.statusCode {
                case 200...299:
                    // Success - validate and decode
                    guard !data.isEmpty else {
                        throw NetworkError.noDataAvailable
                    }

                    let decoder = JSONDecoder()
                    do {
                        let coins = try decoder.decode([Coin].self, from: data)
                        return coins.filter { $0.isValid }
                    } catch {
                        throw NetworkError.decodingError
                    }

                case 400...499:
                    // Client errors (4xx) - don't retry, throw immediately
                    throw NetworkError.requestFailed
                case 500...599:
                    // Server errors (5xx) - retry
                    throw NetworkError.serverError
                default:
                    throw NetworkError.invalidResponse
                }
            } catch let error as NetworkError {
                // Check if error is retryable
                let isRetryable = error == .serverError ||
                                 error == .invalidResponse ||
                                 error == .noDataAvailable

                if !isRetryable || attempt == maxRetries {
                    throw error
                }

                lastError = error
                // Wait before retrying
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            } catch {
                // Handle URLSession errors (network failures)
                if attempt == maxRetries {
                    throw NetworkError.unknown(error)
                }
                lastError = error
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            }
        }

        // If we get here, all retries failed
        throw lastError ?? NetworkError.unknown(NSError(domain: "CoinService", code: -1))
    }
}
```

---

## Option 2: Exponential Backoff Retry

More sophisticated version with exponential backoff (wait time increases with
each retry).

```swift
class CoinService: CoinServiceProtocol {
    // MARK: - Configuration
    private let baseURL = "https://api.coingecko.com/api/v3/coins/markets"
    private let defaultCurrency = "usd"
    private let defaultOrder = "market_cap_desc"
    private let maxRetries = 3
    private let baseDelay: TimeInterval = 1.0 // Base delay in seconds

    private func shouldRetry(error: Error) -> Bool {
        if let networkError = error as? NetworkError {
            // Only retry server errors and transient issues
            switch networkError {
            case .serverError, .invalidResponse, .noDataAvailable:
                return true
            case .invalidURL, .requestFailed, .decodingError, .unknown:
                return false
            }
        }
        // Retry URLSession errors (network failures)
        return true
    }

    private func calculateDelay(attempt: Int) -> TimeInterval {
        // Exponential backoff: 1s, 2s, 4s
        return baseDelay * pow(2.0, Double(attempt - 1))
    }

    func fetchCoins(page: Int = 1, perPage: Int = 20) async throws -> [Coin] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "vs_currency", value: defaultCurrency),
            URLQueryItem(name: "order", value: defaultOrder),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                switch httpResponse.statusCode {
                case 200...299:
                    guard !data.isEmpty else {
                        throw NetworkError.noDataAvailable
                    }

                    let decoder = JSONDecoder()
                    do {
                        let coins = try decoder.decode([Coin].self, from: data)
                        return coins.filter { $0.isValid }
                    } catch {
                        throw NetworkError.decodingError
                    }

                case 400...499:
                    throw NetworkError.requestFailed
                case 500...599:
                    throw NetworkError.serverError
                default:
                    throw NetworkError.invalidResponse
                }
            } catch {
                lastError = error

                // Check if we should retry
                if !shouldRetry(error: error) || attempt == maxRetries {
                    if let networkError = error as? NetworkError {
                        throw networkError
                    }
                    throw NetworkError.unknown(error)
                }

                // Wait with exponential backoff before retrying
                let delay = calculateDelay(attempt: attempt)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw lastError as? NetworkError ?? NetworkError.unknown(NSError(domain: "CoinService", code: -1))
    }
}
```

---

## Option 3: Reusable Retry Utility

Create a generic retry utility that can be used across different services.

**New file: `Core/Utilities/RetryHandler.swift`**

```swift
import Foundation

/// Utility for retrying async operations with configurable retry logic
struct RetryHandler {
    let maxAttempts: Int
    let baseDelay: TimeInterval
    let useExponentialBackoff: Bool

    init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0, useExponentialBackoff: Bool = true) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.useExponentialBackoff = useExponentialBackoff
    }

    /// Retries an async throwing operation
    /// - Parameters:
    ///   - operation: The async throwing operation to retry
    ///   - shouldRetry: Optional closure to determine if an error should be retried
    /// - Returns: The result of the operation
    /// - Throws: The last error if all retries fail
    func retry<T>(
        _ operation: @escaping () async throws -> T,
        shouldRetry: ((Error) -> Bool)? = nil
    ) async throws -> T {
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error

                // Check if we should retry
                let willRetry = shouldRetry?(error) ?? true
                if !willRetry || attempt == maxAttempts {
                    throw error
                }

                // Calculate delay
                let delay = useExponentialBackoff
                    ? baseDelay * pow(2.0, Double(attempt - 1))
                    : baseDelay

                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw lastError ?? NSError(domain: "RetryHandler", code: -1)
    }
}
```

**Then use it in CoinService:**

```swift
class CoinService: CoinServiceProtocol {
    private let baseURL = "https://api.coingecko.com/api/v3/coins/markets"
    private let defaultCurrency = "usd"
    private let defaultOrder = "market_cap_desc"
    private let retryHandler = RetryHandler(maxAttempts: 3, baseDelay: 1.0)

    func fetchCoins(page: Int = 1, perPage: Int = 20) async throws -> [Coin] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "vs_currency", value: defaultCurrency),
            URLQueryItem(name: "order", value: defaultOrder),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        return try await retryHandler.retry {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                guard !data.isEmpty else {
                    throw NetworkError.noDataAvailable
                }

                let decoder = JSONDecoder()
                do {
                    let coins = try decoder.decode([Coin].self, from: data)
                    return coins.filter { $0.isValid }
                } catch {
                    throw NetworkError.decodingError
                }

            case 400...499:
                throw NetworkError.requestFailed
            case 500...599:
                throw NetworkError.serverError
            default:
                throw NetworkError.invalidResponse
            }
        } shouldRetry: { error in
            // Only retry server errors and network failures
            if let networkError = error as? NetworkError {
                switch networkError {
                case .serverError, .invalidResponse, .noDataAvailable:
                    return true
                default:
                    return false
                }
            }
            // Retry URLSession errors
            return true
        }
    }
}
```

---

## Option 4: Retry in ViewModel

If you want user-facing retry control, implement it in the ViewModel:

```swift
class CoinsViewModel {
    // ... existing properties ...
    private let maxRetries = 3

    func fetchCoins() async {
        guard !loading else { return }

        loading = true
        errorMessage = nil

        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                let fetchedCoins = try await service.fetchCoins(page: 1, perPage: coinsPerPage)

                await MainActor.run {
                    self.coins = fetchedCoins
                    self.loading = false
                }
                return // Success, exit

            } catch let error as NetworkError {
                lastError = error

                // Only retry server errors
                let shouldRetry = error == .serverError && attempt < maxRetries

                if !shouldRetry {
                    await MainActor.run {
                        self.errorMessage = error.userMessage
                        self.loading = false
                    }
                    return
                }

                // Wait before retry
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            } catch {
                await MainActor.run {
                    self.errorMessage = "An unexpected error occurred. Please try again."
                    self.loading = false
                }
                return
            }
        }

        // All retries failed
        await MainActor.run {
            self.errorMessage = (lastError as? NetworkError)?.userMessage ?? "Failed after multiple attempts"
            self.loading = false
        }
    }
}
```

---

## Recommendation

**Use Option 1 or Option 2** (simple retry or exponential backoff in
CoinService):

- Keeps retry logic at the service layer
- ViewModel doesn't need to know about retries
- Automatic and transparent
- Easy to test

**Use Option 3** (utility) if:

- You plan to have multiple services that need retry logic
- You want maximum reusability and testability

**Use Option 4** (ViewModel) if:

- You need user-facing retry controls
- You want to show retry progress in the UI
