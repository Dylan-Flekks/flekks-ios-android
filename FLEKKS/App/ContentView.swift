import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Main content based on current screen
            Group {
                switch appState.currentScreen {
                case .splash:
                    SplashView()

                case .onboarding:
                    OnboardingView()

                case .auth:
                    AuthView()

                case .quiz:
                    QuizView()

                case .teamSelection:
                    TeamSelectionView()

                case .coachProfile(let coachId):
                    CoachSplashView(coachId: coachId)

                case .main:
                    TabBarView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)

            // Session player overlay
            if appState.isPlayingSession, let session = appState.currentSession {
                SessionPlayerView(session: session)
                    .transition(.move(edge: .bottom))
                    .zIndex(100)
            }

            // Loading overlay during auth check
            if appState.isCheckingAuth {
                ZStack {
                    Color.bgPrimary.ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("FLĒKKS")
                            .font(FLEKKSFonts.headingHeavy(42))
                            .foregroundStyle(FLEKKSGradients.accentGradientVibrant)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
