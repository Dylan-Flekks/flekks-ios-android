import Foundation
import Supabase

// MARK: - Coach Service
// Handles coach profiles, teams, and content management
@MainActor
class CoachService: ObservableObject {
    static let shared = CoachService()

    private let supabase = SupabaseService.shared

    @Published var coaches: [DBCoach] = []
    @Published var currentCoach: DBCoach?
    @Published var coachTeams: [DBTeam] = []
    @Published var isLoading = false

    // MARK: - Fetch All Coaches
    func fetchAllCoaches() async throws {
        isLoading = true
        defer { isLoading = false }

        coaches = try await supabase.client.database
            .from("coaches")
            .select()
            .eq("is_verified", value: true)
            .order("name")
            .execute()
            .value
    }

    // MARK: - Fetch Coach by ID
    func fetchCoach(id: UUID) async throws -> DBCoach {
        let coach: DBCoach = try await supabase.client.database
            .from("coaches")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        return coach
    }

    // MARK: - Fetch Coach's Teams
    func fetchTeams(forCoach coachId: UUID) async throws -> [DBTeam] {
        let teams: [DBTeam] = try await supabase.client.database
            .from("teams")
            .select()
            .eq("coach_id", value: coachId.uuidString)
            .eq("is_active", value: true)
            .execute()
            .value

        return teams
    }

    // MARK: - Get Coach with Full Profile (for splash page)
    func fetchCoachProfile(id: UUID) async throws -> CoachProfile {
        let coach = try await fetchCoach(id: id)
        let teams = try await fetchTeams(forCoach: id)

        // Fetch stats
        let stats = try await fetchCoachStats(coachId: id)

        return CoachProfile(
            coach: coach,
            teams: teams,
            stats: stats
        )
    }

    // MARK: - Fetch Coach Stats
    private func fetchCoachStats(coachId: UUID) async throws -> CoachStats {
        // Get total members across all teams
        let teams: [DBTeam] = try await supabase.client.database
            .from("teams")
            .select("member_count")
            .eq("coach_id", value: coachId.uuidString)
            .execute()
            .value

        let totalMembers = teams.reduce(0) { $0 + $1.memberCount }

        // Get total sessions
        let programs: [DBProgram] = try await supabase.client.database
            .from("programs")
            .select("id")
            .in("team_id", values: teams.map { $0.id.uuidString })
            .execute()
            .value

        // Count sessions
        // This is simplified - in production you'd use a count query
        let sessionCount = programs.count * 25 // Approximate

        return CoachStats(
            totalMembers: totalMembers,
            totalSessions: sessionCount,
            averageRating: 4.9, // TODO: Implement ratings
            totalReviews: 127 // TODO: Implement reviews
        )
    }

    // MARK: - Join Team
    func joinTeam(teamId: UUID) async throws {
        guard let userId = supabase.currentUser?.id else {
            throw CoachError.notAuthenticated
        }

        // Update user's current team
        try await supabase.client.database
            .from("users")
            .update(["current_team_id": teamId.uuidString])
            .eq("id", value: userId.uuidString)
            .execute()

        // Add to team_members junction table
        try await supabase.client.database
            .from("team_members")
            .insert([
                "team_id": teamId.uuidString,
                "user_id": userId.uuidString,
                "joined_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()

        // Increment member count
        try await supabase.client.rpc(
            "increment_team_members",
            params: ["team_id": teamId.uuidString]
        ).execute()
    }

    // MARK: - Leave Team
    func leaveTeam(teamId: UUID) async throws {
        guard let userId = supabase.currentUser?.id else {
            throw CoachError.notAuthenticated
        }

        // Remove from team_members
        try await supabase.client.database
            .from("team_members")
            .delete()
            .eq("team_id", value: teamId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Clear user's current team
        try await supabase.client.database
            .from("users")
            .update(["current_team_id": NSNull()])
            .eq("id", value: userId.uuidString)
            .execute()

        // Decrement member count
        try await supabase.client.rpc(
            "decrement_team_members",
            params: ["team_id": teamId.uuidString]
        ).execute()
    }
}

// MARK: - Coach Profile (Full data for splash page)
struct CoachProfile {
    let coach: DBCoach
    let teams: [DBTeam]
    let stats: CoachStats

    var primaryTeam: DBTeam? {
        teams.first
    }
}

struct CoachStats {
    let totalMembers: Int
    let totalSessions: Int
    let averageRating: Double
    let totalReviews: Int

    var formattedRating: String {
        String(format: "%.1f", averageRating)
    }
}

// MARK: - Coach Errors
enum CoachError: LocalizedError {
    case notAuthenticated
    case coachNotFound
    case alreadyMember

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to join a team."
        case .coachNotFound:
            return "Coach not found."
        case .alreadyMember:
            return "You're already a member of this team."
        }
    }
}

// MARK: - Coach Content Manager (for coaches to manage their content)
@MainActor
class CoachContentManager: ObservableObject {
    private let supabase = SupabaseService.shared
    private let videoService = VideoService.shared

    @Published var programs: [DBProgram] = []
    @Published var sessions: [DBSession] = []
    @Published var isLoading = false

    // MARK: - Create Program
    func createProgram(teamId: UUID, name: String, description: String, weekCount: Int) async throws -> DBProgram {
        let program = DBProgram(
            id: UUID(),
            teamId: teamId,
            name: name,
            description: description,
            weekCount: weekCount,
            isActive: true,
            createdAt: Date()
        )

        try await supabase.client.database
            .from("programs")
            .insert(program)
            .execute()

        return program
    }

    // MARK: - Create Session with Video
    func createSession(
        programId: UUID,
        weekNumber: Int,
        dayNumber: Int,
        title: String,
        description: String,
        focusArea: String,
        videoFile: URL
    ) async throws -> DBSession {
        let sessionId = UUID()

        // Upload video
        let videoUrl = try await videoService.uploadVideo(fileURL: videoFile, sessionId: sessionId)

        // Generate and upload thumbnail
        var thumbnailUrl: String?
        if let thumbnailData = await videoService.generateThumbnail(from: videoFile) {
            thumbnailUrl = try await videoService.uploadThumbnail(image: thumbnailData, sessionId: sessionId)
        }

        // Get video duration
        let metadata = await videoService.getVideoMetadata(url: videoFile)
        let duration = Int(metadata?.duration ?? 0) / 60

        let session = DBSession(
            id: sessionId,
            programId: programId,
            weekNumber: weekNumber,
            dayNumber: dayNumber,
            title: title,
            description: description,
            focusArea: focusArea,
            durationMinutes: duration,
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            createdAt: Date()
        )

        try await supabase.client.database
            .from("sessions")
            .insert(session)
            .execute()

        return session
    }

    // MARK: - Update Session
    func updateSession(_ session: DBSession) async throws {
        try await supabase.client.database
            .from("sessions")
            .update(session)
            .eq("id", value: session.id.uuidString)
            .execute()
    }

    // MARK: - Delete Session
    func deleteSession(id: UUID) async throws {
        // Delete video files
        try await videoService.deleteVideo(sessionId: id)

        // Delete from database
        try await supabase.client.database
            .from("sessions")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
