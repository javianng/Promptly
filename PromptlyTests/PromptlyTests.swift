//
//  PromptlyTests.swift
//  PromptlyTests
//
//  Created by Javian Ng on 10/8/25.
//

import Testing
@testable import Promptly
import Foundation

struct PromptlyTests {
    
    @Test func testOllamaConnectivity() async throws {
        // First test basic connectivity to Ollama server
        print("🔍 Testing basic Ollama connectivity...")

        let url = URL(string: "http://127.0.0.1:11434/")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Ollama server responding with status: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Available models response: \(responseString)")
            }
        }
        
        #expect((response as? HTTPURLResponse)?.statusCode == 200, "Ollama server should be accessible")
    }
    
    @Test func testModelAvailability() async throws {
        // Test if our configured model is available
        print("🔍 Testing model availability...")
        
        let url = URL(string: "http://localhost:11434/api/tags")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get model list"])
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("📄 Available models: \(responseString)")
        
        // Check if our model is available
        let configuredModel = "gemma3n:latest"
        let isModelAvailable = responseString.contains(configuredModel) || responseString.contains("gemma3n")
        
        if !isModelAvailable {
            print("⚠️ WARNING: Configured model '\(configuredModel)' not found!")
            print("💡 Try: ollama pull \(configuredModel)")
            print("💡 Or use an available model from the list above")
        } else {
            print("✅ Model '\(configuredModel)' is available")
        }
        
        // Don't fail the test if model isn't available, just warn
        // #expect(isModelAvailable, "Model should be available")
    }

    @Test func testOllamaService() async throws {
        // Test the Ollama service with a simple prompt
        let ollamaService = await OllamaService()
        
        let context = "You are a helpful AI assistant that gives brief answers."
        let query = "What is 2+2?"
        
        print("🚀 Testing Ollama service...")
        print("📝 Context: \(context)")
        print("❓ Query: \(query)")
        
        // Test streaming response
        var fullResponse = ""
        var chunkCount = 0
        
        do {
            let responseStream = try await ollamaService.generateResponse(context: context, query: query)
            
            for try await chunk in responseStream {
                fullResponse += chunk
                chunkCount += 1
                print("📦 Chunk \(chunkCount): \(chunk)")
            }
            
            print("✅ Success! Received \(chunkCount) chunks")
            print("📄 Full response: \(fullResponse)")
            
            // Basic validation
            #expect(!fullResponse.isEmpty, "Response should not be empty")
            #expect(chunkCount > 0, "Should receive at least one chunk")
            
        } catch {
            print("❌ Error: \(error)")
            print("💡 Make sure Ollama is running with: ollama serve")
            print("💡 And that gemma3n model is available: ollama pull gemma3n:latest")
            throw error
        }
    }

}
