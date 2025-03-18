import SwiftUI

struct ContentView: View {
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
                    shortcut: "⌘ + ⇧ + P",
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
                    Link(destination: URL(string: "https://www.javianng.com")!) {
                        Image(systemName: "globe")
                            .font(.title2)
                    }
                    
                    Link(destination: URL(string: "https://www.linkedin.com/in/javianngzh/")!) {
                        Image(systemName: "link.circle")
                            .font(.title2)
                    }
                    
                    Link(destination: URL(string: "https://github.com/javianng")!) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.title2)
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .padding(32)
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