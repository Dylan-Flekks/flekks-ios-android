import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .quiz:
                QuizView()
            case .teamSelection:
                TeamSelectionView()
            case .main:
                TabBarView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
