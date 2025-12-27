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

    // Accent (Teal/Mint) - Extended palette
    static let accent = Color(hex: "00d4aa")
    static let accentSecondary = Color(hex: "00b894")
    static let accentLight = Color(hex: "00f5c4")
    static let accentDark = Color(hex: "009d7e")
    static let accentGlow = Color(hex: "00d4aa").opacity(0.15)
    static let accentGlowStrong = Color(hex: "00d4aa").opacity(0.25)
    static let accentGlowIntense = Color(hex: "00d4aa").opacity(0.4)

    // Teal variations for gradients
    static let tealDeep = Color(hex: "004d40")
    static let tealMid = Color(hex: "00897b")
    static let tealBright = Color(hex: "1de9b6")
    static let tealCyan = Color(hex: "00bcd4")

    // Status colors
    static let flekksOrange = Color(hex: "ff8c42")
    static let flekksRed = Color(hex: "ff4757")
    static let flekksGreen = Color(hex: "00d4aa")

    // Border
    static let border = Color.white.opacity(0.06)
    static let borderLight = Color.white.opacity(0.1)
    static let borderTeal = Color.accent.opacity(0.3)
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
// Ladder-style: SF Pro Rounded throughout for friendly, approachable feel
struct FLEKKSFonts {
    // MARK: - Heading Font (Bold Rounded - Ladder style)
    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func headingHeavy(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func headingSemibold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    // MARK: - Body Font (Rounded)
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func bodyMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func bodySemibold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func bodyBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    // MARK: - Monospace (for timers, stats)
    static func mono(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    // MARK: - Display sizes (Ladder-style bold headlines)
    static let displayLarge: Font = .system(size: 48, weight: .heavy, design: .rounded)
    static let displayMedium: Font = .system(size: 36, weight: .bold, design: .rounded)
    static let displaySmall: Font = .system(size: 28, weight: .bold, design: .rounded)

    static let titleLarge: Font = .system(size: 24, weight: .bold, design: .rounded)
    static let titleMedium: Font = .system(size: 20, weight: .bold, design: .rounded)
    static let titleSmall: Font = .system(size: 16, weight: .semibold, design: .rounded)

    static let labelLarge: Font = .system(size: 14, weight: .semibold, design: .rounded)
    static let labelMedium: Font = .system(size: 12, weight: .semibold, design: .rounded)
    static let labelSmall: Font = .system(size: 10, weight: .bold, design: .rounded)

    static let caption: Font = .system(size: 11, weight: .medium, design: .rounded)
}

// MARK: - Text Style Modifiers
extension View {
    func headingStyle(_ size: CGFloat = 28) -> some View {
        self.font(FLEKKSFonts.heading(size))
            .foregroundColor(.textPrimary)
    }

    func bodyStyle(_ size: CGFloat = 15) -> some View {
        self.font(FLEKKSFonts.body(size))
            .foregroundColor(.textSecondary)
    }

    func labelStyle() -> some View {
        self.font(FLEKKSFonts.labelSmall)
            .foregroundColor(.accent)
            .tracking(1.5)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    var useGradient: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FLEKKSFonts.bodySemibold(15))
            .foregroundColor(isDisabled ? .textMuted : .bgPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isDisabled {
                        Color.bgElevated
                    } else if useGradient {
                        FLEKKSGradients.buttonGradient
                    } else {
                        Color.accent
                    }
                }
            )
            .cornerRadius(14)
            .shadow(color: isDisabled ? .clear : Color.accent.opacity(0.3), radius: 12, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FLEKKSFonts.bodySemibold(15))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.bgElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(FLEKKSGradients.borderGradient, lineWidth: 1)
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

struct TealGlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FLEKKSFonts.bodySemibold(15))
            .foregroundColor(.bgPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Glow layer
                    RoundedRectangle(cornerRadius: 14)
                        .fill(FLEKKSGradients.buttonGradient)
                        .blur(radius: 8)
                        .opacity(0.6)
                        .offset(y: 4)

                    // Main button
                    RoundedRectangle(cornerRadius: 14)
                        .fill(FLEKKSGradients.buttonGradient)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Style Modifier
struct CardStyle: ViewModifier {
    var hasTealBorder: Bool = false

    func body(content: Content) -> some View {
        content
            .background(Color.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        hasTealBorder ? FLEKKSGradients.borderGradient : LinearGradient(colors: [Color.border], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1
                    )
            )
            .cornerRadius(18)
    }
}

struct GlowCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Outer glow
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accent.opacity(0.1))
                        .blur(radius: 20)

                    // Card background
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.bgCard)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(FLEKKSGradients.borderGradient, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(tealBorder: Bool = false) -> some View {
        modifier(CardStyle(hasTealBorder: tealBorder))
    }

    func glowCardStyle() -> some View {
        modifier(GlowCardStyle())
    }
}

// MARK: - Gradients (Enhanced Teal themed)
struct FLEKKSGradients {

