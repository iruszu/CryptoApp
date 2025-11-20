# Test Plan for Coins App

This document outlines all the tests that should be included in the test suite.

## Test Organization

Tests should be organized into separate files for each component:
- `CoinsViewModelTests.swift` - ViewModel business logic
- `CoinServiceTests.swift` - Network service (requires mocking)
- `CoinModelTests.swift` - Model validation and computed properties
- `PriceFormatterTests.swift` - Utility formatting functions
- `NetworkErrorTests.swift` - Error handling

---

## 1. CoinsViewModel Tests

### Test File: `CoinsViewModelTests.swift`

#### ✅ **fetchCoins() - Success Case**
- Test that `fetchCoins()` successfully fetches and appends coins
- Verify `loading` state changes correctly (true → false)
- Verify `errorMessage` is cleared on success
- Verify coins are appended (not replaced) for pagination
- Verify page increments correctly

#### ✅ **fetchCoins() - Error Handling**
- Test NetworkError handling (serverError, requestFailed, etc.)
- Test that `errorMessage` is set correctly for each error type
- Test that `loading` is set to false on error
- Test that coins array is not modified on error

#### ✅ **fetchCoins() - Loading State**
- Test that concurrent calls are prevented (guard !loading)
- Test that loading state prevents multiple simultaneous requests

#### ✅ **refreshCoins()**
- Test that page is reset to 0
- Test that coins array is cleared
- Test that fetchCoins() is called after reset

#### ✅ **getTrendingCoins()**
- Test that it returns empty array when coins is empty
- Test that it returns top 5 coins (trendingCount)
- Test that coins are sorted by priceChangePercent24H (descending)
- Test that it handles nil priceChangePercent24H values correctly

#### ✅ **clearError()**
- Test that errorMessage is set to nil

---

## 2. CoinService Tests

### Test File: `CoinServiceTests.swift`

**Note:** These tests require mocking URLSession. You'll need to create a mock URLSession or use a testing framework.

#### ✅ **fetchCoins() - Success**
- Test successful API response with valid JSON
- Test that URL is constructed correctly with query parameters
- Test that invalid coins are filtered out (isValid check)
- Test pagination parameters (page, perPage)

#### ✅ **fetchCoins() - Error Cases**
- Test invalidURL error (malformed baseURL)
- Test invalidResponse error (non-HTTP response)
- Test requestFailed error (4xx status codes)
- Test serverError (5xx status codes)
- Test noDataAvailable error (empty response)
- Test decodingError (malformed JSON)

#### ✅ **URL Construction**
- Test that query parameters are correctly added
- Test default values (currency, order, perPage, page)

---

## 3. Coin Model Tests

### Test File: `CoinModelTests.swift`

#### ✅ **isValid Property**
- Test valid coin (all required fields present, price > 0)
- Test invalid coin (empty id)
- Test invalid coin (empty name)
- Test invalid coin (empty symbol)
- Test invalid coin (price <= 0)
- Test invalid coin (high24H < low24H)
- Test invalid coin (invalid image URL)
- Test valid coin with nil optional fields

#### ✅ **Safe Computed Properties**
- Test `safePriceChangePercent24H` returns value or 0
- Test `safeMarketCap` returns value or 0
- Test `safeTotalVolume` returns value or 0
- Test `safeHigh24H` returns value or price
- Test `safeLow24H` returns value or price

#### ✅ **Codable Conformance**
- Test encoding to JSON
- Test decoding from JSON with all fields
- Test decoding from JSON with missing optional fields
- Test that CodingKeys map correctly

---

## 4. PriceFormatter Tests

### Test File: `PriceFormatterTests.swift`

#### ✅ **formatPrice()**
- Test formatting positive prices
- Test formatting large prices (thousands, millions)
- Test formatting small prices (decimals)
- Test formatting zero
- Test that it always includes 2 decimal places

#### ✅ **formatPercentChange()**
- Test positive percentages (includes + sign)
- Test negative percentages (includes - sign)
- Test zero percentage
- Test large percentages
- Test that it always includes 2 decimal places

#### ✅ **formatCompact()**
- Test formatting billions (e.g., 1.2B)
- Test formatting millions (e.g., 285M)
- Test formatting thousands (e.g., 5.5K)
- Test formatting small values (< 1000)

---

## 5. NetworkError Tests

### Test File: `NetworkErrorTests.swift`

#### ✅ **Error Messages**
- Test that each error case has a user-friendly message
- Test that `userMessage` returns the error description
- Test that `unknown` error includes the underlying error description

#### ✅ **LocalizedError Conformance**
- Test that `errorDescription` is not nil for all cases

---

## Mock Objects Needed

### MockCoinService
```swift
class MockCoinService: CoinServiceProtocol {
    var fetchCoinsResult: Result<[Coin], NetworkError> = .success([])
    var fetchCoinsCallCount = 0
    var lastPage: Int?
    var lastPerPage: Int?
    
    func fetchCoins(page: Int, perPage: Int) async throws -> [Coin] {
        fetchCoinsCallCount += 1
        lastPage = page
        lastPerPage = perPage
        
        switch fetchCoinsResult {
        case .success(let coins):
            return coins
        case .failure(let error):
            throw error
        }
    }
}
```

### Sample Test Data
```swift
extension Coin {
    static let sampleCoin = Coin(
        id: "bitcoin",
        name: "Bitcoin",
        symbol: "btc",
        image: "https://example.com/bitcoin.png",
        price: 45000.0,
        marketCap: 850000000000,
        marketCapRank: 1,
        totalVolume: 25000000000,
        high24H: 46000.0,
        low24H: 44000.0,
        priceChange24H: 2000.0,
        priceChangePercent24H: 4.5,
        circulatingSupply: 19000000
    )
    
    static let invalidCoin = Coin(
        id: "",
        name: "Invalid",
        symbol: "inv",
        image: "",
        price: -100.0,
        marketCap: nil,
        marketCapRank: nil,
        totalVolume: nil,
        high24H: nil,
        low24H: nil,
        priceChange24H: nil,
        priceChangePercent24H: nil,
        circulatingSupply: nil
    )
}
```

---

## Test Execution Order Priority

1. **High Priority** (Core functionality):
   - ViewModel: fetchCoins success/error
   - Coin: isValid validation
   - PriceFormatter: all formatting functions

2. **Medium Priority** (Edge cases):
   - ViewModel: getTrendingCoins, refreshCoins
   - Coin: safe computed properties
   - NetworkError: error messages

3. **Lower Priority** (Integration):
   - CoinService: requires URLSession mocking setup
   - Full integration tests

---

## Example Test Structure (Swift Testing)

```swift
import Testing
@testable import Coins

struct CoinsViewModelTests {
    
    @Test("Fetch coins successfully appends to array")
    func testFetchCoinsSuccess() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .success([.sampleCoin])
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        #expect(viewModel.coins.count == 1)
        #expect(viewModel.loading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Fetch coins handles network error")
    func testFetchCoinsError() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .failure(.serverError)
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        #expect(viewModel.coins.isEmpty)
        #expect(viewModel.loading == false)
        #expect(viewModel.errorMessage != nil)
    }
}
```

---

## Notes

- Use dependency injection to inject mock services
- Test edge cases (empty arrays, nil values, boundary conditions)
- Test error scenarios thoroughly
- Keep tests isolated and independent
- Use descriptive test names that explain what is being tested

