import SwiftUI
import Foundation

struct HoverableLink: View {
    let icon: String
    let url: String
    let tooltip: String
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            Image(systemName: icon)
                .font(.title2)
        }
        .overlay(
            Text(tooltip)
                .font(.caption)
                .foregroundColor(.white)
                .padding(6)
                .background(
                    Color.black.opacity(0.8)
                        .cornerRadius(4)
                )
                .fixedSize(horizontal: true, vertical: false)
                .offset(y: 25)
                .opacity(isHovering ? 1 : 0)
                .animation(.easeOut(duration: 0.1), value: isHovering)
        )
        .onHover { inside in
            isHovering = inside
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct MainView: View {
    @ObservedObject private var shortcutManager = ShortcutManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 96, height: 96)
                    .cornerRadius(12)
            }
            
            Text("Promptly")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                InstructionRow(
                    shortcut: shortcutManager.currentShortcut.map { shortcutManager.shortcutToString(keyCode: $0.keyCode, modifiers: $0.modifiers) } ?? "Not set",
                    description: "Activate Promptly from anywhere"
                )
                
                InstructionRow(
                    shortcut: "⌘ + Enter",
                    description: "Send your prompt"
                )
                
                InstructionRow(
                    shortcut: "Esc",
                    description: "Dismiss Promptly"
                )
            }
            .padding(.vertical, 8)
            
            Text("Promptly helps you be more productive with AI-powered assistance, right from your menubar.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            Divider()
                .padding(.vertical, 8)
            
            VStack(spacing: 8) {
                Text("Developed by Javian Ng")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    HoverableLink(
                        icon: "globe",
                        url: "https://www.javianng.com",
                        tooltip: "Visit my website"
                    )
                    
                    HoverableLink(
                        icon: "link.circle",
                        url: "https://www.linkedin.com/in/javianngzh/",
                        tooltip: "Connect with me on LinkedIn"
                    )
                    
                    HoverableLink(
                        icon: "chevron.left.forwardslash.chevron.right",
                        url: "https://github.com/javianng",
                        tooltip: "Check out my GitHub"
                    )
                }
                .foregroundColor(.primary)
            }
        }
        .padding(24)
    }
}

struct LicenseView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("MIT License")
                    .font(.title2)
                    .padding(.bottom, 4)
                
                Text("""
                Copyright (©) 2025 Javian Ng

                Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                """)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(colorScheme == .dark ? Color(.sRGB, white: 0.9, opacity: 1) : Color.primary)
                .lineSpacing(2)
            }
            .padding(24)
        }
        .background(colorScheme == .dark ? Color.clear : Color(.sRGB, white: 0.97, opacity: 1))
    }
}

struct OllamaView: View {
    @State private var isOllamaRunning: Bool = false
    @State private var isCheckingStatus: Bool = true
    @State private var isStartingOllama: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Ollama Status")
                .font(.title)
                .padding(.top, 10)
            
            if isCheckingStatus {
                ProgressView("Checking status...")
                    .padding(.top, 20)
            } else {
                HStack {
                    Circle()
                        .fill(isOllamaRunning ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(isOllamaRunning ? "Ollama is running" : "Ollama is not running")
                        .font(.headline)
                }
                .padding(.top, 10)
                
                if !isOllamaRunning {
                    Button(action: {
                        startOllama()
                    }) {
                        HStack {
                            if isStartingOllama {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .padding(.trailing, 5)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text(isStartingOllama ? "Starting..." : "Start Ollama")
                        }
                    }
                    .buttonStyle(.minimalPrimary)
                    .disabled(isStartingOllama)
                    .padding(.top, 10)
                }
                
                Button("Check Again") {
                    checkOllamaStatus()
                }
                .buttonStyle(.minimal)
                .padding(.top, 10)
            }
            
            if !isCheckingStatus && !isOllamaRunning {
                Text("Ollama needs to be running for Promptly to use local AI models.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            checkOllamaStatus()
        }
    }
    
    private func checkOllamaStatus() {
        isCheckingStatus = true
        
        DispatchQueue.global(qos: .background).async {
            // Try to connect to Ollama API to see if it's running
            guard let url = URL(string: "http://localhost:11434/api/version") else {
                DispatchQueue.main.async {
                    isOllamaRunning = false
                    isCheckingStatus = false
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { _, response, error in
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        isOllamaRunning = true
                    } else {
                        isOllamaRunning = false
                    }
                    isCheckingStatus = false
                }
            }
            task.resume()
        }
    }
    
    private func startOllama() {
        isStartingOllama = true
        
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["ollama", "serve"]
            
            do {
                try process.run()
                
                // Wait a moment for Ollama to start up
                Thread.sleep(forTimeInterval: 2.0)
                
                DispatchQueue.main.async {
                    checkOllamaStatus()
                    isStartingOllama = false
                }
            } catch {
                DispatchQueue.main.async {
                    isStartingOllama = false
                    print("Failed to start Ollama: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
            
            OllamaView()
                .tabItem {
                    Label("Ollama", systemImage: "server.rack")
                }
            
            LicenseView()
                .tabItem {
                    Label("License", systemImage: "doc.text")
                }
        }
        .frame(width: 480, height: 580)
    }
}

struct InstructionRow: View {
    let shortcut: String
    let description: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(colorScheme == .dark ? Color(.sRGB, white: 0.2, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
                .cornerRadius(6)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
} 