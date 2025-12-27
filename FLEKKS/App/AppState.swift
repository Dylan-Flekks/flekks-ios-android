import SwiftUI

enum AppScreen {
    case splash
    case onboarding
    case quiz
    case teamSelection
    case main
}

enum Tab {
    case home
    case program
    case team
    case progress
    case profile
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var selectedTab: Tab = .home
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var selectedTeam: Team?
    @Published var currentStreak: Int = 12

    // Quiz state
    @Published var quizAnswers: [String: String] = [:]
    @Published var currentQuizStep: Int = 0

    func completeOnboarding() {
        currentScreen = .quiz
    }

    func completeQuiz() {
        currentScreen = .teamSelection
    }

    func selectTeam(_ team: Team) {
        selectedTeam = team
        currentScreen = .main
    }

    func logout() {
        isLoggedIn = false
        currentUser = nil
        selectedTeam = nil
        currentScreen = .splash
    }
}
