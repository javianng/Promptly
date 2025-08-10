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
# Run all tests
xcodebuild test -scheme Promptly -destination 'platform=macOS'

# Run only unit tests
xcodebuild test -scheme Promptly -destination 'platform=macOS' -only-testing:PromptlyTests

# Run UI tests
xcodebuild test -scheme Promptly -destination 'platform=macOS' -only-testing:PromptlyUITests

# Run specific test classes
xcodebuild test -scheme Promptly -destination 'platform=macOS' -only-testing:PromptlyTests/OllamaServiceTests
xcodebuild test -scheme Promptly -destination 'platform=macOS' -only-testing:PromptlyTests/TextSelectionServiceTests
```

**Test Prerequisites:**
- Ollama must be running: `ollama serve`
- Install required model: `ollama pull gemma3n:latest`
- Grant accessibility permissions for text selection tests

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
│   ├── ContentView.swift         # Main UI view (template content)
│   └── Components/               # Reusable UI components (empty)
├── ViewModels/                   # ObservableObject classes (empty, ready for MVVM)
├── Services/                     # Business logic and external integrations
│   ├── OllamaService.swift       # Ollama API integration service
│   └── TextSelectionService.swift # Global text selection service
├── Models/                       # Data structures and enums
│   ├── OllamaRequest.swift       # Request models for Ollama API
│   ├── OllamaResponse.swift      # Response models and result types
│   └── OllamaError.swift         # Error types and handling
├── Utils/                        # Helper functions and extensions (empty)
└── Config/                       # Configuration files
    └── AppConfig.swift           # App and Ollama configuration
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

- **Ollama**: Required external dependency for AI processing (localhost:11434)
- **SwiftUI**: Primary UI framework
- **Foundation**: Core Swift framework
- **AppKit**: For accessibility and clipboard operations
- **Carbon**: For global keyboard event simulation

### Current Model Configuration

- **Default Model**: "gemma3n:latest"
- **Fallback Models**: Check AppConfig.swift for alternatives
- **Model Requirements**: Model must support streaming responses

### Build Targets

- **Promptly**: Main application target
- **PromptlyTests**: Unit test target
- **PromptlyUITests**: UI test target

## Current Implementation Status

The project has evolved significantly from the initial template:

### Implemented Features

- **Core Services**:
  - `OllamaService`: Complete integration with Ollama API supporting streaming and non-streaming responses
  - `TextSelectionService`: Accessibility-based text selection with clipboard fallback mechanism
  - Both services include comprehensive error handling and cancellation support

- **Data Models**:
  - `OllamaRequest`: Configurable request structure with options for temperature, top_p, etc.
  - `OllamaResponse`: Separate models for streaming and complete responses
  - `OllamaError`: Comprehensive error handling for various failure scenarios

- **Configuration**:
  - `AppConfig`: Centralized configuration with UserDefaults integration
  - Default model: "gemma3n:latest"
  - Configurable base URL, timeout, retry logic

### Testing Infrastructure

- **Unit Tests**: Complete test coverage for both core services
- **OllamaServiceTests**: Tests connectivity, model availability, streaming, cancellation, and retry mechanisms
- **TextSelectionServiceTests**: Tests accessibility integration, clipboard handling, and error scenarios
- Uses Swift Testing framework with detailed logging and diagnostics

### Architecture Status

- **MVVM Ready**: Services are protocol-based and injectable for ViewModels
- **UI**: Currently still uses template ContentView - main UI implementation pending
- **Error Handling**: Robust error types and recovery mechanisms implemented
- **Concurrency**: Full async/await support with proper cancellation

## Important Notes

- App requires Ollama to be installed and running for AI functionality
- Accessibility permissions are required for global text selection
- App uses hardened runtime and app sandbox for security
- Main UI implementation is still pending - currently shows template content

## Requirements

- macOS 13.0 or later
- Xcode 14.0+ for development
- Ollama installed for AI functionality
