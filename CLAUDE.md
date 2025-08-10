# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Promptly is a macOS menubar application built with Swift and SwiftUI that provides AI-powered assistance through global text selection. The app integrates with Ollama for local AI processing and allows users to trigger AI queries from any application via keyboard shortcuts.

## Development Environment

- **Platform**: macOS 13.0 or later
- **Language**: Swift 5.0
- **Framework**: SwiftUI
- **IDE**: Xcode 16.4+
- **Deployment Target**: macOS 15.5
- **Bundle ID**: Javian-Ng.Promptly

## Build Commands

### Building the Application
```bash
# Build using Xcode command line tools
xcodebuild -project Promptly.xcodeproj -scheme Promptly -configuration Debug build

# Or using swift build (from command line)
swift build
```

### Running Tests
```bash
# Run unit tests
xcodebuild test -project Promptly.xcodeproj -scheme Promptly -destination 'platform=macOS'

# Run specific test target
xcodebuild test -project Promptly.xcodeproj -scheme PromptlyTests -destination 'platform=macOS'
```

### Building for Release
```bash
xcodebuild -project Promptly.xcodeproj -scheme Promptly -configuration Release build
```

## Project Structure

### Main Application
- **`Promptly/PromptlyApp.swift`**: Main app entry point using SwiftUI `@main`
- **`Promptly/ContentView.swift`**: Primary UI view (currently basic SwiftUI template)
- **`Promptly/Promptly.entitlements`**: App sandbox entitlements for macOS security

### Testing
- **`PromptlyTests/`**: Unit tests using Swift Testing framework
- **`PromptlyUITests/`**: UI automation tests

### Assets
- **`Promptly/Assets.xcassets/`**: App icons and visual assets
  - AppIcon.appiconset for menubar and application icons
  - AccentColor.colorset for app theming

## Key Architecture Notes

This appears to be a fresh rebuild of the Promptly application. The git status shows many deleted files from a previous implementation, suggesting this is a new implementation starting from the Xcode template.

### Expected Features (Based on README)
The application is designed to support:
- Global text selection from any macOS application
- Menubar integration for quick access
- Keyboard shortcut customization
- Ollama API integration for AI processing
- Native macOS UI with SwiftUI

### Security Considerations
- App uses sandboxing (`com.apple.security.app-sandbox`)
- Limited file access permissions (`com.apple.security.files.user-selected.read-only`)
- Will require accessibility permissions for global text capture

## Development Notes

- The current codebase appears to be in early development stage with basic SwiftUI template code
- The project uses Swift Testing framework (not XCTest) for unit tests
- No external dependencies are currently configured in the Xcode project
- The application will need significant implementation to match the features described in the README

## Testing Framework

Uses Swift Testing (`import Testing`) instead of XCTest. Test files should:
- Import the main module with `@testable import Promptly`
- Use `@Test` attribute for test functions
- Use `#expect(...)` for assertions instead of XCTest assertions