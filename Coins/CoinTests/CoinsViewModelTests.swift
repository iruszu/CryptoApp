//
//  CoinsViewModelTests.swift
//  CoinTests
//
//  Created by Kellie Ho on 2025-11-19.
//

import Testing
@testable import Coins

// MARK: - Mock Service

/// Mock implementation of CoinServiceProtocol for testing
class MockCoinService: CoinServiceProtocol {
    var fetchCoinsResult: Result<[Coin], NetworkError> = .success([])
    var fetchCoinsCallCount = 0
    var lastPage: Int?
    var lastPerPage: Int?
    var delayNanoseconds: UInt64 = 0 // Delay to simulate network latency
    
    func fetchCoins(page: Int, perPage: Int) async throws -> [Coin] {
        fetchCoinsCallCount += 1
        lastPage = page
        lastPerPage = perPage
        
        // Simulate network delay if specified
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        
        switch fetchCoinsResult {
        case .success(let coins):
            return coins
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Test Data

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
    
    static let ethereumCoin = Coin(
        id: "ethereum",
        name: "Ethereum",
        symbol: "eth",
        image: "https://example.com/ethereum.png",
        price: 3000.0,
        marketCap: 360000000000,
        marketCapRank: 2,
        totalVolume: 15000000000,
        high24H: 3100.0,
        low24H: 2900.0,
        priceChange24H: 100.0,
        priceChangePercent24H: 3.3,
        circulatingSupply: 120000000
    )
    
    static let cardanoCoin = Coin(
        id: "cardano",
        name: "Cardano",
        symbol: "ada",
        image: "https://example.com/cardano.png",
        price: 1.5,
        marketCap: 50000000000,
        marketCapRank: 3,
        totalVolume: 2000000000,
        high24H: 1.6,
        low24H: 1.4,
        priceChange24H: -0.1,
        priceChangePercent24H: -6.7,
        circulatingSupply: 33000000000
    )
}

// MARK: - ViewModel Tests

struct CoinsViewModelTests {
    
    // MARK: - fetchCoins() Success Tests
    
    @Test("Fetch coins successfully appends to array")
    func testFetchCoinsSuccess() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .success([.sampleCoin])
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        await MainActor.run {
            #expect(viewModel.coins.count == 1)
            #expect(viewModel.coins.first?.id == "bitcoin")
            #expect(viewModel.loading == false)
            #expect(viewModel.errorMessage == nil)
        }
    }
    
    @Test("Fetch coins appends for pagination")
    func testFetchCoinsPagination() async {
        let mockService = MockCoinService()
        let viewModel = CoinsViewModel(service: mockService)
        
        // First fetch
        mockService.fetchCoinsResult = .success([.sampleCoin])
        await viewModel.fetchCoins()
        
        // Second fetch (should append)
        mockService.fetchCoinsResult = .success([.ethereumCoin])
        await viewModel.fetchCoins()
        
        await MainActor.run {
            #expect(viewModel.coins.count == 2)
            #expect(viewModel.coins[0].id == "bitcoin")
            #expect(viewModel.coins[1].id == "ethereum")
        }
    }
    
    @Test("Fetch coins increments page number")
    func testFetchCoinsIncrementsPage() async {
        let mockService = MockCoinService()
        let viewModel = CoinsViewModel(service: mockService)
        
        mockService.fetchCoinsResult = .success([.sampleCoin])
        
        await viewModel.fetchCoins()
        
        #expect(mockService.fetchCoinsCallCount == 1)
        #expect(mockService.lastPage == 1)
        
        await viewModel.fetchCoins()
        
        #expect(mockService.fetchCoinsCallCount == 2)
        #expect(mockService.lastPage == 2)
    }
    
    @Test("Fetch coins sets loading state correctly")
    func testFetchCoinsLoadingState() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .success([.sampleCoin])
        // Add delay to simulate network latency so we can check loading state
        mockService.delayNanoseconds = 50_000_000 // 0.05 seconds
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await MainActor.run {
            #expect(viewModel.loading == false)
        }
        
        // Start the async fetch
        let fetchTask = Task { @MainActor in
            await viewModel.fetchCoins()
        }
        
        // Give it a moment to start (loading should be true by now)
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        // Loading should be true while fetching
        await MainActor.run {
            #expect(viewModel.loading == true)
        }
        
        // Wait for completion
        await fetchTask.value
        
        await MainActor.run {
            #expect(viewModel.loading == false)
        }
    }
    
    // MARK: - fetchCoins() Error Tests
    
