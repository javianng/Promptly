//
//  TextSelectionService.swift
//  Promptly
//
//  Created by Claude on 10/8/25.
//

import AppKit
import Carbon
import Foundation

@MainActor
protocol TextSelectionServiceProtocol {
  func getMouseSelectedText() -> String?
}

@MainActor
class TextSelectionService: ObservableObject, TextSelectionServiceProtocol {

  func getMouseSelectedText() -> String? {
    // Get the frontmost application
    guard let app = NSWorkspace.shared.frontmostApplication else { return nil }

    // Get the AXUIElement for the application
    let appRef = AXUIElementCreateApplication(app.processIdentifier)

    // Get the focused element
    var focusedElement: AnyObject?
    let focusedResult = AXUIElementCopyAttributeValue(
      appRef, kAXFocusedUIElementAttribute as CFString, &focusedElement)

    if focusedResult == .success {
      // Try to get selected text from the focused element
      var selectedText: AnyObject?
      let selectedResult = AXUIElementCopyAttributeValue(
        focusedElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)

      if selectedResult == .success, let text = selectedText as? String {
        return text
      }

      // Also try to get selected text range for more complex selections
      var selectedRange: AnyObject?
      let rangeResult = AXUIElementCopyAttributeValue(
        focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRange)

      if rangeResult == .success, let range = selectedRange {
        var valueText: AnyObject?
        let valueResult = AXUIElementCopyAttributeValue(
          focusedElement as! AXUIElement, kAXValueAttribute as CFString, &valueText)

        if valueResult == .success, let fullText = valueText as? String {
          // Extract text based on range if possible
          if let rangeValue = range as? CFRange {
            let startIndex = fullText.index(fullText.startIndex, offsetBy: rangeValue.location)
            let endIndex = fullText.index(startIndex, offsetBy: rangeValue.length)
            return String(fullText[startIndex..<endIndex])
          }
        }
      }
    }

    // If we couldn't get the text through accessibility, try the pasteboard fallback
    let pasteboard = NSPasteboard.general
    let oldContent = pasteboard.string(forType: .string)

    // Simulate Command+C to copy selected text
    let source = CGEventSource(stateID: .hidSystemState)
    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)  // 'C' key
    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)

    keyDown?.flags = .maskCommand
    keyUp?.flags = .maskCommand

    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)

    // Small delay to allow pasteboard to update
    Thread.sleep(forTimeInterval: 0.1)

    let newContent = pasteboard.string(forType: .string)

    // If the content changed, return the new content, otherwise restore old content
    if newContent != oldContent, let selectedText = newContent {
      return selectedText
    } else {
      // Restore original clipboard content if we didn't get new text
      if let oldContent = oldContent {
        pasteboard.clearContents()
        pasteboard.setString(oldContent, forType: .string)
      }
    }

    return nil
  }
}
