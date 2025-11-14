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
            HStack {
                CoinImageView(imageURL: coin.image, size: 30)
                
                HStack(spacing: 4) {
                    Text(coin.name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)
                    
                    Text(coin.symbol.uppercased())
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .bold()
                }
                .padding(.trailing, 50)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 6, height: 10)
            }
            
            Text(PriceFormatter.formatPrice(coin.price))
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 4) {
                Image(systemName: coin.safePriceChangePercent24H >= 0 ? "chevron.up" : "chevron.down")
                    .resizable()
                    .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
                    .frame(width: 10, height: 5)
                Text(PriceFormatter.formatPercentChange(coin.safePriceChangePercent24H))
                    .font(.subheadline)
                    .foregroundColor(coin.safePriceChangePercent24H >= 0 ? .green : .red)
            }
        }
        .padding(18)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 0.2)
        )
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
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