    @Test("Fetch coins handles server error")
    func testFetchCoinsServerError() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .failure(.serverError)
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        await MainActor.run {
            #expect(viewModel.coins.isEmpty)
            #expect(viewModel.loading == false)
            #expect(viewModel.errorMessage == NetworkError.serverError.userMessage)
        }
    }
    
    @Test("Fetch coins handles request failed error")
    func testFetchCoinsRequestFailed() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .failure(.requestFailed)
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        await MainActor.run {
            #expect(viewModel.errorMessage == NetworkError.requestFailed.userMessage)
            #expect(viewModel.loading == false)
        }
    }
    
    @Test("Fetch coins handles unknown error")
    func testFetchCoinsUnknownError() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .failure(.decodingError)
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        await MainActor.run {
            #expect(viewModel.errorMessage == NetworkError.decodingError.userMessage)
        }
    }
    
    @Test("Fetch coins prevents concurrent requests")
    func testFetchCoinsPreventsConcurrentRequests() async {
        let mockService = MockCoinService()
        // Make service slow to simulate network delay
        mockService.fetchCoinsResult = .success([.sampleCoin])
        
        let viewModel = CoinsViewModel(service: mockService)
        
        // Start first call
        let task1 = Task { @MainActor in
            await viewModel.fetchCoins()
        }
        
        // Immediately try second call (should be ignored)
        let task2 = Task { @MainActor in
            await viewModel.fetchCoins()
        }
        
        await task1.value
        await task2.value
        
        // Should only call service once due to loading guard
        #expect(mockService.fetchCoinsCallCount == 1)
    }
    
    // MARK: - refreshCoins() Tests
    
    @Test("Refresh coins resets page and clears array")
    func testRefreshCoins() async {
        let mockService = MockCoinService()
        let viewModel = CoinsViewModel(service: mockService)
        
        // Add some coins first
        mockService.fetchCoinsResult = .success([.sampleCoin, .ethereumCoin])
        await viewModel.fetchCoins()
        
        // Refresh
        mockService.fetchCoinsResult = .success([.cardanoCoin])
        await viewModel.refreshCoins()
        
        // Should only have the new coin, not the old ones
        await MainActor.run {
            #expect(viewModel.coins.count == 1)
            #expect(viewModel.coins.first?.id == "cardano")
        }
    }
    
    // MARK: - getTrendingCoins() Tests
    
    @Test("Get trending coins returns empty array when coins is empty")
    func testGetTrendingCoinsEmpty() async {
        let viewModel = CoinsViewModel()
        
        let trending = await MainActor.run {
            viewModel.getTrendingCoins()
        }
        #expect(trending.isEmpty)
    }
    
    @Test("Get trending coins returns top 5 sorted by price change")
    func testGetTrendingCoinsSorting() async {
        let mockService = MockCoinService()
        let viewModel = CoinsViewModel(service: mockService)
        
        // Create coins with different price changes
        let coins = [
            Coin.sampleCoin,      // 4.5%
            Coin.ethereumCoin,    // 3.3%
            Coin.cardanoCoin,     // -6.7%
        ]
        
        mockService.fetchCoinsResult = .success(coins)
        
        await viewModel.fetchCoins()
        
        let trending = await MainActor.run {
            viewModel.getTrendingCoins()
        }
        #expect(trending.count == 3) // All 3 coins
        #expect(trending[0].id == "bitcoin") // Highest: 4.5%
        #expect(trending[1].id == "ethereum") // Second: 3.3%
        #expect(trending[2].id == "cardano") // Lowest: -6.7%
    }
    
    @Test("Get trending coins handles nil price change")
    func testGetTrendingCoinsWithNilPriceChange() async {
        let mockService = MockCoinService()
        let viewModel = CoinsViewModel(service: mockService)
        
        let coinWithNil = Coin(
            id: "test",
            name: "Test",
            symbol: "test",
            image: "https://example.com/test.png",
            price: 100.0,
            marketCap: nil,
            marketCapRank: nil,
            totalVolume: nil,
            high24H: nil,
            low24H: nil,
            priceChange24H: nil,
            priceChangePercent24H: nil,
            circulatingSupply: nil
        )
        
        mockService.fetchCoinsResult = .success([coinWithNil, .sampleCoin])
        
        await viewModel.fetchCoins()
        
        let trending = await MainActor.run {
            viewModel.getTrendingCoins()
        }
        // Coin with nil should be treated as 0, so sampleCoin (4.5%) should be first
        #expect(trending.first?.id == "bitcoin")
    }
    
    // MARK: - clearError() Tests
    
    @Test("Clear error removes error message")
    func testClearError() async {
        let mockService = MockCoinService()
        mockService.fetchCoinsResult = .failure(.serverError)
        
        let viewModel = CoinsViewModel(service: mockService)
        
        await viewModel.fetchCoins()
        
        await MainActor.run {
            #expect(viewModel.errorMessage != nil)
            viewModel.clearError()
            #expect(viewModel.errorMessage == nil)
        }
    }
}

