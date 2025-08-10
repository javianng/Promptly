//
//  AppConfig.swift
//  Promptly
//
//  Created by Claude on 10/8/25.
//

import Foundation

struct AppConfig {
  // MARK: - Ollama Configuration
  struct Ollama {
    static let baseURL = "http://localhost:11434"
    static let generateEndpoint = "/api/generate"
    static let defaultModel = "gemma3n:latest"
    static let requestTimeout: TimeInterval = 60.0
    static let maxRetries = 3
    static let retryDelay: TimeInterval = 1.0

    // Request options
    static let defaultTemperature: Double = 0.7
    static let defaultTopP: Double = 0.9
    static let defaultTopK: Int = 40
  }

  // MARK: - App Settings
  struct App {
    static let defaultKeyboardShortcut = "⌘⇧I"
    static let maxContextLength = 4096
    static let streamingBufferSize = 1024
  }

  // MARK: - User Defaults Keys
  struct UserDefaultsKeys {
    static let selectedOllamaModel = "selectedOllamaModel"
    static let keyboardShortcut = "keyboardShortcut"
    static let ollamaBaseURL = "ollamaBaseURL"
  }

  // MARK: - Helper Methods
  static func getOllamaBaseURL() -> String {
    return UserDefaults.standard.string(forKey: UserDefaultsKeys.ollamaBaseURL) ?? Ollama.baseURL
  }

  static func getSelectedModel() -> String {
    return UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedOllamaModel)
      ?? Ollama.defaultModel
  }
}
