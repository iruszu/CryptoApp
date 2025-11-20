//
//  Coin.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import Foundation

/// Represents a cryptocurrency coin with market data.
/// 
/// Note: Some fields are optional to handle cases where the API may return nil values.
/// This defensive approach prevents crashes from unexpected API responses.
struct Coin: Identifiable, Codable {
    let id: String
    let name: String
    let symbol: String
    let image: String
    let price: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let totalVolume: Double?
    let high24H: Double?
    let low24H: Double?
    let priceChange24H: Double?
    let priceChangePercent24H: Double?
    let circulatingSupply: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case image
        case price = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercent24H = "price_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
    }
    
    /// Validates that the coin has essential data and reasonable values.
    /// Filters out coins with invalid data to prevent UI issues.
    var isValid: Bool {
        // Essential fields must be present and non-empty
        guard !id.isEmpty, !name.isEmpty, !symbol.isEmpty else {
            return false
        }
        
        // Price must be positive (coins can't have negative prices)
        guard price > 0 else {
            return false
        }
        
        // If 24h high/low are present, high must be >= low
        if let high = high24H, let low = low24H {
            guard high >= low else {
                return false
            }
        }
        
        // Image URL should be valid (basic check)
        if !image.isEmpty {
            guard let url = URL(string: image),
                  let scheme = url.scheme,
                  (scheme == "http" || scheme == "https") else {
                return false
            }
        }
        
        return true
    }
    
    /// Returns a safe price change percentage, defaulting to 0 if nil
    var safePriceChangePercent24H: Double {
        return priceChangePercent24H ?? 0.0
    }
    
    /// Returns a safe market cap, defaulting to 0 if nil
    var safeMarketCap: Double {
        return marketCap ?? 0.0
    }
    
    /// Returns a safe total volume, defaulting to 0 if nil
    var safeTotalVolume: Double {
        return totalVolume ?? 0.0
    }
    
    /// Returns a safe 24h high, defaulting to price if nil
    var safeHigh24H: Double {
        return high24H ?? price
    }
    
    /// Returns a safe 24h low, defaulting to price if nil
    var safeLow24H: Double {
        return low24H ?? price
    }
}
