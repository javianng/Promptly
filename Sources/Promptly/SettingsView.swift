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
    @ObservedObject private var viewModel = SettingsViewModel()
    @ObservedObject private var shortcutManager = ShortcutManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Model Settings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.top, 4)
                } else if !viewModel.availableModels.isEmpty {
                    Picker("Model", selection: $viewModel.selectedModel) {
                        ForEach(viewModel.availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(PopUpButtonPickerStyle())
                    .frame(maxWidth: 200)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(colorScheme == .dark ? Color(.sRGB, white: 0.15, opacity: 1) : Color(.sRGB, white: 0.97, opacity: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Keyboard Shortcut")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(viewModel.isRecordingShortcut ? "Recording: \(shortcutManager.currentShortcut.map { shortcutManager.shortcutToString(keyCode: $0.keyCode, modifiers: $0.modifiers) } ?? "...")" : (shortcutManager.currentShortcut.map { shortcutManager.shortcutToString(keyCode: $0.keyCode, modifiers: $0.modifiers) } ?? "Not set"))
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .frame(minWidth: 150)
                        .background(colorScheme == .dark ? Color(.sRGB, white: 0.15, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                    
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
                        .buttonStyle(.minimalPrimary)
                    
                        HStack(spacing: 8) {
                            Button("Change") {
                                viewModel.isRecordingShortcut.toggle()
                            }
                            .buttonStyle(.minimal)
                            
                            Button("Reset") {
                                // Reset to Command+Shift+I
                                shortcutManager.currentShortcut = (keyCode: 34, modifiers: [.command, .shift])
                                UserDefaults.standard.set("⌘⇧I", forKey: "customShortcut")
                            }
                            .buttonStyle(.minimal)
                        }
                    } else {
                        Button("Change") {
                            viewModel.isRecordingShortcut.toggle()
                        }
                        .buttonStyle(.minimal)
                    }
                }
                
                if !viewModel.isRecordingShortcut {
                    Text("Click 'Change' and press your desired keyboard shortcut")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Donation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Support via PayPal") {
                    if let url = URL(string: "https://paypal.me/j4vianz?country.x=SG&locale.x=en_GB") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.minimal)
                
                Text("Your support helps keep Promptly evolving!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Feedback")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Report a Bug") {
                    if let url = URL(string: "https://github.com/javianng/Promptly/issues") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.minimal)
                
                Text("Help improve Promptly by reporting issues")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(minWidth: 380, minHeight: 280)
    }
} 