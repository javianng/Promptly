//
//  PromptlyApp.swift
//  Promptly
//
//  Created by Javian Ng on 10/8/25.
//

import SwiftUI
import AppKit

@main
struct PromptlyApp: App {
    @StateObject private var appDelegate = AppDelegate()
    
    var body: some Scene {
        MenuBarExtra("Promptly", systemImage: "wand.and.rays") {
            Button("Quit Promptly") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}

class AppDelegate: NSObject, ObservableObject {
    private var keyboardMonitor: KeyboardMonitor?
    private var textCapture: TextCapture?
    
    override init() {
        super.init()
        setupGlobalShortcut()
    }
    
    private func setupGlobalShortcut() {
        keyboardMonitor = KeyboardMonitor()
        textCapture = TextCapture()
        
        keyboardMonitor?.onShortcutPressed = { [weak self] in
            self?.handleShortcut()
        }
        
        keyboardMonitor?.startMonitoring()
    }
    
    private func handleShortcut() {
        guard let selectedText = textCapture?.getSelectedText() else {
            return
        }
        
        DispatchQueue.main.async {
            self.showQueryDialog(with: selectedText)
        }
    }
    
    private func showQueryDialog(with text: String) {
        let dialogView = QueryDialogView(selectedText: text)
        let hostingController = NSHostingController(rootView: dialogView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 500, height: 300))
        window.styleMask = [.titled, .closable]
        window.title = "Promptly Query"
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
    }
}
