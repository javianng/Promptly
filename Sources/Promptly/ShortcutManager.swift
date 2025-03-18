import SwiftUI
import AppKit

class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()
    
    @Published var currentShortcut: (keyCode: Int, modifiers: NSEvent.ModifierFlags)?
    private var shortcutMonitor: Any?
    
    private init() {
        loadSavedShortcut()
    }
    
    func loadSavedShortcut() {
        if let shortcutString = UserDefaults.standard.string(forKey: "customShortcut") {
            // Default to Cmd+Shift+I if no custom shortcut is set
            if shortcutString == "⌘ + ⇧ + I" {
                currentShortcut = (keyCode: 34, modifiers: [.command, .shift])
            } else {
                // Parse the custom shortcut string
                var modifiers: NSEvent.ModifierFlags = []
                var remainingString = shortcutString
                
                // Parse modifiers
                if remainingString.contains("⌘") {
                    modifiers.insert(.command)
                    remainingString = remainingString.replacingOccurrences(of: "⌘", with: "")
                }
                if remainingString.contains("⇧") {
                    modifiers.insert(.shift)
                    remainingString = remainingString.replacingOccurrences(of: "⇧", with: "")
                }
                if remainingString.contains("⌥") {
                    modifiers.insert(.option)
                    remainingString = remainingString.replacingOccurrences(of: "⌥", with: "")
                }
                if remainingString.contains("⌃") {
                    modifiers.insert(.control)
                    remainingString = remainingString.replacingOccurrences(of: "⌃", with: "")
                }
                
                // Remove + symbols and whitespace
                remainingString = remainingString.replacingOccurrences(of: "+", with: "")
                
                // Get the key code for the remaining character
                let key = remainingString.trimmingCharacters(in: .whitespaces)
                let keyCode = stringToKeyCode(key)
                
                currentShortcut = (keyCode: keyCode, modifiers: modifiers)
            }
        } else {
            // Default shortcut
            currentShortcut = (keyCode: 34, modifiers: [.command, .shift])
            // Save the default shortcut with the new format
            UserDefaults.standard.set("⌘ + ⇧ + I", forKey: "customShortcut")
        }
    }
    
    private func stringToKeyCode(_ key: String) -> Int {
        // Common key codes
        let keyCodes: [String: Int] = [
            "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7,
            "C": 8, "V": 9, "B": 11, "Q": 12, "W": 13, "E": 14, "R": 15,
            "Y": 16, "T": 17, "O": 31, "U": 32, "I": 34, "P": 35, "L": 37,
            "J": 38, "K": 40, "N": 45, "M": 46
        ]
        
        return keyCodes[key] ?? 34 // Default to 'I' if key not found
    }
    
    func startRecording() {
        shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleShortcutRecording(event)
            return nil
        }
    }
    
    func stopRecording() {
        if let monitor = shortcutMonitor {
            NSEvent.removeMonitor(monitor)
            shortcutMonitor = nil
        }
    }
    
    private func handleShortcutRecording(_ event: NSEvent) {
        let modifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
        currentShortcut = (keyCode: Int(event.keyCode), modifiers: modifiers)
        
        // Convert to human-readable format
        let shortcutString = shortcutToString(keyCode: Int(event.keyCode), modifiers: modifiers)
        UserDefaults.standard.set(shortcutString, forKey: "customShortcut")
    }
    
    func shortcutToString(keyCode: Int, modifiers: NSEvent.ModifierFlags) -> String {
        var parts: [String] = []
        
        if modifiers.contains(.command) { parts.append("⌘") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.control) { parts.append("⌃") }
        
        let key = keyCodeToString(keyCode)
        parts.append(key)
        
        return parts.joined(separator: " + ")
    }
    
    private func keyCodeToString(_ keyCode: Int) -> String {
        // Common key codes
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 40: return "K"
        case 45: return "N"
        case 46: return "M"
        default: return "[\(keyCode)]"
        }
    }
} 