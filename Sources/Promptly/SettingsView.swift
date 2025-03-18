import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedOllamaModel")
        }
    }
    
    @Published var isRecordingShortcut = false {
        didSet {
            if isRecordingShortcut {
                ShortcutManager.shared.startRecording()
            } else {
                ShortcutManager.shared.stopRecording()
            }
        }
    }
    
    @Published var availableModels: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedOllamaModel") ?? "llama2"
        // Default shortcut is now ⌘⇧I
        if UserDefaults.standard.string(forKey: "customShortcut") == nil {
            UserDefaults.standard.set("⌘⇧I", forKey: "customShortcut")
        }
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
    @ObservedObject private var shortcutManager = ShortcutManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Model Selection")
                    .font(.headline)
                
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.availableModels.isEmpty {
                    Picker("Model", selection: $viewModel.selectedModel) {
                        ForEach(viewModel.availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Keyboard Shortcut")
                    .font(.headline)
                
                HStack {
                    Text(viewModel.isRecordingShortcut ? "Recording: \(shortcutManager.currentShortcut.map { shortcutManager.shortcutToString(keyCode: $0.keyCode, modifiers: $0.modifiers) } ?? "...")" : (shortcutManager.currentShortcut.map { shortcutManager.shortcutToString(keyCode: $0.keyCode, modifiers: $0.modifiers) } ?? "Not set"))
                        .padding(8)
                        .frame(minWidth: 150)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(6)
                    
                    if viewModel.isRecordingShortcut {
                        Button("Done") {
                            // Save the shortcut when done
                            if let currentShortcut = shortcutManager.currentShortcut {
                                UserDefaults.standard.set(
                                    shortcutManager.shortcutToString(
                                        keyCode: currentShortcut.keyCode,
                                        modifiers: currentShortcut.modifiers
                                    ),
                                    forKey: "customShortcut"
                                )
                            }
                            viewModel.isRecordingShortcut.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    } else {
                        HStack {
                            Button("Change") {
                                viewModel.isRecordingShortcut.toggle()
                            }
                            
                            Button("Reset") {
                                // Reset to Command+Shift+I
                                shortcutManager.currentShortcut = (keyCode: 34, modifiers: [.command, .shift])
                                UserDefaults.standard.set("⌘⇧I", forKey: "customShortcut")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                if !viewModel.isRecordingShortcut {
                    Text("Click 'Change' and press your desired keyboard shortcut")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
} 