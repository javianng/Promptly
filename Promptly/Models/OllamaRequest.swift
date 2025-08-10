//
//  OllamaRequest.swift
//  Promptly
//
//  Created by Claude on 10/8/25.
//

import Foundation

struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
    let options: RequestOptions?
    
    struct RequestOptions: Codable {
        let temperature: Double?
        let top_p: Double?
        let top_k: Int?
        let num_predict: Int?
        
        init(temperature: Double? = nil, top_p: Double? = nil, top_k: Int? = nil, num_predict: Int? = nil) {
            self.temperature = temperature
            self.top_p = top_p
            self.top_k = top_k
            self.num_predict = num_predict
        }
    }
    
    init(model: String = "gemma2", prompt: String, stream: Bool = true, options: RequestOptions? = nil) {
        self.model = model
        self.prompt = prompt
        self.stream = stream
        self.options = options
    }
    
    static func createPrompt(context: String, query: String) -> String {
        return """
        Context: \(context)
        
        Query: \(query)
        """
    }
}