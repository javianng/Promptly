//
//  OllamaError.swift
//  Promptly
//
//  Created by Claude on 10/8/25.
//

import Foundation

enum OllamaError: LocalizedError, Equatable {
    case networkUnavailable
    case serverNotRunning
    case modelNotFound(String)
    case invalidResponse
    case decodingError(String)
    case requestTimeout
    case cancelled
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection is unavailable. Please check your internet connection."
        case .serverNotRunning:
            return "Ollama server is not running. Please start Ollama and try again."
        case .modelNotFound(let model):
            return "Model '\(model)' not found. Please ensure the model is installed in Ollama."
        case .invalidResponse:
            return "Received invalid response from Ollama server."
        case .decodingError(let details):
            return "Failed to decode response: \(details)"
        case .requestTimeout:
            return "Request timed out. The server took too long to respond."
        case .cancelled:
            return "Request was cancelled."
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your network connection and try again."
        case .serverNotRunning:
            return "Start Ollama by running 'ollama serve' in your terminal."
        case .modelNotFound(let model):
            return "Install the model by running 'ollama pull \(model)' in your terminal."
        case .invalidResponse, .decodingError:
            return "This might be a temporary server issue. Try again in a moment."
        case .requestTimeout:
            return "Try again with a shorter prompt or check your network connection."
        case .cancelled:
            return "The request was cancelled by the user."
        case .unknown:
            return "Please try again. If the problem persists, check Ollama server logs."
        }
    }
    
    static func from(_ error: Error) -> OllamaError {
        if let ollamaError = error as? OllamaError {
            return ollamaError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .cannotConnectToHost, .cannotFindHost:
                return .serverNotRunning
            case .timedOut:
                return .requestTimeout
            case .cancelled:
                return .cancelled
            default:
                return .unknown(urlError.localizedDescription)
            }
        }
        
        if error is CancellationError {
            return .cancelled
        }
        
        return .unknown(error.localizedDescription)
    }
}