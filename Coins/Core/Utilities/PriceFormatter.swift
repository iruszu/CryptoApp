//
//  PriceFormatter.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import Foundation

/// Utility for formatting cryptocurrency prices and percentages consistently.
/// Centralizes formatting logic to ensure consistency across the app.
enum PriceFormatter {
    /// Formats a price value as currency with 2 decimal places.
    /// - Parameter price: The price value to format
    /// - Returns: Formatted string (e.g., "$45,250.50")
    static func formatPrice(_ price: Double) -> String {
        return "$\(price.formatted(.number.precision(.fractionLength(2))))"
    }
    
    /// Formats a price change percentage with 2 decimal places and appropriate sign.
    /// - Parameter percent: The percentage change value
    /// - Returns: Formatted string (e.g., "+2.84%" or "-1.23%")
    static func formatPercentChange(_ percent: Double) -> String {
        let sign = percent >= 0 ? "+" : ""
        return "\(sign)\(percent.formatted(.number.precision(.fractionLength(2))))%"
    }
    
    /// Formats a large number with compact notation (e.g., "1.2B" for billions).
    /// Useful for market cap and volume display.
    /// - Parameter value: The value to format
    /// - Returns: Formatted string (e.g., "$1.2B" or "$285M")
    static func formatCompact(_ value: Double) -> String {
        return "$\(value.formatted(.number.notation(.compactName).precision(.fractionLength(2))))"
    }
}

