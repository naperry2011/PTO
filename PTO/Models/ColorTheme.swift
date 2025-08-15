import SwiftUI

/// AppearanceMode represents the user's appearance preference
enum AppearanceMode: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var displayName: String {
        return rawValue
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

/// Semantic color system for the PTO app that adapts to light and dark modes
struct AppColors {
    
    // MARK: - Primary Colors
    
    /// Primary background color for main content areas
    static let primaryBackground = Color("PrimaryBackground", fallback: Color(.systemBackground))
    
    /// Secondary background for cards and elevated content
    static let secondaryBackground = Color("SecondaryBackground", fallback: Color(.secondarySystemBackground))
    
    /// Tertiary background for grouped content
    static let tertiaryBackground = Color("TertiaryBackground", fallback: Color(.tertiarySystemBackground))
    
    /// Background for cards and containers
    static let cardBackground = Color("CardBackground", fallback: Color(.systemBackground))
    
    // MARK: - Text Colors
    
    /// Primary text color
    static let primaryText = Color("PrimaryText", fallback: Color(.label))
    
    /// Secondary text color for less important content
    static let secondaryText = Color("SecondaryText", fallback: Color(.secondaryLabel))
    
    /// Tertiary text color for subtle content
    static let tertiaryText = Color("TertiaryText", fallback: Color(.tertiaryLabel))
    
    // MARK: - Accent Colors
    
    /// Primary accent color (earnings, success states)
    static let accent = Color("AccentColor", fallback: .green)
    
    /// Secondary accent color
    static let secondaryAccent = Color("SecondaryAccent", fallback: .blue)
    
    /// Warning/alert color
    static let warning = Color("WarningColor", fallback: .orange)
    
    /// Error/danger color
    static let error = Color("ErrorColor", fallback: .red)
    
    // MARK: - Interactive Colors
    
    /// Color for interactive elements in normal state
    static let interactive = Color("InteractiveColor", fallback: .blue)
    
    /// Color for pressed/active interactive elements
    static let interactivePressed = Color("InteractivePressedColor", fallback: Color.blue.opacity(0.7))
    
    // MARK: - Border and Separator Colors
    
    /// Standard border color
    static let border = Color("BorderColor", fallback: Color(.separator))
    
    /// Subtle border color for cards
    static let subtleBorder = Color("SubtleBorderColor", fallback: Color(.separator).opacity(0.3))
    
    // MARK: - Overlay Colors
    
    /// Standard overlay for modals and sheets
    static let overlay = Color("OverlayColor", fallback: Color.black.opacity(0.4))
    
    /// Light overlay for subtle backgrounds
    static let lightOverlay = Color("LightOverlayColor", fallback: Color.black.opacity(0.1))
    
    // MARK: - Gradient Colors
    
    /// Primary gradient colors
    static let gradientPrimary = [
        Color("GradientPrimary1", fallback: .green),
        Color("GradientPrimary2", fallback: .blue)
    ]
    
    /// Secondary gradient colors
    static let gradientSecondary = [
        Color("GradientSecondary1", fallback: .orange),
        Color("GradientSecondary2", fallback: .red)
    ]
    
    /// Danger gradient colors
    static let gradientDanger = [
        Color("GradientDanger1", fallback: .red),
        Color("GradientDanger2", fallback: .orange)
    ]
    
    // MARK: - Timer Specific Colors
    
    /// Timer circle background
    static let timerBackground = Color("TimerBackground", fallback: Color(.systemGray5))
    
    /// Timer progress colors
    static let timerProgress = [
        Color("TimerProgress1", fallback: .green),
        Color("TimerProgress2", fallback: .blue),
        Color("TimerProgress3", fallback: .mint)
    ]
    
    /// Timer inactive state
    static let timerInactive = Color("TimerInactive", fallback: Color(.systemGray4))
    
    // MARK: - Card Shadow Colors
    
    /// Standard shadow color for cards
    static let cardShadow = Color("CardShadow", fallback: Color.black.opacity(0.05))
    
    /// Elevated shadow color for important cards
    static let elevatedShadow = Color("ElevatedShadow", fallback: Color.black.opacity(0.1))
}

/// Color extension for creating colors with fallbacks
extension Color {
    init(_ name: String, fallback: Color) {
        if let uiColor = UIColor(named: name) {
            self.init(uiColor)
        } else {
            self = fallback
        }
    }
}

/// Environment-aware color schemes
extension EnvironmentValues {
    private struct AppearanceModeKey: EnvironmentKey {
        static let defaultValue: AppearanceMode = .system
    }
    
    var appearanceMode: AppearanceMode {
        get { self[AppearanceModeKey.self] }
        set { self[AppearanceModeKey.self] = newValue }
    }
}

extension View {
    func appearanceMode(_ mode: AppearanceMode) -> some View {
        environment(\.appearanceMode, mode)
    }
}

/// Material effects that adapt to appearance
struct AppMaterials {
    /// Ultra thin material for backgrounds
    static let ultraThin = Material.ultraThinMaterial
    
    /// Thin material for cards
    static let thin = Material.thinMaterial
    
    /// Regular material for elevated content
    static let regular = Material.regularMaterial
    
    /// Thick material for important overlays
    static let thick = Material.thickMaterial
}

/// Dynamic shadows that adapt to color scheme
extension View {
    func dynamicCardShadow(colorScheme: ColorScheme) -> some View {
        self.shadow(
            color: colorScheme == .dark ? AppColors.cardShadow.opacity(0.3) : AppColors.cardShadow,
            radius: colorScheme == .dark ? 8 : 5,
            x: 0,
            y: colorScheme == .dark ? 4 : 2
        )
    }
    
    func dynamicElevatedShadow(colorScheme: ColorScheme) -> some View {
        self.shadow(
            color: colorScheme == .dark ? AppColors.elevatedShadow.opacity(0.4) : AppColors.elevatedShadow,
            radius: colorScheme == .dark ? 12 : 8,
            x: 0,
            y: colorScheme == .dark ? 6 : 4
        )
    }
}