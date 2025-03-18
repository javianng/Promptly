import SwiftUI

struct QueryView: View {
    let selectedText: String
    @State private var query: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var showCopied: Bool = false
    @FocusState private var isQueryFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Selected Text:")
                .font(.headline)
            ScrollView {
                Text(selectedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
            }
            .frame(height: 100)
            
            Text("Your Query:")
                .font(.headline)
            TextField("Enter your query...", text: $query)
                .textFieldStyle(.roundedBorder)
                .focused($isQueryFieldFocused)
            
            Button(action: sendToOllama) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Process with Ollama")
                }
            }
            .disabled(query.isEmpty || isLoading)
            .keyboardShortcut(.return, modifiers: [])
            
            if !responseText.isEmpty {
                HStack {
                    Text("Response:")
                        .font(.headline)
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
                            Text(showCopied ? "Copied!" : "Copy")
                        }
                        .foregroundColor(showCopied ? .green : .blue)
                    }
                    .buttonStyle(.plain)
                }
                ScrollView {
                    Text(responseText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                }
                .frame(height: 100)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isQueryFieldFocused = true
            }
        }
    }
    
    func sendToOllama() {
        isLoading = true
        responseText = "" // Clear previous response
        
        Task {
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
                    "stream": false // Disable streaming for simpler handling
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (data, _) = try await URLSession.shared.data(for: request)
                
                // Decode the response
                if let jsonString = String(data: data, encoding: .utf8),
                   let jsonData = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let response = json["response"] as? String {
                    await MainActor.run {
                        responseText = response
                        isLoading = false
                    }
                } else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Ollama response"])
                }
            } catch {
                await MainActor.run {
                    responseText = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    QueryView(selectedText: "Example selected text for preview.\nThis is a multi-line sample to show how the view handles longer content.")
        .frame(width: 400, height: 400)
} 
