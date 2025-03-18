import SwiftUI

struct HoverableLink: View {
    let icon: String
    let url: String
    let tooltip: String
    @State private var isHovering = false
    
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
    
    var body: some View {
        VStack(spacing: 20) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .cornerRadius(16)
            }
            
            Text("Promptly")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
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
            .padding(.vertical)
            
            Text("Promptly helps you be more productive with AI-powered assistance, right from your menubar.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 8) {
                Text("Developed by Javian Ng")
                    .font(.headline)
                
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
        .padding(32)
    }
}

struct LicenseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("MIT License")
                    .font(.title)
                    .padding(.bottom, 8)
                
                Text("""
                Copyright (©) 2025 Javian Ng

                Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                """)
                .font(.body)
                .foregroundColor(.primary)
            }
            .padding(32)
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
            
            LicenseView()
                .tabItem {
                    Label("License", systemImage: "doc.text")
                }
        }
        .frame(width: 500, height: 600)
    }
}

struct InstructionRow: View {
    let shortcut: String
    let description: String
    
    var body: some View {
        HStack {
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)
            
            Text(description)
                .foregroundColor(.primary)
        }
    }
}

#Preview("Content View") {
    ContentView()
}

#Preview("Main View") {
    MainView()
        .frame(width: 500, height: 600)
}

#Preview("License View") {
    LicenseView()
        .frame(width: 500, height: 600)
}

#Preview("Instruction Row") {
    InstructionRow(shortcut: "⌘ + ⇧ + I", description: "Sample instruction")
        .padding()
} 