# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Promptly is a macOS menubar application that provides AI-powered assistance through text selection and keyboard shortcuts. It's built with Swift and SwiftUI, targeting macOS 13.0+.

**Key Features:**
- Global text selection from any application
- Customizable keyboard shortcuts (default ⌘⇧I)
- Ollama integration for local AI processing
- Menubar integration with minimal resource usage
- Native SwiftUI interface

## Development Commands

### Building
```bash
# Open in Xcode (recommended)
open Promptly.xcodeproj

# Command line build
swift build
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme Promptly -destination 'platform=macOS'

# Run UI tests
xcodebuild test -scheme Promptly -destination 'platform=macOS' -only-testing:PromptlyUITests
```

### Running
- Build and run through Xcode
- The app requires accessibility permissions to capture text from other applications

## Architecture

The project follows MVVM architecture with a clean separation of concerns:

### Directory Structure
```
Promptly/
├── App/                          # Core app entry point
│   ├── PromptlyApp.swift         # Main app entry point
│   └── Promptly.entitlements     # App sandbox entitlements
├── Assets/                       # Resources
│   └── Assets.xcassets           # App icons, colors, images
├── Views/                        # SwiftUI UI components
│   ├── ContentView.swift         # Main UI view
│   └── Components/               # Reusable UI components
├── ViewModels/                   # ObservableObject classes (MVVM)
├── Services/                     # Business logic and external integrations
├── Models/                       # Data structures and enums
├── Utils/                        # Helper functions and extensions
└── Config/                       # Configuration files
```

### Architectural Patterns
- **MVVM**: ViewModels act as the bridge between Views and Services
- **Dependency Injection**: Services are injected into ViewModels for testability
- **Single Responsibility**: Each directory has a focused purpose

### Project Configuration
- **Xcode Project**: Standard iOS/macOS project structure
- **Deployment Target**: macOS 13.0 (15.5 in build settings)
- **Swift Version**: 5.0
- **Team ID**: 8696PZW8HY
- **Bundle ID**: Javian-Ng.Promptly

### Dependencies
- **Ollama**: Required external dependency for AI processing
- **SwiftUI**: Primary UI framework
- **Foundation**: Core Swift framework

### Build Targets
- **Promptly**: Main application target
- **PromptlyTests**: Unit test target
- **PromptlyUITests**: UI test target

## Important Notes

- The current codebase appears to be in early development - ContentView.swift contains template "Hello, world!" content
- App requires Ollama to be installed and running for AI functionality
- Accessibility permissions are required for global text selection
- App uses hardened runtime and app sandbox for security

## Requirements
- macOS 13.0 or later
- Xcode 14.0+ for development
- Ollama installed for AI functionality