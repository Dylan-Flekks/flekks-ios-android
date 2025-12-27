import Foundation
import Supabase

// MARK: - Data Service
// Handles fetching and caching data from Supabase
@MainActor
class DataService: ObservableObject {
    static let shared = DataService()

    private let supabase = SupabaseService.shared

    // MARK: - Cached Data
    @Published var coaches: [Coach] = Coach.allCoaches
    @Published var teams: [Team] = Team.allTeams
    @Published var programs: [Program] = Program.allPrograms
    @Published var currentProgram: Program?
    @Published var sessions: [Session] = []
    @Published var todaySession: Session?

    @Published var isLoading = false
    @Published var errorMessage: String?

    // Use local preview data (set to false when Supabase is configured)
    private var useLocalData = true

    init() {
        // Check if Supabase is configured
        let urlString = SupabaseConfig.url.absoluteString
        useLocalData = urlString.contains("YOUR_PROJECT_ID")

        if useLocalData {
            loadLocalData()
        }
    }

    // MARK: - Load Local Preview Data
    private func loadLocalData() {
        coaches = Coach.allCoaches
        teams = Team.allTeams
        programs = Program.allPrograms
        sessions = Session.lowBackSessions + Session.pikeSessions
        currentProgram = Program.lowBackReset
        todaySession = Session.lowBackSessions.first(where: { !$0.isCompleted })
    }

    // MARK: - Fetch Coaches
    func fetchCoaches() async {
        guard !useLocalData else { return }

        isLoading = true
        do {
            let result: [Coach] = try await supabase.client.database
                .from("coaches")
                .select()
                .eq("is_verified", value: true)
                .execute()
                .value

            coaches = result
        } catch {
            errorMessage = "Failed to load coaches: \(error.localizedDescription)"
            coaches = Coach.allCoaches // Fallback
        }
        isLoading = false
    }

    // MARK: - Fetch Teams
    func fetchTeams() async {
        guard !useLocalData else { return }

        isLoading = true
        do {
            let result: [Team] = try await supabase.client.database
                .from("teams")
                .select("*, coach:coaches(*)")
                .eq("is_active", value: true)
                .execute()
                .value

            teams = result
        } catch {
            errorMessage = "Failed to load teams: \(error.localizedDescription)"
            teams = Team.allTeams // Fallback
        }
        isLoading = false
    }

    // MARK: - Fetch Programs for Team
    func fetchPrograms(teamId: UUID) async {
        guard !useLocalData else {
            programs = Program.allPrograms.filter { $0.teamId == teamId }
            currentProgram = programs.first
            return
        }

        isLoading = true
        do {
            let result: [Program] = try await supabase.client.database
                .from("programs")
                .select()
                .eq("team_id", value: teamId.uuidString)
                .eq("is_active", value: true)
                .execute()
                .value

            programs = result
            currentProgram = result.first
        } catch {
            errorMessage = "Failed to load programs: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Fetch Sessions for Program
    func fetchSessions(programId: UUID, week: Int? = nil) async {
        guard !useLocalData else {
            if programId == Program.lowBackReset.id {
                sessions = Session.lowBackSessions
            } else if programId == Program.pikePerfection.id {
                sessions = Session.pikeSessions
            }
            todaySession = sessions.first(where: { !$0.isCompleted })
            return
        }

        isLoading = true
        do {
            var query = supabase.client.database
                .from("sessions")
                .select()
                .eq("program_id", value: programId.uuidString)

            if let week = week {
                query = query.eq("week_number", value: week)
            }

            let result: [Session] = try await query
                .order("week_number")
                .order("day_number")
                .execute()
                .value

            sessions = result
            todaySession = result.first(where: { !$0.isCompleted })
        } catch {
            errorMessage = "Failed to load sessions: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Get Coach by ID
    func getCoach(id: UUID) -> Coach? {
        return coaches.first(where: { $0.id == id }) ?? Coach.allCoaches.first(where: { $0.id == id })
    }

    // MARK: - Get Team by ID
    func getTeam(id: UUID) -> Team? {
        return teams.first(where: { $0.id == id }) ?? Team.allTeams.first(where: { $0.id == id })
    }

    // MARK: - Get Programs for Coach
    func getPrograms(coachId: UUID) -> [Program] {
        let coachTeams = teams.filter { $0.coachId == coachId }
        return programs.filter { program in
            coachTeams.contains(where: { $0.id == program.teamId })
        }
    }

    // MARK: - Get Sessions for Current Week
    func getCurrentWeekSessions(programId: UUID, week: Int) -> [Session] {
        return sessions.filter { $0.programId == programId && $0.weekNumber == week }
    }

    // MARK: - Mark Session Complete
    func markSessionComplete(session: Session, durationSeconds: Int) async throws {
        guard let userId = supabase.client.auth.currentUser?.id else {
            // For local testing, just update local state
            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[index].isCompleted = true
            }
            return
        }

        // Record progress in database
        try await supabase.client.database
            .from("user_progress")
            .insert([
                "user_id": userId.uuidString,
                "session_id": session.id.uuidString,
                "duration_seconds": durationSeconds
            ])
            .execute()

        // Update local state
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].isCompleted = true
        }

        // Update today's session
        todaySession = sessions.first(where: { !$0.isCompleted })
    }

    // MARK: - Computed Properties
    var completedSessionsCount: Int {
        sessions.filter { $0.isCompleted }.count
    }

    var totalSessionsCount: Int {
        sessions.count
    }

    var progressPercentage: Double {
        guard totalSessionsCount > 0 else { return 0 }
        return Double(completedSessionsCount) / Double(totalSessionsCount)
    }
}
