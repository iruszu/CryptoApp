//
//  CoinsViewModel.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import Foundation
import Observation

/// ViewModel managing coin data and business logic.
/// Uses dependency injection for the service to enable testing and flexibility.
@Observable
class CoinsViewModel {

    var coins: [Coin] = []
    var loading = false
    var errorMessage: String?
    

    private let service: CoinServiceProtocol
    

    private let coinsPerPage = 20
    private let trendingCount = 5
    
    // For page pagination, we increment the page on each request that is made
    private var page = 0
    

    init(service: CoinServiceProtocol = CoinService()) {
        self.service = service
    }
    

    @MainActor
    func fetchCoins() async {
        // Prevent multiple simultaneous requests, makes sure we don't start a new fetch if one is in progress
        guard !loading else { return }
        
        loading = true
        errorMessage = nil
        
        do {
            page += 1
            let fetchedCoins = try await service.fetchCoins(page: page, perPage: coinsPerPage)
            
            // Update on main thread for UI safety

            self.coins.append(contentsOf: fetchedCoins)
            self.loading = false
            
        } catch let error as NetworkError {

                self.errorMessage = error.userMessage
                self.loading = false
            
        } catch {
     
                self.errorMessage = "An unexpected error occurred. Please try again."
                self.loading = false
            
        }
    }
    
    func refreshCoins() async {
        page = 0
        coins = []
        await fetchCoins()
    }
    
    /// Returns the top trending coins based on 24h price change percentage.
    /// This business logic is kept in the ViewModel to maintain separation of concerns.
    @MainActor
    func getTrendingCoins() -> [Coin] {
        guard !coins.isEmpty else { return [] }
        
        return Array(coins
            .sorted { ($0.priceChangePercent24H ?? 0) > ($1.priceChangePercent24H ?? 0) }
            .prefix(trendingCount))
    }
    
    /// Clears the current error message.
    func clearError() {
        errorMessage = nil
    }
}
