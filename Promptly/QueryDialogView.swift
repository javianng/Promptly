//
//  QueryDialogView.swift
//  Promptly
//
//  Created by Javian Ng on 10/8/25.
//

import SwiftUI

struct QueryDialogView: View {
    let selectedText: String
    @State private var query: String = ""
    @State private var isProcessing: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "wand.and.rays")
                    .foregroundColor(.blue)
                Text("Promptly Query")
                    .font(.headline)
                Spacer()
                Button(action: closeDialog) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            // Selected text display
            VStack(alignment: .leading, spacing: 8) {
                Text("Selected Text:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView {
                    Text(selectedText.isEmpty ? "No text selected" : selectedText)
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        .border(Color(.separatorColor), width: 1)
                }
                .frame(height: 100)
            }
            
            // Query input
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Query:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextEditor(text: $query)
                    .font(.body)
                    .padding(8)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                    .border(Color(.separatorColor), width: 1)
                    .frame(height: 80)
            }
            
            // Action buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    closeDialog()
                }
                .keyboardShortcut(.escape)
                
                Button("Process Query") {
                    processQuery()
                }
                .buttonStyle(.borderedProminent)
                .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                .keyboardShortcut(.return)
            }
            
            if isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing query...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .frame(width: 500, height: 350)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            // Focus on query text field when dialog appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }
    
    private func processQuery() {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isProcessing = true
        
        // TODO: Integrate with AI service (Ollama)
        // For now, just simulate processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessing = false
            // TODO: Show result in a new window or copy to clipboard
            showResult()
        }
    }
    
    private func showResult() {
        let alert = NSAlert()
        alert.messageText = "Query Processed"
        alert.informativeText = "Selected text: '\(selectedText.prefix(50))...'\nQuery: '\(query)'"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        closeDialog()
    }
    
    private func closeDialog() {
        // Close the current window
        if let window = NSApp.keyWindow {
            window.close()
        }
    }
}

#Preview {
    QueryDialogView(selectedText: "This is some sample selected text that would be captured from any application window.")
        .frame(width: 500, height: 350)
}