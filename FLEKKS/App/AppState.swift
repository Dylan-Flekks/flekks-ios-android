import SwiftUI

// MARK: - App Screens
enum AppScreen: Equatable {
    case splash
    case onboarding
    case quiz
    case teamSelection
    case coachProfile(UUID)  // Coach splash page
    case auth                // Login/Signup
    case main
}

// MARK: - Tab Bar
enum Tab {
    case home
    case program
    case team
    case progress
    case profile
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    // MARK: - Navigation State
    @Published var currentScreen: AppScreen = .splash
    @Published var selectedTab: Tab = .home
    @Published var navigationPath: [AppScreen] = []

    // MARK: - Auth State
    @Published var isLoggedIn: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var currentUser: User?

    // MARK: - Team State
    @Published var selectedTeam: Team?
    @Published var currentStreak: Int = 0

    // MARK: - Quiz State
    @Published var quizAnswers: [String: String] = [:]
    @Published var currentQuizStep: Int = 0

    // MARK: - Session State
    @Published var currentSession: Session?
    @Published var isPlayingSession: Bool = false

    // MARK: - Services
    private let authService = AuthService.shared
    private let supabase = SupabaseService.shared

    // MARK: - Init
    init() {
        Task {
            await checkAuthState()
        }
    }

    // MARK: - Auth Actions
    func checkAuthState() async {
        isCheckingAuth = true
        let hasSession = await authService.checkSession()

        await MainActor.run {
            self.isLoggedIn = hasSession
            self.isCheckingAuth = false

            if hasSession {
                // User is logged in, check if they have a team
                if self.selectedTeam != nil {
                    self.currentScreen = .main
                } else {
                    self.currentScreen = .teamSelection
                }
            } else {
                self.currentScreen = .splash
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await authService.signIn(email: email, password: password)
        await MainActor.run {
            self.isLoggedIn = true
            self.currentScreen = self.selectedTeam != nil ? .main : .teamSelection
        }
    }

    func signUp(email: String, password: String, name: String) async throws {
        try await authService.signUp(email: email, password: password, name: name)
        await MainActor.run {
            self.isLoggedIn = true
            self.currentScreen = .quiz // New users go through quiz
        }
    }

    func signOut() async {
        try? await authService.signOut()
        await MainActor.run {
            self.isLoggedIn = false
            self.currentUser = nil
            self.selectedTeam = nil
            self.quizAnswers = [:]
            self.currentQuizStep = 0
            self.currentScreen = .splash
        }
    }

    // MARK: - Onboarding Actions
    func completeOnboarding() {
        if isLoggedIn {
            currentScreen = .quiz
        } else {
            currentScreen = .auth
        }
    }

    func completeQuiz() {
        currentScreen = .teamSelection
    }

    func selectTeam(_ team: Team) {
        selectedTeam = team
        currentScreen = .main
    }

    func viewCoachProfile(_ coachId: UUID) {
        currentScreen = .coachProfile(coachId)
    }

    // MARK: - Navigation Actions
    func navigateToTab(_ tab: Tab) {
        selectedTab = tab
    }

    func startSession(_ session: Session) {
        currentSession = session
        isPlayingSession = true
    }

    func endSession() {
        isPlayingSession = false
        currentSession = nil
    }

    // MARK: - Progress Actions
    func incrementStreak() {
        currentStreak += 1
    }

    func recordSessionComplete(session: Session, duration: Int) {
        // Update local state
        incrementStreak()

        // Update via service (fire and forget)
        Task {
            // This would call ProgressService to record completion
        }
    }

    // MARK: - Legacy logout (for compatibility)
    func logout() {
        Task {
            await signOut()
        }
    }
}

// MARK: - App State Extensions for Convenience
extension AppState {
    var isOnboarding: Bool {
        switch currentScreen {
        case .splash, .onboarding, .quiz, .teamSelection, .auth:
            return true
        default:
            return false
        }
    }

    var showTabBar: Bool {
        currentScreen == .main && !isPlayingSession
    }

    var userName: String {
        currentUser?.name ?? "User"
    }

    var userInitials: String {
        guard let name = currentUser?.name else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
