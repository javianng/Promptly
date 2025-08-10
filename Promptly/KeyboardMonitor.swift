//
//  KeyboardMonitor.swift
//  Promptly
//
//  Created by Javian Ng on 10/8/25.
//

import Foundation
import AppKit
import Carbon

class KeyboardMonitor {
    var onShortcutPressed: (() -> Void)?
    private var eventTap: CFMachPort?
    
    func startMonitoring() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon!).takeUnretainedValue() as KeyboardMonitor? else {
                    return Unmanaged.passUnretained(event)
                }
                return monitor.handleKeyEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            requestAccessibilityPermissions()
            return
        }
        
        self.eventTap = eventTap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }
    
    private func handleKeyEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            // Option + Spacebar: keyCode 49 is spacebar, option modifier
            if keyCode == 49 && flags.contains(.maskAlternate) && !flags.contains(.maskCommand) && !flags.contains(.maskControl) {
                onShortcutPressed?()
                // Consume the event so it doesn't propagate
                return nil
            }
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    private func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Accessibility permissions not granted")
            DispatchQueue.main.async {
                self.showPermissionAlert()
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Promptly needs accessibility permissions to capture global keyboard shortcuts. Please grant permission in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    deinit {
        stopMonitoring()
    }
}