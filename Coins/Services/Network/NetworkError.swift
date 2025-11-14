//
//  NetworkError.swift
//  Coins
//
//  Created by Kellie Ho on 2025-11-12.
//

import Foundation

/// Enumeration of network-related errors that can occur during API requests.
/// Provides user-friendly error messages for each error type.
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed
    case serverError
    case noDataAvailable
    case decodingError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check your network configuration."
        case .requestFailed:
            return "Request failed. Please check your internet connection and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .invalidResponse:
            return "Invalid response from the server. Please try again."
        case .noDataAvailable:
            return "No data returned from the server."
        case .decodingError:
            return "Failed to decode data from the server. The data format may have changed."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    /// Returns a user-friendly message suitable for display in the UI
    var userMessage: String {
        return errorDescription ?? "An unknown error occurred"
    }
}
