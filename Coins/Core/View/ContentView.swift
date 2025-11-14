//
//  ContentView.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import SwiftUI

/// Main view displaying the cryptocurrency market overview.
/// Shows trending coins and a list of all coins with their current prices.
struct ContentView: View {
    @State private var viewModel = CoinsViewModel()
    
    // MARK: - Computed Properties
    
    /// Gets trending coins from the ViewModel (business logic moved out of view)
    private var trendingCoins: [Coin] {
        viewModel.getTrendingCoins()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                headerSection
                
                if let errorMessage = viewModel.errorMessage {
                    errorSection(errorMessage)
                } else {
                    trendingSection
                    coinsListSection
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .redacted(reason: viewModel.loading ? .placeholder : [])
            .refreshable {
                await viewModel.refreshCoins()
            }
        }
        .task {
            await viewModel.fetchCoins()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Crypto Market")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
            
            // TODO: Replace with user name from user settings/profile
            // Given more time, I would prefer to inject a UserService or use @EnvironmentObject
            // to provide user data throughout the app hierarchy
            Text("Welcome back!")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var trendingSection: some View {
        Group {
            if !trendingCoins.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(trendingCoins, id: \.id) { coin in
                            NavigationLink(destination: CoinDetailView(coin: coin, loading: viewModel.loading)) {
                                HeaderCard(coin: coin)
                                    .padding(16)
                                    .padding(.vertical, 16)
                                    .scrollTargetLayout()
                            }
                        }
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
                .frame(height: 200)
                .clipped(antialiased: false)
            }
        }
    }
    
    private var coinsListSection: some View {
        // TODO: Implement pagination that renders more coins (ViewModel)
        // Given more time, I would make sure when the user scrolls down, more
        // coins are loaded from the API (limit of 20). We can do this by triggering
        // fetchCoins() when near the bottom and increase the page count
        Group {
            if viewModel.coins.isEmpty && !viewModel.loading {
                emptyStateView
            } else {
                LazyVStack {
                    Divider()
                    ForEach(viewModel.coins, id: \.id) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin, loading: viewModel.loading)) {
                            CoinRowView(coin: coin)
                                .onAppear {
                                    if coin.id == self.viewModel.coins.last?.id {
                                        Task {
                                            await self.viewModel.fetchCoins()
                                            print("pagination happening...")
                                        }
                                    }
                                }
                        }
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
    }
    
    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel.fetchCoins()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No coins available")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Coin Row View

/// Reusable view component for displaying a coin in the list.
/// Extracted to improve code organization and reusability.
private struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CoinImageView(imageURL: coin.image, size: 40)
                
                VStack(alignment: .leading) {
                    Text(coin.name)
                        .font(.title3)
                        .foregroundColor(.black)
                        .bold()
                    Text(coin.symbol.uppercased())
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(PriceFormatter.formatPercentChange(coin.safePriceChangePercent24H))
                        .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
                        .bold()
                    Text(PriceFormatter.formatPrice(coin.price))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .padding(4)
            Divider()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ContentView()
}
