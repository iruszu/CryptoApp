//
//  CardView.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import SwiftUI

/// Reusable card component for displaying key-value pairs in a consistent format.
/// Used throughout the app for displaying coin statistics.
struct CardView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 20, weight: .semibold))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 0.2)
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
