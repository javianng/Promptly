//
//  OllamaResponse.swift
//  Promptly
//
//  Created by Claude on 10/8/25.
//

import Foundation

struct OllamaStreamResponse: Codable {
    let model: String?
    let created_at: String?
    let response: String?
    let done: Bool
    let context: [Int]?
    let total_duration: Int?
    let load_duration: Int?
    let prompt_eval_count: Int?
    let prompt_eval_duration: Int?
    let eval_count: Int?
    let eval_duration: Int?
    
    var isComplete: Bool {
        return done
    }
    
    var responseChunk: String {
        return response ?? ""
    }
}

struct OllamaCompleteResponse: Codable {
    let model: String
    let created_at: String
    let response: String
    let done: Bool
    let context: [Int]?
    let total_duration: Int?
    let load_duration: Int?
    let prompt_eval_count: Int?
    let prompt_eval_duration: Int?
    let eval_count: Int?
    let eval_duration: Int?
}

struct OllamaGenerationResult {
    let fullResponse: String
    let model: String
    let duration: TimeInterval?
    let tokenCount: Int?
    
    init(fullResponse: String, model: String, duration: TimeInterval? = nil, tokenCount: Int? = nil) {
        self.fullResponse = fullResponse
        self.model = model
        self.duration = duration
        self.tokenCount = tokenCount
    }
}