    // MARK: - Radial Glow Gradients
    static let tealGlow = RadialGradient(
        colors: [Color.accent.opacity(0.25), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 200
    )

    static let tealGlowIntense = RadialGradient(
        colors: [Color.accentLight.opacity(0.4), Color.accent.opacity(0.2), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 250
    )

    static let tealGlowSoft = RadialGradient(
        colors: [Color.accent.opacity(0.15), Color.accent.opacity(0.05), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 300
    )

    static let tealSpotlight = RadialGradient(
        colors: [Color.tealBright.opacity(0.3), Color.accent.opacity(0.1), Color.clear],
        center: .top,
        startRadius: 0,
        endRadius: 400
    )

    // MARK: - Hero Section Gradients
    static let heroGreen = LinearGradient(
        colors: [Color(hex: "0d2818"), Color(hex: "061210"), Color.bgPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroTeal = LinearGradient(
        colors: [Color.tealDeep.opacity(0.8), Color(hex: "0a1a18"), Color.bgPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroTealVibrant = LinearGradient(
        colors: [Color.tealMid.opacity(0.4), Color.tealDeep.opacity(0.6), Color.bgPrimary],
        startPoint: .top,
        endPoint: .bottom
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

    // MARK: - Button & Accent Gradients
    static let buttonGradient = LinearGradient(
        colors: [Color.accentLight, Color.accent, Color.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [Color.accent, Color.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradientVibrant = LinearGradient(
        colors: [Color.tealBright, Color.accent, Color.tealMid],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Background Gradients
    static let tealFade = LinearGradient(
        colors: [Color.accent.opacity(0.3), Color.accent.opacity(0.05), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )

    static let tealFadeIntense = LinearGradient(
        colors: [Color.accent.opacity(0.5), Color.accent.opacity(0.2), Color.accent.opacity(0.05), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )

    static let tealOverlay = LinearGradient(
        colors: [Color.accent.opacity(0.1), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tealSheen = LinearGradient(
        colors: [Color.clear, Color.accent.opacity(0.1), Color.clear],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let darkTealGradient = LinearGradient(
        colors: [Color.tealDeep, Color.bgPrimary],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Avatar & Icon Gradients
    static let avatarGradient = LinearGradient(
        colors: [Color.tealBright, Color.accent, Color.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let iconGradient = LinearGradient(
        colors: [Color.accentLight, Color.accent],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Border Gradients
    static let borderGradient = LinearGradient(
        colors: [Color.accent.opacity(0.4), Color.accent.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let borderGradientSubtle = LinearGradient(
        colors: [Color.accent.opacity(0.2), Color.accent.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glowBorder = LinearGradient(
        colors: [Color.tealBright.opacity(0.5), Color.accent.opacity(0.3), Color.tealDeep.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Card Highlight Gradients
    static let cardHighlight = LinearGradient(
        colors: [Color.accent.opacity(0.3), Color.accent.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardHighlightIntense = LinearGradient(
        colors: [Color.accent.opacity(0.4), Color.accent.opacity(0.2), Color.accent.opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let selectedCardGradient = LinearGradient(
        colors: [Color.accent.opacity(0.2), Color.accent.opacity(0.1), Color.accent.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Progress & Stats Gradients
    static let progressGradient = LinearGradient(
        colors: [Color.tealBright, Color.accent],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let streakGradient = LinearGradient(
        colors: [Color.flekksOrange, Color(hex: "ff6b35")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Mesh-style Multi-color Gradients
    static let tealAurora = LinearGradient(
        colors: [
            Color.tealCyan.opacity(0.3),
            Color.accent.opacity(0.2),
            Color.tealDeep.opacity(0.3),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tealNebula = RadialGradient(
        colors: [
            Color.tealBright.opacity(0.2),
            Color.accent.opacity(0.15),
            Color.tealMid.opacity(0.1),
            Color.clear
        ],
        center: .center,
        startRadius: 50,
        endRadius: 300
    )
}

// MARK: - Animated Glow Modifier
struct GlowEffect: ViewModifier {
    var color: Color = .accent
    var radius: CGFloat = 80
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.7)
                    .blur(radius: radius)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct PulsingGlow: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.accent, lineWidth: 2)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .opacity(isAnimating ? 0 : 0.8)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct TealShimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.accent.opacity(0.2),
                        Color.clear
                    ],
                    startPoint: .init(x: phase - 0.5, y: phase - 0.5),
                    endPoint: .init(x: phase, y: phase)
                )
                .blendMode(.overlay)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func glowEffect(color: Color = .accent, radius: CGFloat = 80) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }

    func pulsingGlow() -> some View {
        modifier(PulsingGlow())
    }

    func tealShimmer() -> some View {
        modifier(TealShimmer())
    }
}

// MARK: - Gradient Text
struct GradientText: View {
    let text: String
    let font: Font
    let gradient: LinearGradient

    init(_ text: String, font: Font = FLEKKSFonts.heading(28), gradient: LinearGradient = FLEKKSGradients.accentGradient) {
        self.text = text
        self.font = font
        self.gradient = gradient
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(gradient)
    }
}
