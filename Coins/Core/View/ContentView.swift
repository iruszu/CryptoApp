//
//  ContentView.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import SwiftUI

/// Main view displaying the cryptocurrency market overview.
/// Shows trending coins and a list of all coins with their current prices.
/// Filter options for the coins list
enum CoinFilter: String, CaseIterable {
    case all = "All"
    case topGainers = "Top Gainers"
    case topLosers = "Top Losers"
    case highestPrice = "Highest Price"
    case lowestPrice = "Lowest Price"
    
    var systemImage: String {
        switch self {
        case .all: return "list.bullet"
        case .topGainers: return "arrow.up.right.circle.fill"
        case .topLosers: return "arrow.down.right.circle.fill"
        case .highestPrice: return "arrow.up.circle.fill"
        case .lowestPrice: return "arrow.down.circle.fill"
        }
    }
}

struct ContentView: View {
    @State private var viewModel = CoinsViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedFilter: CoinFilter = .all
    
    // MARK: - Computed Properties
    
    /// Gets trending coins from the ViewModel (business logic moved out of view)
    private var trendingCoins: [Coin] {
        viewModel.getTrendingCoins()
    }
    
    /// Gets coins to display - either search results or filtered regular list
    private var displayedCoins: [Coin] {
        if !searchText.isEmpty {
            return viewModel.searchResults
        }
        
        let coinsToFilter = viewModel.coins
        
        switch selectedFilter {
        case .all:
            return coinsToFilter
        case .topGainers:
            return coinsToFilter
                .sorted { ($0.priceChangePercent24H ?? 0) > ($1.priceChangePercent24H ?? 0) }
        case .topLosers:
            return coinsToFilter
                .sorted { ($0.priceChangePercent24H ?? 0) < ($1.priceChangePercent24H ?? 0) }
        case .highestPrice:
            return coinsToFilter
                .sorted { $0.price > $1.price }
        case .lowestPrice:
            return coinsToFilter
                .sorted { $0.price < $1.price }
        }
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
            .redacted(reason: viewModel.loading || viewModel.isSearching ? .placeholder : [])
            .refreshable {
                await viewModel.refreshCoins()
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search Coin...")
            .onChange(of: searchText) { oldValue, newValue in
                // Cancel previous search task
                searchTask?.cancel()
                
                // Debounce search - wait 0.5 seconds after user stops typing
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    
                    // Check if task was cancelled
                    guard !Task.isCancelled else { return }
                    
                    await viewModel.searchCoins(query: newValue)
                }
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
            if displayedCoins.isEmpty && !viewModel.loading && !viewModel.isSearching {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    // Filter Picker
                    if searchText.isEmpty {
                        filterPicker
                    }
                    
                    // Coins List
                    LazyVStack(spacing: 12) {
                        ForEach(displayedCoins, id: \.id) { coin in
                            NavigationLink(destination: CoinDetailView(coin: coin, loading: viewModel.loading)) {
                                CoinRowView(coin: coin)
                                    .onAppear {
                                        // Only trigger pagination if not searching/filtering and reached the last item
                                        if searchText.isEmpty && selectedFilter == .all && coin.id == self.viewModel.coins.last?.id {
                                            Task {
                                                await self.viewModel.fetchCoins()
                                                print("pagination happening...")
                                            }
                                        }
                                    }
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
        }
    }
    
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CoinFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: filter.systemImage)
                                .font(.caption)
                            Text(filter.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        }
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedFilter == filter ? Color.orange : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedFilter == filter ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
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
            Image(systemName: searchText.isEmpty ? "bitcoinsign.circle" : "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "No coins available" : "No coins found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !searchText.isEmpty {
                Text("Try searching for a different coin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
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
        HStack {
            CoinImageView(imageURL: coin.image, size: 40)
            
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .bold()
                Text(coin.symbol.uppercased())
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(PriceFormatter.formatPercentChange(coin.safePriceChangePercent24H))
                    .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
                    .bold()
                Text(PriceFormatter.formatPrice(coin.price))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: 12.0))
    }
}

#Preview {
    ContentView()
}
