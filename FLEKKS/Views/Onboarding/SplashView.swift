import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color.bgPrimary
                .ignoresSafeArea()

            // Animated teal glow effect (multiple layers for depth)
            ZStack {
                // Outer glow
                Circle()
                    .fill(FLEKKSGradients.tealGlowSoft)
                    .frame(width: 500, height: 500)
                    .blur(radius: 100)
                    .offset(y: -50)
                    .scaleEffect(isAnimating ? 1.2 : 0.9)
                    .opacity(isAnimating ? 0.8 : 0.4)

                // Inner bright glow
                Circle()
                    .fill(FLEKKSGradients.tealGlowIntense)
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(y: -80)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.6)
            }

            VStack(spacing: 12) {
                Spacer()

                // Logo with gradient (Ladder-style bold)
                Text("FLĒKKS")
                    .font(FLEKKSFonts.headingHeavy(52))
                    .foregroundStyle(FLEKKSGradients.accentGradientVibrant)
                    .tracking(4)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // Tagline
                Text("FLEXIBILITY REDEFINED")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
                    .tracking(4)
                    .opacity(logoOpacity)

                Spacer()

                // CTA Section
                VStack(spacing: 20) {
                    Button(action: {
                        appState.currentScreen = .onboarding
                    }) {
                        Text("Get Started")
                    }
                    .buttonStyle(TealGlowButtonStyle())
                    .frame(maxWidth: 300)

                    Button(action: {
                        appState.currentScreen = .main
                    }) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.textMuted)
                            Text("Log in")
                                .foregroundStyle(FLEKKSGradients.accentGradient)
                                .fontWeight(.bold)
                        }
                        .font(FLEKKSFonts.bodyMedium(14))
                    }
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            // Logo entrance animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Continuous glow animation
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
