import SwiftUI
import RevenueCat

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

    // MARK: - Subscription State
    @Published var isSubscribed: Bool = false
    @Published var showPaywall: Bool = false
    @Published var showCustomerCenter: Bool = false

    // MARK: - Team State
    @Published var selectedTeam: Team?
    @Published var currentStreak: Int = 0

    // MARK: - Quiz State
    @Published var quizAnswers: [String: String] = [:]
    @Published var currentQuizStep: Int = 0

    // MARK: - Session State
    @Published var currentSession: Session?
    @Published var isPlayingSession: Bool = false
    @Published var showSessionDetail: Bool = false
    @Published var selectedSessionForDetail: Session?

    // MARK: - Session Actions State
    @Published var savedSessions: Set<UUID> = []
    @Published var scheduledSessions: [UUID: Date] = [:]  // sessionId -> scheduledDate
    @Published var downloadedSessions: Set<UUID> = []

    // MARK: - Celebration State
    @Published var showCelebration: Bool = false
    @Published var completedSessionForCelebration: Session?

    // MARK: - Services
    private let authService = AuthService.shared
    private let supabase = SupabaseService.shared
    private let revenueCat = RevenueCatService.shared

    // MARK: - Init
    init() {
        loadPersistedSessionActions()
        setupSubscriptionObserver()
        Task {
            await checkAuthState()
        }
    }

    // MARK: - Subscription Observer
    private func setupSubscriptionObserver() {
        // Observe RevenueCat subscription changes
        Task {
            for await _ in revenueCat.$subscriptionStatus.values {
                await MainActor.run {
                    self.isSubscribed = self.revenueCat.isSubscribed
                }
            }
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

        // Trigger celebration
        completedSessionForCelebration = session
        showCelebration = true

        // Update via service (fire and forget)
        Task {
            // This would call ProgressService to record completion
        }
    }

    func dismissCelebration() {
        showCelebration = false
        completedSessionForCelebration = nil
    }

    // MARK: - Session Detail Actions
    func viewSessionDetail(_ session: Session) {
        selectedSessionForDetail = session
        showSessionDetail = true
    }

    func dismissSessionDetail() {
        showSessionDetail = false
        selectedSessionForDetail = nil
    }

    // MARK: - Save Session Actions
    func toggleSaveSession(_ sessionId: UUID) {
        if savedSessions.contains(sessionId) {
            savedSessions.remove(sessionId)
        } else {
            savedSessions.insert(sessionId)
        }
        // Persist to UserDefaults or Supabase
        persistSessionActions()
    }

    func isSaved(_ sessionId: UUID) -> Bool {
        savedSessions.contains(sessionId)
    }

    // MARK: - Schedule Session Actions
    func scheduleSession(_ sessionId: UUID, for date: Date) {
        scheduledSessions[sessionId] = date
        persistSessionActions()
    }

    func unscheduleSession(_ sessionId: UUID) {
        scheduledSessions.removeValue(forKey: sessionId)
        persistSessionActions()
    }

    func getScheduledDate(_ sessionId: UUID) -> Date? {
        scheduledSessions[sessionId]
    }

    func getUpcomingScheduledSessions() -> [(UUID, Date)] {
        let now = Date()
        return scheduledSessions
            .filter { $0.value > now }
            .sorted { $0.value < $1.value }
    }

    // MARK: - Download Session Actions
    func addDownloadedSession(_ sessionId: UUID) {
        downloadedSessions.insert(sessionId)
        persistSessionActions()
    }

    func removeDownloadedSession(_ sessionId: UUID) {
        downloadedSessions.remove(sessionId)
        persistSessionActions()
    }

    func isDownloaded(_ sessionId: UUID) -> Bool {
        downloadedSessions.contains(sessionId)
    }

    // MARK: - Persistence
    private func persistSessionActions() {
        // Save to UserDefaults for now (could be Supabase in production)
        if let savedData = try? JSONEncoder().encode(Array(savedSessions)) {
            UserDefaults.standard.set(savedData, forKey: "savedSessions")
        }
        if let scheduledData = try? JSONEncoder().encode(scheduledSessions) {
            UserDefaults.standard.set(scheduledData, forKey: "scheduledSessions")
        }
        if let downloadedData = try? JSONEncoder().encode(Array(downloadedSessions)) {
            UserDefaults.standard.set(downloadedData, forKey: "downloadedSessions")
        }
    }

    private func loadPersistedSessionActions() {
        if let savedData = UserDefaults.standard.data(forKey: "savedSessions"),
           let saved = try? JSONDecoder().decode([UUID].self, from: savedData) {
            savedSessions = Set(saved)
        }
        if let scheduledData = UserDefaults.standard.data(forKey: "scheduledSessions"),
           let scheduled = try? JSONDecoder().decode([UUID: Date].self, from: scheduledData) {
            scheduledSessions = scheduled
        }
        if let downloadedData = UserDefaults.standard.data(forKey: "downloadedSessions"),
           let downloaded = try? JSONDecoder().decode([UUID].self, from: downloadedData) {
            downloadedSessions = Set(downloaded)
        }
    }

    // MARK: - Subscription Actions
    func checkSubscriptionStatus() async {
        await revenueCat.refreshCustomerInfo()
        isSubscribed = revenueCat.isSubscribed
    }

    func hasProAccess() -> Bool {
        return revenueCat.hasProEntitlement
    }

    func presentPaywall() {
        showPaywall = true
    }

    func dismissPaywall() {
        showPaywall = false
    }

    func presentCustomerCenter() {
        showCustomerCenter = true
    }

    func dismissCustomerCenter() {
        showCustomerCenter = false
    }

    func restorePurchases() async throws {
        _ = try await revenueCat.restorePurchases()
        isSubscribed = revenueCat.isSubscribed
    }

    /// Call this to gate premium features
    func requiresSubscription(for feature: String, action: @escaping () -> Void) {
        if isSubscribed {
            action()
        } else {
            showPaywall = true
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
