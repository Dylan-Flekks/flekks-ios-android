import Foundation
import Supabase

// MARK: - Supabase Configuration
// Add to your project: https://github.com/supabase/supabase-swift
// Swift Package: https://github.com/supabase-community/supabase-swift

enum SupabaseConfig {
    // TODO: Replace with your Supabase project credentials
    static let url = URL(string: "https://gshddhkasfonhqypgewy.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzaGRkaGthc2ZvbmhxeXBnZXd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4MzI3MjAsImV4cCI6MjA4MjQwODcyMH0.2dMXC74G5tx1osppGbviFc8iatpbFLJO9FtC04dbYs8"

    // Storage buckets
    static let videoBucket = "videos"
    static let avatarBucket = "avatars"
    static let thumbnailBucket = "thumbnails"
}

// MARK: - Supabase Client Singleton
@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    let client: SupabaseClient

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )

        // Listen for auth state changes
        Task {
            await setupAuthListener()
        }
    }

    private func setupAuthListener() async {
        for await state in client.auth.authStateChanges {
            await MainActor.run {
                switch state.event {
                case .signedIn:
                    self.isAuthenticated = true
                    Task { await self.fetchCurrentUser() }
                case .signedOut:
                    self.isAuthenticated = false
                    self.currentUser = nil
                default:
                    break
                }
            }
        }
    }

    private func fetchCurrentUser() async {
        guard let authUser = client.auth.currentUser else { return }

        do {
            let user: User = try await client.database
                .from("users")
                .select()
                .eq("id", value: authUser.id.uuidString)
                .single()
                .execute()
                .value

            await MainActor.run {
                self.currentUser = user
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
}

// MARK: - Database Types (matching Supabase schema)
struct DBUser: Codable {
    let id: UUID
    var email: String
    var name: String
    var avatarUrl: String?
    var streakCount: Int
    var totalSessions: Int
    var totalMinutes: Int
    var currentTeamId: UUID?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case avatarUrl = "avatar_url"
        case streakCount = "streak_count"
        case totalSessions = "total_sessions"
        case totalMinutes = "total_minutes"
        case currentTeamId = "current_team_id"
        case createdAt = "created_at"
    }
}

struct DBCoach: Codable {
    let id: UUID
    var userId: UUID
    var name: String
    var credential: String
    var bio: String
    var avatarUrl: String?
    var heroImageUrl: String?
    var accentColor: String
    var isVerified: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name, credential, bio
        case avatarUrl = "avatar_url"
        case heroImageUrl = "hero_image_url"
        case accentColor = "accent_color"
        case isVerified = "is_verified"
        case createdAt = "created_at"
    }
}

struct DBTeam: Codable {
    let id: UUID
    var coachId: UUID
    var name: String
    var description: String
    var focus: String
    var heroGradient: String
    var memberCount: Int
    var isActive: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case coachId = "coach_id"
        case name, description, focus
        case heroGradient = "hero_gradient"
        case memberCount = "member_count"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct DBProgram: Codable {
    let id: UUID
    var teamId: UUID
    var name: String
    var description: String
    var weekCount: Int
    var isActive: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case name, description
        case weekCount = "week_count"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct DBSession: Codable {
    let id: UUID
    var programId: UUID
    var weekNumber: Int
    var dayNumber: Int
    var title: String
    var description: String
    var focusArea: String
    var durationMinutes: Int
    var videoUrl: String?
    var thumbnailUrl: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case programId = "program_id"
        case weekNumber = "week_number"
        case dayNumber = "day_number"
        case title, description
        case focusArea = "focus_area"
        case durationMinutes = "duration_minutes"
        case videoUrl = "video_url"
        case thumbnailUrl = "thumbnail_url"
        case createdAt = "created_at"
    }
}

struct DBChatMessage: Codable {
    let id: UUID
    var teamId: UUID
    var userId: UUID
    var content: String
    var createdAt: Date

    // Joined data
    var user: DBUser?

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case userId = "user_id"
        case content
        case createdAt = "created_at"
        case user
    }
}

struct DBUserProgress: Codable {
    let id: UUID
    var userId: UUID
    var sessionId: UUID
    var completedAt: Date
    var durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case sessionId = "session_id"
        case completedAt = "completed_at"
        case durationSeconds = "duration_seconds"
    }
}
