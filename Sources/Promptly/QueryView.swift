import SwiftUI

struct QueryView: View {
    let selectedText: String
    @State private var query: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var showCopied: Bool = false
    @State private var isContextCollapsed: Bool = false
    @State private var streamingTask: Task<Void, Never>?
    @FocusState private var isQueryFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Context")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isContextCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: isContextCollapsed ? "chevron.down" : "chevron.up")
                            .imageScale(.small)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if !isContextCollapsed {
                    ScrollView {
                        Text(selectedText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(colorScheme == .dark ? Color(.sRGB, white: 0.9, opacity: 1) : Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                    }
                    .frame(height: 120)
                    .background(colorScheme == .dark ? Color(.sRGB, white: 0.15, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.scale(scale: 1, anchor: .top).combined(with: .opacity))
                } else {
                    // Show a preview when collapsed
                    Text(selectedText.prefix(30) + (selectedText.count > 30 ? "..." : ""))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
                }
            }
            
            Divider()
                .padding(.vertical, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                TextField("Ask about this code...", text: $query)
                    .font(.system(size: 14))
                    .foregroundColor(Color.primary)
                    .padding(10)
                    .background(colorScheme == .dark ? Color(.sRGB, white: 0.17, opacity: 1) : Color(.sRGB, white: 0.97, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .focused($isQueryFieldFocused)
                
                Button(action: sendToOllama) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Process")
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.minimalPrimary)
                .disabled(query.isEmpty || isLoading)
                .keyboardShortcut(.return, modifiers: [])
            }
            
            if !responseText.isEmpty {
                Divider()
                    .padding(.vertical, 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Response")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(responseText, forType: .string)
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showCopied = false
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                                    .imageScale(.small)
                                Text(showCopied ? "Copied" : "Copy")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.minimal)
                    }
                    
                    ScrollView {
                        Text(responseText)
                            .foregroundColor(colorScheme == .dark ? Color(.sRGB, white: 0.9, opacity: 1) : Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                    }
                    .frame(height: 150)
                    .background(colorScheme == .dark ? Color(.sRGB, white: 0.15, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(16)
        .frame(width: 500)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isQueryFieldFocused = true
            }
        }
    }
    
    func sendToOllama() {
        isLoading = true
        responseText = "" // Clear previous response
        
        // Cancel any ongoing streaming task
        streamingTask?.cancel()
        
        // Auto-collapse context when sending query
        withAnimation(.easeInOut(duration: 0.2)) {
            isContextCollapsed = true
        }
        
        streamingTask = Task {
            do {
                // Create the request to Ollama
                let url = URL(string: "http://localhost:11434/api/generate")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let prompt = """
                Context: \(selectedText)
                
                Query: \(query)
                """
                
                let selectedModel = UserDefaults.standard.string(forKey: "selectedOllamaModel") ?? "llama2"
                let body: [String: Any] = [
                    "model": selectedModel,
                    "prompt": prompt,
                    "stream": true // Enable streaming
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request) { _, _, _ in }
                dataTask.resume()
                
                // Get the session configuration to use the same cookies/cache
                let sessionConfig = session.configuration
                
                // Create a new stream task with the same configuration
                let streamingSession = URLSession(configuration: sessionConfig)
                
                let (asyncBytes, _) = try await streamingSession.bytes(for: request)
                
                // Process the streaming response
                for try await line in asyncBytes.lines {
                    if Task.isCancelled { break }
                    
                    guard !line.isEmpty else { continue }
                    
                    // Each line is a JSON object with a "response" field
                    if let data = line.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        // Extract and append the response chunk
                        if let responseChunk = json["response"] as? String {
                            await MainActor.run {
                                responseText += responseChunk
                            }
                        }
                        
                        // Check if we've reached the end of the stream
                        if let done = json["done"] as? Bool, done {
                            break
                        }
                    }
                }
                
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        responseText += "\nError: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    QueryView(selectedText: "Sample selected text")
} 
