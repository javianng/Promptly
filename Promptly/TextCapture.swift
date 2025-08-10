//
//  TextCapture.swift
//  Promptly
//
//  Created by Javian Ng on 10/8/25.
//

import Foundation
import AppKit
import ApplicationServices

class TextCapture {
    
    func getSelectedText() -> String? {
        // First try to get text via clipboard (most reliable method)
        if let clipboardText = getTextViaClipboard() {
            return clipboardText
        }
        
        // Fallback: Try accessibility API
        if let accessibilityText = getTextViaAccessibility() {
            return accessibilityText
        }
        
        return nil
    }
    
    private func getTextViaClipboard() -> String? {
        // Save current clipboard content
        let pasteboard = NSPasteboard.general
        let previousClipboard = pasteboard.string(forType: .string)
        
        // Clear clipboard
        pasteboard.clearContents()
        
        // Simulate Cmd+C to copy selected text
        let cmdCEvent = CGEvent(keyboardEventSource: nil, virtualKey: 8, keyDown: true) // C key
        cmdCEvent?.flags = .maskCommand
        cmdCEvent?.post(tap: .cghidEventTap)
        
        let cmdCEventUp = CGEvent(keyboardEventSource: nil, virtualKey: 8, keyDown: false)
        cmdCEventUp?.flags = .maskCommand
        cmdCEventUp?.post(tap: .cghidEventTap)
        
        // Small delay to allow copy operation to complete
        usleep(100000) // 0.1 seconds
        
        // Get the copied text
        let copiedText = pasteboard.string(forType: .string)
        
        // Restore previous clipboard content if we had any
        if let previousClipboard = previousClipboard {
            pasteboard.clearContents()
            pasteboard.setString(previousClipboard, forType: .string)
        } else {
            pasteboard.clearContents()
        }
        
        return copiedText
    }
    
    private func getTextViaAccessibility() -> String? {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        let app = AXUIElementCreateApplication(focusedApp.processIdentifier)
        var focusedElement: CFTypeRef?
        
        if AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focusedElement) == .success,
           let element = focusedElement {
            
            var selectedText: CFTypeRef?
            if AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText) == .success,
               let text = selectedText as? String {
                return text
            }
            
            // Fallback: try to get value attribute
            var value: CFTypeRef?
            if AXUIElementCopyAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, &value) == .success,
               let text = value as? String {
                return text
            }
        }
        
        return nil
    }
    
    func requestAccessibilityPermissions() -> Bool {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options as CFDictionary)
        }
        return trusted
    }
}