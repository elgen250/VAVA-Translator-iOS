import SwiftUI

/// Brand design tokens and color scheme for VAVA Translator.
public extension Color {
    /// Primary Brand Identity - Deep Electric Indigo
    static let vavaPrimary = Color(red: 0.28, green: 0.38, blue: 0.96)
    
    /// Secondary Accent - Luminous Teal Cyan
    static let vavaAccent = Color(red: 0.08, green: 0.72, blue: 0.82)
    static let vavaSecondary = Color(red: 0.08, green: 0.72, blue: 0.82)

    /// Success / Installed status color
    static let vavaSuccess = Color(red: 0.13, green: 0.77, blue: 0.44)

    /// Surface Card Background (Adapts dynamically to Light/Dark mode)
    static let vavaCardBackground = Color(uiColor: .secondarySystemGroupedBackground)

    /// Surface Background for parent screens
    static let vavaScreenBackground = Color(uiColor: .systemGroupedBackground)
    static let vavaBackground = Color(uiColor: .systemGroupedBackground)

    /// Subdued text and border tone
    static let vavaBorder = Color(uiColor: .separator).opacity(0.4)
}

public extension LinearGradient {
    /// Hero gradient for active buttons and header accents
    static let vavaHero = LinearGradient(
        colors: [Color.vavaPrimary, Color.vavaAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
