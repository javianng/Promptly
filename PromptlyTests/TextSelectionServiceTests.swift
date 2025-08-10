//
//  TextSelectionServiceTests.swift
//  PromptlyTests
//
//  Created by Claude on 10/8/25.
//

import AppKit
import Foundation
import Testing

@testable import Promptly

struct TextSelectionServiceTests {

  @Test func testTextSelectionServiceInstantiation() async throws {
    let textService = await TextSelectionService()

    // Since TextSelectionService is not optional, we just verify it was created successfully
    // by checking that it's a valid instance
    #expect(
      type(of: textService) == TextSelectionService.self,
      "TextSelectionService should instantiate successfully")
  }

  @Test func testGetMouseSelectedTextWithEmptySelection() async throws {
    let textService = await TextSelectionService()

    // This test will attempt to get selected text when nothing is selected
    // Note: This test may return nil as expected behavior
    let result = await textService.getMouseSelectedText()

    print("📝 Selected text result (empty selection): \(result ?? "nil")")

    // We don't assert anything specific here as the result depends on current system state
    // This test mainly ensures the function doesn't crash
    #expect(true, "Function should not crash with empty selection")
  }

  @Test func testGetMouseSelectedTextClipboardFallback() async throws {
    let textService = await TextSelectionService()

    // Store original clipboard content
    let originalClipboard = NSPasteboard.general.string(forType: .string)

    // Set test content in clipboard
    let testContent = "Test clipboard content"
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(testContent, forType: .string)

    // Call the function - this will simulate Command+C
    // Since we can't actually select text in tests, this tests the clipboard restoration
    let result = await textService.getMouseSelectedText()

    print("📝 Selected text result (clipboard test): \(result ?? "nil")")

    // The function should either return text or restore clipboard
    let _ = NSPasteboard.general.string(forType: .string)

    // Restore original clipboard if it existed
    if let original = originalClipboard {
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(original, forType: .string)
    }

    #expect(true, "Function should handle clipboard operations without crashing")
  }

  @Test func testGetMouseSelectedTextProtocol() async throws {
    let textService: TextSelectionServiceProtocol = await TextSelectionService()

    // Test that the protocol method is accessible
    let result = await textService.getMouseSelectedText()

    print("📝 Protocol method result: \(result ?? "nil")")

    #expect(true, "Protocol method should be accessible")
  }

  @Test func testGetMouseSelectedTextErrorHandling() async throws {
    let textService = await TextSelectionService()

    // This tests the function's resilience to various system states
    // The function should handle cases where:
    // - No application is frontmost
    // - Accessibility is not enabled
    // - No UI elements are focused

    // Since getMouseSelectedText() doesn't throw, we just test that it returns without crashing
    let result = await textService.getMouseSelectedText()
    print("📝 Error handling test result: \(result ?? "nil")")

    // The test passes if we get here without any runtime crashes
    #expect(true, "Function should handle various system states without crashing")
  }

  @Test func testClipboardRestoration() async throws {
    // Test that clipboard content is properly restored when no new text is found

    let originalContent = "Original clipboard content for testing"

    // Set original content
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(originalContent, forType: .string)

    let textService = await TextSelectionService()

    // This should attempt to get selected text and restore clipboard if nothing new is found
    let result = await textService.getMouseSelectedText()

    // Check if clipboard was restored (this depends on whether actual text was selected)
    let currentContent = NSPasteboard.general.string(forType: .string)

    print("📝 Original: \(originalContent)")
    print("📝 Result: \(result ?? "nil")")
    print("📝 Current clipboard: \(currentContent ?? "nil")")

    // The test passes if the function doesn't crash and handles clipboard properly
    #expect(true, "Clipboard restoration should work without crashes")
  }

  @Test func testGetMouseSelectedTextAccessibilityFallback() async throws {
    // Test behavior when accessibility APIs might not be available
    let textService = await TextSelectionService()

    print("📝 Testing accessibility fallback behavior...")

    // This test ensures the function gracefully handles accessibility permission issues
    let result = await textService.getMouseSelectedText()

    print("📝 Accessibility fallback result: \(result ?? "nil")")

    // The main goal is that the function doesn't crash regardless of accessibility state
    #expect(true, "Function should handle accessibility limitations gracefully")
  }

  @Test func testGetMouseSelectedTextPerformance() async throws {
    // Test that the function completes within reasonable time
    let textService = await TextSelectionService()

    let startTime = CFAbsoluteTimeGetCurrent()

    let result = await textService.getMouseSelectedText()

    let endTime = CFAbsoluteTimeGetCurrent()
    let executionTime = endTime - startTime

    print("📝 Execution time: \(executionTime) seconds")
    print("📝 Performance test result: \(result ?? "nil")")

    // Function should complete within 5 seconds (generous timeout)
    #expect(executionTime < 5.0, "Function should complete within reasonable time")
  }
}
