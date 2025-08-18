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

/// Anti-Corporate Rebellion color system - Corporate aesthetics with subversive content
struct AppColors {
    
    // MARK: - Corporate Rebellion Colors
    
    /// Primary background - Corporate sterile white/dark
    static let primaryBackground = Color("PrimaryBackground", fallback: Color(.systemBackground))
    
    /// Secondary background - Corporate gray hierarchy
    static let secondaryBackground = Color("SecondaryBackground", fallback: Color(.secondarySystemBackground))
    
    /// Tertiary background - Bland corporate grouping
    static let tertiaryBackground = Color("TertiaryBackground", fallback: Color(.tertiarySystemBackground))
    
    /// Card background - Corporate container styling
    static let cardBackground = Color("CardBackground", fallback: Color(.systemBackground))
    
    // MARK: - Corporate Text Hierarchy
    
    /// Executive-level text (primary importance)
    static let primaryText = Color("PrimaryText", fallback: Color(.label))
    
    /// Middle-management text (secondary importance)
    static let secondaryText = Color("SecondaryText", fallback: Color(.secondaryLabel))
    
    /// Intern-level text (tertiary importance)
    static let tertiaryText = Color("TertiaryText", fallback: Color(.tertiaryLabel))
    
    // MARK: - Corporate Status Colors
    
    /// Money green (the only color that matters to corporate)
    static let accent = Color("AccentColor", fallback: Color(red: 0.0, green: 0.6, blue: 0.0))
    
    /// Corporate blue (trust, stability, boring meetings)
    static let secondaryAccent = Color("SecondaryAccent", fallback: Color(red: 0.1, green: 0.4, blue: 0.8))
    
    /// Warning orange (boss approaching, hide phone)
    static let warning = Color("WarningColor", fallback: Color(red: 1.0, green: 0.6, blue: 0.0))
    
    /// Danger red (getting caught, HR involvement)
    static let error = Color("ErrorColor", fallback: Color(red: 0.9, green: 0.2, blue: 0.2))
    
    /// Corporate authority purple (C-suite only)
    static let corporate = Color("CorporateColor", fallback: Color(red: 0.4, green: 0.2, blue: 0.8))
    
    /// Achievement gold (milestone rewards)
    static let rebellion = Color("RebellionColor", fallback: Color(red: 0.9, green: 0.7, blue: 0.1))
    
    // MARK: - Corporate Interaction Colors
    
    /// Interactive corporate blue (clicking costs company money)
    static let interactive = Color("InteractiveColor", fallback: Color(red: 0.1, green: 0.4, blue: 0.8))
    
    /// Pressed state (session active)
    static let interactivePressed = Color("InteractivePressedColor", fallback: Color(red: 0.1, green: 0.4, blue: 0.8).opacity(0.7))
    
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
    
    // MARK: - Corporate Gradient Schemes
    
    /// Money-making gradient (green to gold)
    static let gradientPrimary = [
        Color("GradientPrimary1", fallback: Color(red: 0.0, green: 0.6, blue: 0.0)),
        Color("GradientPrimary2", fallback: Color(red: 0.9, green: 0.7, blue: 0.1))
    ]
    
    /// Corporate authority gradient (blue to purple)
    static let gradientSecondary = [
        Color("GradientSecondary1", fallback: Color(red: 0.1, green: 0.4, blue: 0.8)),
        Color("GradientSecondary2", fallback: Color(red: 0.4, green: 0.2, blue: 0.8))
    ]
    
    /// Warning gradient (orange to red - boss alert)
    static let gradientDanger = [
        Color("GradientDanger1", fallback: Color(red: 1.0, green: 0.6, blue: 0.0)),
        Color("GradientDanger2", fallback: Color(red: 0.9, green: 0.2, blue: 0.2))
    ]
    
    /// Success gradient (gold to green - completed session)
    static let gradientRebellion = [
        Color("GradientRebellion1", fallback: Color(red: 0.9, green: 0.7, blue: 0.1)),
        Color("GradientRebellion2", fallback: Color(red: 0.0, green: 0.6, blue: 0.0))
    ]
    
    // MARK: - Timer Colors
    
    /// Corporate gray clock background (time is money)
    static let timerBackground = Color("TimerBackground", fallback: Color(.systemGray5))
    
    /// Money accumulation progress colors
    static let timerProgress = [
        Color("TimerProgress1", fallback: Color(red: 0.0, green: 0.6, blue: 0.0)),
        Color("TimerProgress2", fallback: Color(red: 0.9, green: 0.7, blue: 0.1)),
        Color("TimerProgress3", fallback: Color(red: 0.1, green: 0.7, blue: 0.1))
    ]
    
    /// Inactive timer (session not started)
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
    
