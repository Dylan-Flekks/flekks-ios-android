import SwiftUI

// MARK: - Color Theme (matching mockup)
extension Color {
    // Backgrounds
    static let bgPrimary = Color(hex: "0a0a0a")
    static let bgCard = Color(hex: "141414")
    static let bgElevated = Color(hex: "1c1c1c")
    static let bgInput = Color(hex: "242424")

    // Text
    static let textPrimary = Color(hex: "fafafa")
    static let textSecondary = Color(hex: "a1a1a1")
    static let textMuted = Color(hex: "525252")

    // Accent (Teal/Mint)
    static let accent = Color(hex: "00d4aa")
    static let accentSecondary = Color(hex: "00b894")
    static let accentGlow = Color(hex: "00d4aa").opacity(0.15)
    static let accentGlowStrong = Color(hex: "00d4aa").opacity(0.25)

    // Status colors
    static let flekksOrange = Color(hex: "ff8c42")
    static let flekksRed = Color(hex: "ff4757")
    static let flekksGreen = Color(hex: "00d4aa")

    // Border
    static let border = Color.white.opacity(0.06)
    static let borderLight = Color.white.opacity(0.1)
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct FLEKKSFonts {
    // Serif font for headings (Instrument Serif in mockup)
    static func serif(_ size: CGFloat) -> Font {
        .custom("Georgia", size: size) // Fallback to Georgia, can add custom font later
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Georgia-Italic", size: size)
    }

    // Sans font for body (DM Sans in mockup)
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(isDisabled ? .textMuted : .bgPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isDisabled ? Color.bgElevated : Color.accent)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.bgElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.borderLight, lineWidth: 1)
            )
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .accent : .textSecondary)
            .padding(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Style Modifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.border, lineWidth: 1)
            )
            .cornerRadius(18)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Gradients (Teal themed)
struct FLEKKSGradients {
    // Primary teal glow gradient
    static let tealGlow = RadialGradient(
        colors: [Color.accent.opacity(0.25), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 200
    )

    // Hero section gradient (dark with teal hint)
    static let heroGreen = LinearGradient(
        colors: [Color(hex: "0d2818"), Color.bgPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroPurple = LinearGradient(
        colors: [Color(hex: "1a0d2e"), Color.bgPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroBlue = LinearGradient(
        colors: [Color(hex: "0d1a2e"), Color.bgPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Accent button gradient
    static let accentGradient = LinearGradient(
        colors: [Color.accent, Color.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Teal to transparent (for backgrounds)
    static let tealFade = LinearGradient(
        colors: [Color.accent.opacity(0.3), Color.accent.opacity(0.05), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )

    // Subtle teal overlay
    static let tealOverlay = LinearGradient(
        colors: [Color.accent.opacity(0.1), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Avatar gradient
    static let avatarGradient = LinearGradient(
        colors: [Color.accent, Color.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Card highlight gradient (subtle teal border effect)
    static let cardHighlight = LinearGradient(
        colors: [Color.accent.opacity(0.3), Color.accent.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Animated Glow Modifier
struct GlowEffect: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(FLEKKSGradients.tealGlow)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.6)
                    .blur(radius: 80)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func glowEffect() -> some View {
        modifier(GlowEffect())
    }
}
