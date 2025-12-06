//
//  SearchResult.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import Foundation

/// Response model for CoinGecko search API
struct SearchResponse: Codable {
    let coins: [SearchCoin]
}

struct SearchCoin: Codable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case marketCapRank = "market_cap_rank"
    }
}

