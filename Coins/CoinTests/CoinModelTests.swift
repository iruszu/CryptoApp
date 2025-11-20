//
//  CoinModelTests.swift
//  CoinTests
//
//  Created by Kellie Ho on 2025-11-19.
//

import Testing
@testable import Coins

struct CoinModelTests {
    
    // MARK: - isValid Tests
    
    @Test("Valid coin passes validation")
    func testValidCoin() {
        let coin = Coin.sampleCoin
        #expect(coin.isValid == true)
    }
    
    @Test("Coin with empty id is invalid")
    func testInvalidCoinEmptyId() {
        let coin = Coin(
            id: "",
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
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with empty name is invalid")
    func testInvalidCoinEmptyName() {
        let coin = Coin(
            id: "test",
            name: "",
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
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with empty symbol is invalid")
    func testInvalidCoinEmptySymbol() {
        let coin = Coin(
            id: "test",
            name: "Test",
            symbol: "",
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
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with zero price is invalid")
    func testInvalidCoinZeroPrice() {
        let coin = Coin(
            id: "test",
            name: "Test",
            symbol: "test",
            image: "https://example.com/test.png",
            price: 0.0,
            marketCap: nil,
            marketCapRank: nil,
            totalVolume: nil,
            high24H: nil,
            low24H: nil,
            priceChange24H: nil,
            priceChangePercent24H: nil,
            circulatingSupply: nil
        )
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with negative price is invalid")
    func testInvalidCoinNegativePrice() {
        let coin = Coin(
            id: "test",
            name: "Test",
            symbol: "test",
            image: "https://example.com/test.png",
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
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with high24H less than low24H is invalid")
    func testInvalidCoinHighLessThanLow() {
        let coin = Coin(
            id: "test",
            name: "Test",
            symbol: "test",
            image: "https://example.com/test.png",
            price: 100.0,
            marketCap: nil,
            marketCapRank: nil,
            totalVolume: nil,
            high24H: 90.0,
            low24H: 110.0, // Invalid: low > high
            priceChange24H: nil,
            priceChangePercent24H: nil,
            circulatingSupply: nil
        )
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with invalid image URL is invalid")
    func testInvalidCoinImageURL() {
        let coin = Coin(
            id: "test",
            name: "Test",
            symbol: "test",
            image: "not a valid url",
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
        #expect(coin.isValid == false)
    }
    
    @Test("Coin with valid high24H and low24H passes validation")
    func testValidCoinWithHighAndLow() {
        let coin = Coin(
            id: "test",
            name: "Test",
            symbol: "test",
            image: "https://example.com/test.png",
            price: 100.0,
            marketCap: nil,
            marketCapRank: nil,
            totalVolume: nil,
            high24H: 110.0,
            low24H: 90.0,
            priceChange24H: nil,
            priceChangePercent24H: nil,
            circulatingSupply: nil
        )
        #expect(coin.isValid == true)
    }
    
    @Test("Coin with nil optional fields is valid")
    func testValidCoinWithNilOptionals() {
        let coin = Coin(
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
        #expect(coin.isValid == true)
    }
    
    // MARK: - Safe Computed Properties Tests
    
    @Test("safePriceChangePercent24H returns value when present")
    func testSafePriceChangePercent24HWithValue() {
        let coin = Coin.sampleCoin
        #expect(coin.safePriceChangePercent24H == 4.5)
    }
    
    @Test("safePriceChangePercent24H returns zero when nil")
    func testSafePriceChangePercent24HWithNil() {
        let coin = Coin(
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
        #expect(coin.safePriceChangePercent24H == 0.0)
    }
    
    @Test("safeMarketCap returns value when present")
    func testSafeMarketCapWithValue() {
        let coin = Coin.sampleCoin
        #expect(coin.safeMarketCap == 850000000000)
    }
    
    @Test("safeMarketCap returns zero when nil")
    func testSafeMarketCapWithNil() {
        let coin = Coin(
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
        #expect(coin.safeMarketCap == 0.0)
    }
    
    @Test("safeTotalVolume returns value when present")
    func testSafeTotalVolumeWithValue() {
        let coin = Coin.sampleCoin
        #expect(coin.safeTotalVolume == 25000000000)
    }
    
    @Test("safeTotalVolume returns zero when nil")
    func testSafeTotalVolumeWithNil() {
        let coin = Coin(
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
        #expect(coin.safeTotalVolume == 0.0)
    }
    
    @Test("safeHigh24H returns value when present")
    func testSafeHigh24HWithValue() {
        let coin = Coin.sampleCoin
        #expect(coin.safeHigh24H == 46000.0)
    }
    
    @Test("safeHigh24H returns price when nil")
    func testSafeHigh24HWithNil() {
        let coin = Coin(
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
        #expect(coin.safeHigh24H == 100.0) // Should return price
    }
    
    @Test("safeLow24H returns value when present")
    func testSafeLow24HWithValue() {
        let coin = Coin.sampleCoin
        #expect(coin.safeLow24H == 44000.0)
    }
    
    @Test("safeLow24H returns price when nil")
    func testSafeLow24HWithNil() {
        let coin = Coin(
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
        #expect(coin.safeLow24H == 100.0) // Should return price
    }
}

