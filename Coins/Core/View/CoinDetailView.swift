//
//  CoinDetailView.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import SwiftUI

/// Detail view displaying comprehensive information about a specific coin.
/// Shows price, price change, and key market statistics.
struct CoinDetailView: View {
    let coin: Coin
    let loading: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                priceSection
                statsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .redacted(reason: loading ? .placeholder : [])
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            CoinImageView(imageURL: coin.image, size: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
                Text(coin.symbol.uppercased())
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(PriceFormatter.formatPrice(coin.price))
                .font(.title)
                .bold()
                .foregroundColor(.primary)
            
            HStack(spacing: 4) {
                Image(systemName: coin.safePriceChangePercent24H >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                Text(PriceFormatter.formatPercentChange(coin.safePriceChangePercent24H))
                    .font(.title3)
            }
            .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statsSection: some View {
        GlassEffectContainer(spacing: 16) {
            VStack(spacing: 16) {
                CardView(title: "24H High", value: PriceFormatter.formatPrice(coin.safeHigh24H))
                CardView(title: "24H Low", value: PriceFormatter.formatPrice(coin.safeLow24H))
                CardView(title: "24H Volume", value: PriceFormatter.formatCompact(coin.safeTotalVolume))
                CardView(title: "Market Cap", value: PriceFormatter.formatCompact(coin.safeMarketCap))
            }
        }
    }
ub}

#Preview {
    NavigationStack {
        CoinDetailView(coin: Coin(
            id: UUID().uuidString,
            name: "Bitcoin",
            symbol: "BTC",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            price: 45250.50,
            marketCap: 885000000000,
            marketCapRank: 1,
            totalVolume: 28500000000,
            high24H: 46100.00,
            low24H: 44800.00,
            priceChange24H: 1250.50,
            priceChangePercent24H: 2.84,
            circulatingSupply: 19500000
        ), loading: false)
    }
}
