//
//  HeaderCard.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import SwiftUI

/// Card component for displaying trending coins in the horizontal scroll view.
/// Shows coin image, name, symbol, price, and price change percentage.
struct HeaderCard: View {
    let coin: Coin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                CoinImageView(imageURL: coin.image, size: 30)
                
                HStack(spacing: 4) {
                    Text(coin.name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(coin.symbol.uppercased())
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(PriceFormatter.formatPrice(coin.price))
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 4) {
                Image(systemName: coin.safePriceChangePercent24H >= 0 ? "chevron.up" : "chevron.down")
                    .resizable()
                    .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
                    .frame(width: 10, height: 5)
                Text(PriceFormatter.formatPercentChange(coin.safePriceChangePercent24H))
                    .font(.subheadline)
                    .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 250, height: 120, alignment: .leading)
        .padding(18)
        .glassEffect(in: .rect(cornerRadius: 16.0))
    }
}

#Preview {
    HeaderCard(coin: Coin(
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
        circulatingSupply: 19500000))
}