    /// Conditional view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Corporate Design System

/// Standardized spacing tokens for consistent layout
struct DesignTokens {
    // MARK: - Spacing Scale
    static let spacing: (
        xs: CGFloat,
        sm: CGFloat,
        md: CGFloat,
        lg: CGFloat,
        xl: CGFloat,
        xxl: CGFloat
    ) = (
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32,
        xxl: 48
    )
    
    // MARK: - Corner Radius Scale
    static let cornerRadius: (
        sm: CGFloat,
        md: CGFloat,
        lg: CGFloat,
        xl: CGFloat
    ) = (
        sm: 8,
        md: 12,
        lg: 16,
        xl: 20
    )
    
    // MARK: - Typography Scale
    static let typography = CorporateTypography()
}

/// Corporate typography system with consistent hierarchy
struct CorporateTypography {
    
    // MARK: - Headers
    var heroTitle: Font { .system(size: 34, weight: .heavy, design: .default) }
    var largeTitle: Font { .system(size: 28, weight: .bold, design: .default) }
    var title1: Font { .system(size: 24, weight: .bold, design: .default) }
    var title2: Font { .system(size: 20, weight: .semibold, design: .default) }
    var title3: Font { .system(size: 18, weight: .semibold, design: .default) }
    
    // MARK: - Body Text
    var headline: Font { .system(size: 16, weight: .semibold, design: .default) }
    var body: Font { .system(size: 16, weight: .regular, design: .default) }
    var bodyEmphasized: Font { .system(size: 16, weight: .medium, design: .default) }
    var callout: Font { .system(size: 14, weight: .regular, design: .default) }
    
    // MARK: - Support Text
    var subheadline: Font { .system(size: 14, weight: .medium, design: .default) }
    var footnote: Font { .system(size: 12, weight: .regular, design: .default) }
    var caption1: Font { .system(size: 11, weight: .medium, design: .default) }
    var caption2: Font { .system(size: 10, weight: .medium, design: .default) }
    
    // MARK: - Special Purpose
    var monospacedDigit: Font { .system(size: 16, weight: .regular, design: .monospaced) }
    var monospacedLarge: Font { .system(size: 24, weight: .bold, design: .monospaced) }
    var corporateHeader: Font { .system(size: 12, weight: .bold, design: .default) }
}

/// View extensions for consistent styling
extension View {
    // MARK: - Typography Modifiers
    func corporateHeaderStyle() -> some View {
        self
            .font(DesignTokens.typography.corporateHeader)
            .foregroundStyle(AppColors.corporate)
            .textCase(.uppercase)
            .tracking(1.2)
    }
    
    func rebellionHeaderStyle() -> some View {
        self
            .font(DesignTokens.typography.title2)
            .foregroundStyle(AppColors.rebellion)
            .fontWeight(.bold)
            .tracking(0.5)
    }
    
    func corporateBodyStyle() -> some View {
        self
            .font(DesignTokens.typography.body)
            .foregroundStyle(AppColors.primaryText)
    }
    
    func corporateSubheadStyle() -> some View {
        self
            .font(DesignTokens.typography.subheadline)
            .foregroundStyle(AppColors.secondaryText)
    }
    
    func corporateCaptionStyle() -> some View {
        self
            .font(DesignTokens.typography.caption1)
            .foregroundStyle(AppColors.tertiaryText)
    }
    
    // MARK: - Card Styling
    func corporateCardStyle(colorScheme: ColorScheme) -> some View {
        self
            .padding(DesignTokens.spacing.md)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md))
            .dynamicCardShadow(colorScheme: colorScheme)
    }
    
    func elevatedCardStyle(colorScheme: ColorScheme) -> some View {
        self
            .padding(DesignTokens.spacing.lg)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.lg))
            .dynamicElevatedShadow(colorScheme: colorScheme)
    }
    
    // MARK: - Button Styling
    func primaryButtonStyle(colorScheme: ColorScheme, isPressed: Bool = false) -> some View {
        self
            .font(DesignTokens.typography.headline)
            .foregroundStyle(.white)
            .padding(.vertical, DesignTokens.spacing.md)
            .padding(.horizontal, DesignTokens.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md)
                    .fill(
                        LinearGradient(
                            colors: AppColors.gradientRebellion,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .dynamicElevatedShadow(colorScheme: colorScheme)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignTokens.typography.headline)
            .foregroundStyle(AppColors.corporate)
            .padding(.vertical, DesignTokens.spacing.md)
            .padding(.horizontal, DesignTokens.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md)
                    .fill(AppColors.secondaryBackground)
                    .stroke(AppColors.corporate, lineWidth: 1.5)
            )
    }
    
    // MARK: - Section Styling
    func sectionContainerStyle(colorScheme: ColorScheme) -> some View {
        self
            .padding(DesignTokens.spacing.lg)
            .background(AppColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.lg))
            .dynamicCardShadow(colorScheme: colorScheme)
    }
}