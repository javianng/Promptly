import SwiftUI

// Standardized button dimensions
struct StandardButtonStyle: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    
    let isPrimary: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(height: 28) // Standard minimalistic height
            .padding(.horizontal, 12) // Standard horizontal padding
            .background(
                isPrimary 
                ? Color.accentColor
                : (colorScheme == .dark ? Color(.sRGB, white: 0.2, opacity: 1) : Color(.sRGB, white: 0.95, opacity: 1))
            )
            .foregroundColor(
                isPrimary 
                ? .white 
                : (colorScheme == .dark ? .white : .primary)
            )
            .cornerRadius(6)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// Extensions to make it easier to apply the standard styling
extension View {
    func standardButtonStyle(primary: Bool = false) -> some View {
        self.modifier(StandardButtonStyle(isPrimary: primary))
    }
}

// Pre-defined button styles that follow the standard dimensions
struct MinimalButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(StandardButtonStyle(isPrimary: isPrimary))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension ButtonStyle where Self == MinimalButtonStyle {
    static var minimal: MinimalButtonStyle {
        MinimalButtonStyle(isPrimary: false)
    }
    
    static var minimalPrimary: MinimalButtonStyle {
        MinimalButtonStyle(isPrimary: true)
    }
} 