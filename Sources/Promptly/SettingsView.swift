import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedOllamaModel")
        }
    }
    
    @Published var availableModels: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedOllamaModel") ?? "llama2"
        Task {
            await fetchAvailableModels()
        }
    }
    
    @MainActor
    func fetchAvailableModels() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "http://localhost:11434/api/tags")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let models = json["models"] as? [[String: Any]] {
                availableModels = models.compactMap { model in
                    model["name"] as? String
                }.sorted()
                
                // If no model is selected yet and we have models available, select the first one
                if selectedModel.isEmpty && !availableModels.isEmpty {
                    selectedModel = availableModels[0]
                }
            }
        } catch {
            errorMessage = "Failed to fetch models: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        Form {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading models...")
                    Spacer()
                }
            } else if let error = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Error loading models")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task {
                            await viewModel.fetchAvailableModels()
                        }
                    }
                }
            } else {
                Picker("Ollama Model", selection: $viewModel.selectedModel) {
                    ForEach(viewModel.availableModels, id: \.self) { model in
                        Text(model)
                            .tag(model)
                    }
                }
                .pickerStyle(.menu)
                .disabled(viewModel.availableModels.isEmpty)
                
                if viewModel.availableModels.isEmpty {
                    Text("No models found. Please install models using 'ollama pull <model>'")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.top, 4)
                } else {
                    Text("Selected model: \(viewModel.selectedModel)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            
            Text("Note: Make sure Ollama is running and models are downloaded using 'ollama pull <model>'")
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.top, 8)
        }
        .padding(20)
        .frame(width: 300)
    }
} 