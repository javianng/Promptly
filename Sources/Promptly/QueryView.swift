import SwiftUI

struct QueryView: View {
    let selectedText: String
    @State private var query: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var showCopied: Bool = false
    @FocusState private var isQueryFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Context")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ScrollView {
                    Text(selectedText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(colorScheme == .dark ? Color(.sRGB, white: 0.9, opacity: 1) : Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
                .frame(height: 80)
                .background(colorScheme == .dark ? Color(.sRGB, white: 0.15, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
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
                            .foregroundColor(showCopied ? Color.green : Color.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ScrollView {
                        Text(responseText)
                            .foregroundColor(colorScheme == .dark ? Color(.sRGB, white: 0.9, opacity: 1) : Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                    }
                    .frame(height: 100)
                    .background(colorScheme == .dark ? Color(.sRGB, white: 0.15, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(16)
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
    QueryView(selectedText: "Sample selected text")
} 
