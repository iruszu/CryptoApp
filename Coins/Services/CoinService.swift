//
//  CoinService.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import Foundation

// Protocol defining the interface for fetching coin data.
// This abstraction allows for easy testing and swapping implementations.
protocol CoinServiceProtocol {

    func fetchCoins(page: Int, perPage: Int) async throws -> [Coin]
}


class CoinService: CoinServiceProtocol {
    private let baseURL = "https://api.coingecko.com/api/v3/coins/markets"
    private let defaultCurrency = "usd"
    private let defaultOrder = "market_cap_desca"
    

    // Note: Errors propagate to the caller (ViewModel) which handles user-facing error messages.
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
        
        // Perform network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            break // Success
        case 400...499:
            throw NetworkError.requestFailed
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.invalidResponse
        }
        
        // Validate data is not empty
        guard !data.isEmpty else {
            throw NetworkError.noDataAvailable
        }
        
        // Decode JSON response
        // Note: Decoding errors will propagate as NetworkError.decodingError via catch in ViewModel
        let decoder = JSONDecoder()
        do {
            let coins = try decoder.decode([Coin].self, from: data)
            // Validate decoded coins have valid data
            return coins.filter { $0.isValid }
        } catch {
            throw NetworkError.decodingError
        }
    }
}
