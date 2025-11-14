//
//  CoinImageView.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import SwiftUI

/// Reusable component for displaying coin images with error handling.
/// Provides a consistent placeholder and error state across the app.
struct CoinImageView: View {
    let imageURL: String
    let size: CGFloat
    
    init(imageURL: String, size: CGFloat = 40) {
        self.imageURL = imageURL
        self.size = size
    }
    
    var body: some View {
        Group {
            if let url = URL(string: imageURL), !imageURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var placeholderView: some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(.system(size: size * 0.4))
            )
    }
}

#Preview {
    HStack {
        CoinImageView(imageURL: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png", size: 60)
        CoinImageView(imageURL: "", size: 40)
        CoinImageView(imageURL: "invalid-url", size: 30)
    }
    .padding()
}

