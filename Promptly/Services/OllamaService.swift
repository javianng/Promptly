//
//  OllamaService.swift
//  Promptly
//
//  Created by Claude on 10/8/25.
//

import Foundation

@MainActor
protocol OllamaServiceProtocol {
  func generateResponse(context: String, query: String) async throws -> AsyncThrowingStream<
    String, Error
  >
  func generateCompleteResponse(context: String, query: String) async throws
    -> OllamaGenerationResult
  func cancelCurrentRequest()
}

@MainActor
class OllamaService: ObservableObject, OllamaServiceProtocol {
  private var currentTask: Task<Void, Never>?
  private let session: URLSession

  init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = AppConfig.Ollama.requestTimeout
    config.timeoutIntervalForResource = AppConfig.Ollama.requestTimeout * 2
    self.session = URLSession(configuration: config)
  }

  // MARK: - Streaming Response
  func generateResponse(context: String, query: String) async throws -> AsyncThrowingStream<
    String, Error
  > {
    let prompt = OllamaRequest.createPrompt(context: context, query: query)
    let request = OllamaRequest(model: AppConfig.Ollama.defaultModel, prompt: prompt, stream: true)

    return AsyncThrowingStream<String, Error> { continuation in
      let task = Task {
        do {
          let urlRequest = try self.createURLRequest(for: request)
          let (asyncBytes, response) = try await session.bytes(for: urlRequest)

          try self.validateHTTPResponse(response)

          for try await line in asyncBytes.lines {
            if Task.isCancelled {
              continuation.finish(throwing: OllamaError.cancelled)
              return
            }

            guard !line.isEmpty else { continue }

            do {
              let streamResponse = try self.parseStreamResponse(line)

              if !streamResponse.responseChunk.isEmpty {
                continuation.yield(streamResponse.responseChunk)
              }

              if streamResponse.isComplete {
                continuation.finish()
                return
              }
            } catch {
              continuation.finish(throwing: OllamaError.decodingError(error.localizedDescription))
              return
            }
          }

          continuation.finish()
        } catch {
          continuation.finish(throwing: OllamaError.from(error))
        }
      }

      self.currentTask = task

      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }
  }

  // MARK: - Complete Response (Non-streaming)
  func generateCompleteResponse(context: String, query: String) async throws
    -> OllamaGenerationResult
  {
    let prompt = OllamaRequest.createPrompt(context: context, query: query)
    let request = OllamaRequest(model: AppConfig.Ollama.defaultModel, prompt: prompt, stream: false)

    let urlRequest = try createURLRequest(for: request)

    do {
      let (data, response) = try await session.data(for: urlRequest)
      try validateHTTPResponse(response)

      let completeResponse = try JSONDecoder().decode(OllamaCompleteResponse.self, from: data)

      let duration = completeResponse.total_duration.map { TimeInterval($0) / 1_000_000_000.0 }

      return OllamaGenerationResult(
        fullResponse: completeResponse.response,
        model: completeResponse.model,
        duration: duration,
        tokenCount: completeResponse.eval_count
      )
    } catch {
      throw OllamaError.from(error)
    }
  }

  // MARK: - Cancellation
  func cancelCurrentRequest() {
    currentTask?.cancel()
    currentTask = nil
  }

  // MARK: - Private Helper Methods
  private func createURLRequest(for ollamaRequest: OllamaRequest) throws -> URLRequest {
    let urlString = AppConfig.getOllamaBaseURL() + AppConfig.Ollama.generateEndpoint
    guard let url = URL(string: urlString) else {
      throw OllamaError.unknown("Invalid URL: \(urlString)")
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      request.httpBody = try JSONEncoder().encode(ollamaRequest)
    } catch {
      throw OllamaError.unknown("Failed to encode request: \(error.localizedDescription)")
    }

    return request
  }

  private func validateHTTPResponse(_ response: URLResponse?) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
      throw OllamaError.invalidResponse
    }

    switch httpResponse.statusCode {
    case 200...299:
      return
    case 404:
      throw OllamaError.modelNotFound(AppConfig.Ollama.defaultModel)
    case 500...599:
      throw OllamaError.serverNotRunning
    default:
      throw OllamaError.unknown("HTTP \(httpResponse.statusCode)")
    }
  }

  private func parseStreamResponse(_ line: String) throws -> OllamaStreamResponse {
    guard let data = line.data(using: .utf8) else {
      throw OllamaError.decodingError("Failed to convert line to data")
    }

    do {
      return try JSONDecoder().decode(OllamaStreamResponse.self, from: data)
    } catch {
      throw OllamaError.decodingError("JSON parsing failed: \(error.localizedDescription)")
    }
  }
}

// MARK: - Convenience Extensions
extension OllamaService {
  func generateResponseWithRetry(
    context: String, query: String, maxRetries: Int = AppConfig.Ollama.maxRetries
  ) async throws -> AsyncThrowingStream<String, Error> {
    var lastError: Error?

    for attempt in 0..<maxRetries {
      do {
        return try await generateResponse(context: context, query: query)
      } catch {
        lastError = error

        if case OllamaError.cancelled = error {
          throw error
        }

        if attempt < maxRetries - 1 {
          try await Task.sleep(nanoseconds: UInt64(AppConfig.Ollama.retryDelay * 1_000_000_000))
        }
      }
    }

    throw lastError ?? OllamaError.unknown("Max retries exceeded")
  }
}
