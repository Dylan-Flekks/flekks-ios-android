import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background
            Color.bgPrimary
                .ignoresSafeArea()

            // Animated glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.accent.opacity(0.25), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(y: -100)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .opacity(isAnimating ? 1.0 : 0.6)

            VStack(spacing: 8) {
                Spacer()

                // Logo
                Text("FLĒKKS")
                    .font(.custom("Georgia-Italic", size: 64))
                    .foregroundColor(.textPrimary)
                    .tracking(2)

                // Tagline
                Text("FLEXIBILITY REDEFINED")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textMuted)
                    .tracking(4)

                Spacer()

                // CTA Section
                VStack(spacing: 20) {
                    Button(action: {
                        appState.currentScreen = .onboarding
                    }) {
                        Text("Get Started")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 300)

                    Button(action: {
                        // Login action
                        appState.currentScreen = .main
                    }) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.textMuted)
                            Text("Log in")
                                .foregroundColor(.accent)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                    }
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
