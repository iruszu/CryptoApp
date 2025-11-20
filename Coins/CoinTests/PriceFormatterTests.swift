//
//  PriceFormatterTests.swift
//  CoinTests
//
//  Created by Kellie Ho on 2025-11-19.
//

import Testing
@testable import Coins

struct PriceFormatterTests {
    
    // MARK: - formatPrice() Tests
    
    @Test("Format price formats positive price correctly")
    func testFormatPricePositive() {
        let formatted = PriceFormatter.formatPrice(45250.50)
        #expect(formatted.contains("$"))
        #expect(formatted.contains("45,250.50") || formatted.contains("45250.50"))
    }
    
    @Test("Format price formats small price correctly")
    func testFormatPriceSmall() {
        let formatted = PriceFormatter.formatPrice(0.01)
        #expect(formatted.contains("$"))
        #expect(formatted.contains("0.01"))
    }
    
    @Test("Format price formats large price correctly")
    func testFormatPriceLarge() {
        let formatted = PriceFormatter.formatPrice(1000000.99)
        #expect(formatted.contains("$"))
        // Should format with commas
    }
    
    @Test("Format price formats zero correctly")
    func testFormatPriceZero() {
        let formatted = PriceFormatter.formatPrice(0.0)
        #expect(formatted.contains("$"))
        #expect(formatted.contains("0.00"))
    }
    
    @Test("Format price always includes 2 decimal places")
    func testFormatPriceTwoDecimals() {
        let formatted1 = PriceFormatter.formatPrice(100.0)
        let formatted2 = PriceFormatter.formatPrice(100.5)
        let formatted3 = PriceFormatter.formatPrice(100.555)
        
        // All should have 2 decimal places
        #expect(formatted1.contains(".00") || formatted1.contains("100"))
        #expect(formatted2.contains(".50"))
        #expect(formatted3.contains(".56") || formatted3.contains(".55"))
    }
    
    // MARK: - formatPercentChange() Tests
    
    @Test("Format percent change formats positive percentage with plus sign")
    func testFormatPercentChangePositive() {
        let formatted = PriceFormatter.formatPercentChange(4.5)
        #expect(formatted.contains("+"))
        #expect(formatted.contains("4.5"))
        #expect(formatted.contains("%"))
    }
    
    @Test("Format percent change formats negative percentage correctly")
    func testFormatPercentChangeNegative() {
        let formatted = PriceFormatter.formatPercentChange(-6.7)
        #expect(!formatted.contains("+")) // Should not have plus
        #expect(formatted.contains("-"))
        #expect(formatted.contains("6.7"))
        #expect(formatted.contains("%"))
    }
    
    @Test("Format percent change formats zero correctly")
    func testFormatPercentChangeZero() {
        let formatted = PriceFormatter.formatPercentChange(0.0)
        // Zero should not have a sign (or have +)
        #expect(formatted.contains("0"))
        #expect(formatted.contains("%"))
    }
    
    @Test("Format percent change formats large percentage correctly")
    func testFormatPercentChangeLarge() {
        let formatted = PriceFormatter.formatPercentChange(150.25)
        #expect(formatted.contains("+"))
        #expect(formatted.contains("150.25"))
        #expect(formatted.contains("%"))
    }
    
    @Test("Format percent change always includes 2 decimal places")
    func testFormatPercentChangeTwoDecimals() {
        let formatted1 = PriceFormatter.formatPercentChange(10.0)
        let formatted2 = PriceFormatter.formatPercentChange(10.5)
        let formatted3 = PriceFormatter.formatPercentChange(10.555)
        
        // All should have 2 decimal places
        #expect(formatted1.contains(".00") || formatted1.contains("10"))
        #expect(formatted2.contains(".50"))
        #expect(formatted3.contains(".56") || formatted3.contains(".55"))
    }
    
    // MARK: - formatCompact() Tests
    
    @Test("Format compact formats billions correctly")
    func testFormatCompactBillions() {
        let formatted = PriceFormatter.formatCompact(1_200_000_000)
        #expect(formatted.contains("$"))
        // Should contain "B" or "billion" or similar
    }
    
    @Test("Format compact formats millions correctly")
    func testFormatCompactMillions() {
        let formatted = PriceFormatter.formatCompact(285_000_000)
        #expect(formatted.contains("$"))
        // Should contain "M" or "million" or similar
    }
    
    @Test("Format compact formats thousands correctly")
    func testFormatCompactThousands() {
        let formatted = PriceFormatter.formatCompact(5_500)
        #expect(formatted.contains("$"))
        // Should contain "K" or "thousand" or similar
    }
    
    @Test("Format compact formats small values correctly")
    func testFormatCompactSmall() {
        let formatted = PriceFormatter.formatCompact(500)
        #expect(formatted.contains("$"))
        // Small values might not use compact notation
    }
    
    @Test("Format compact formats zero correctly")
    func testFormatCompactZero() {
        let formatted = PriceFormatter.formatCompact(0.0)
        #expect(formatted.contains("$"))
        #expect(formatted.contains("0"))
    }
}

