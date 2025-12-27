import Foundation

// MARK: - User
struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var avatarUrl: String?
    var joinedDate: Date
    var streakCount: Int
    var totalSessions: Int
    var totalMinutes: Int
    var currentTeamId: UUID?

    var avatarInitials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case avatarUrl = "avatar_url"
        case joinedDate = "created_at"
        case streakCount = "streak_count"
        case totalSessions = "total_sessions"
        case totalMinutes = "total_minutes"
        case currentTeamId = "current_team_id"
    }

    static let preview = User(
        id: UUID(),
        name: "Alex",
        email: "alex@example.com",
        avatarUrl: nil,
        joinedDate: Date(),
        streakCount: 12,
        totalSessions: 47,
        totalMinutes: 892,
        currentTeamId: nil
    )
}

// MARK: - Coach
struct Coach: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: UUID?
    var name: String
    var credential: String
    var bio: String
    var avatarUrl: String?
    var heroImageUrl: String?
    var accentColor: String

    var avatarInitials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    enum CodingKeys: String, CodingKey {
        case id, name, credential, bio
        case userId = "user_id"
        case avatarUrl = "avatar_url"
        case heroImageUrl = "hero_image_url"
        case accentColor = "accent_color"
    }

    // Dr. Dylan Peters
    static let dylanPeters = Coach(
        id: UUID(uuidString: "c1111111-1111-4444-aaaa-111111111111")!,
        userId: nil,
        name: "Dr. Dylan Peters",
        credential: "DPT, CSCS",
        bio: "Doctor of Physical Therapy specializing in spinal health, injury prevention, and movement optimization. 10+ years helping desk workers and athletes move pain-free.",
        avatarUrl: nil,
        heroImageUrl: nil,
        accentColor: "#00d4aa"
    )

    // Tina
    static let tina = Coach(
        id: UUID(uuidString: "c2222222-2222-4444-bbbb-222222222222")!,
        userId: nil,
        name: "Tina",
        credential: "Certified Stretch Therapist",
        bio: "Former professional dancer turned flexibility specialist. I help people unlock their body's full range of motion through targeted stretching protocols. Your pike and pancake goals are my specialty!",
        avatarUrl: nil,
        heroImageUrl: nil,
        accentColor: "#9b59b6"
    )

    static let allCoaches: [Coach] = [.dylanPeters, .tina]
}

// MARK: - Team (Team = Program in simplified model)
struct Team: Identifiable, Codable, Equatable {
    let id: UUID
    var coachId: UUID
    var name: String
    var tagline: String?
    var description: String
    var focus: String
    var heroGradient: GradientStyle
    var thumbnailUrl: String?
    var weekCount: Int
    var sessionsPerWeek: Int
    var memberCount: Int
    var isActive: Bool
    var isFeatured: Bool

    // Joined data
    var coach: Coach?

    // Local state for user progress
    var currentWeek: Int = 1
    var completedSessions: Int = 0

    var totalSessions: Int {
        weekCount * sessionsPerWeek
    }

    var progressPercentage: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }

    // Match percentage based on quiz (computed in real app)
    var matchPercentage: Int {
        switch name {
        case "Low Back Liberation": return 94
        case "Pike Perfection": return 86
        case "Pancake Protocol": return 82
        default: return 80
        }
    }

    enum GradientStyle: String, Codable {
        case green, purple, blue, teal
    }

    enum CodingKeys: String, CodingKey {
        case id, name, tagline, description, focus
        case coachId = "coach_id"
        case heroGradient = "hero_gradient"
        case thumbnailUrl = "thumbnail_url"
        case weekCount = "week_count"
        case sessionsPerWeek = "sessions_per_week"
        case memberCount = "member_count"
        case isActive = "is_active"
        case isFeatured = "is_featured"
        case coach
    }

    // Dr. Dylan's Team
    static let lowBackLiberation = Team(
        id: UUID(uuidString: "t1111111-1111-4444-aaaa-111111111111")!,
        coachId: Coach.dylanPeters.id,
        name: "Low Back Liberation",
        tagline: "Fix your low back for good",
        description: "Science-backed protocols for desk workers, lifters, and anyone tired of living with back pain. No fluff, just results.",
        focus: "Low Back Pain Relief",
        heroGradient: .green,
        thumbnailUrl: nil,
        weekCount: 6,
        sessionsPerWeek: 5,
        memberCount: 847,
        isActive: true,
        isFeatured: true,
        coach: .dylanPeters,
        currentWeek: 2,
        completedSessions: 7
    )

    // Tina's Teams
    static let pikePerfection = Team(
        id: UUID(uuidString: "t2222222-2222-4444-bbbb-111111111111")!,
        coachId: Coach.tina.id,
        name: "Pike Perfection",
        tagline: "Touch your toes and beyond",
        description: "Master the pike stretch with progressive overload and targeted techniques. Go from barely touching your toes to chest-to-knees flexibility.",
        focus: "Pike Flexibility",
        heroGradient: .purple,
        thumbnailUrl: nil,
        weekCount: 8,
        sessionsPerWeek: 5,
        memberCount: 523,
        isActive: true,
        isFeatured: true,
        coach: .tina
    )

    static let pancakeProtocol = Team(
        id: UUID(uuidString: "t2222222-2222-4444-bbbb-222222222222")!,
        coachId: Coach.tina.id,
        name: "Pancake Protocol",
        tagline: "Flat pancake or bust",
        description: "The ultimate middle splits and pancake progression. Unlock your hips and achieve that flat pancake position.",
        focus: "Pancake & Middle Splits",
        heroGradient: .blue,
        thumbnailUrl: nil,
        weekCount: 8,
        sessionsPerWeek: 5,
        memberCount: 312,
        isActive: true,
        isFeatured: false,
        coach: .tina
    )

    static let allTeams: [Team] = [.lowBackLiberation, .pikePerfection, .pancakeProtocol]
}

// MARK: - Session
struct Session: Identifiable, Codable, Equatable {
    let id: UUID
    var teamId: UUID
    var weekNumber: Int
    var dayNumber: Int
    var title: String
    var description: String
    var focusArea: String
    var durationMinutes: Int

    // Mux video
    var muxPlaybackId: String?
    var muxAssetId: String?
    var thumbnailUrl: String?

    // Metadata
    var equipment: [String]
    var difficulty: Difficulty

    // Local state
    var isCompleted: Bool = false

    var duration: Int { durationMinutes }

    var hasMuxVideo: Bool { muxPlaybackId != nil }

    var muxStreamUrl: String? {
        guard let playbackId = muxPlaybackId else { return nil }
        return "https://stream.mux.com/\(playbackId).m3u8"
    }

    var muxThumbnailUrl: String? {
        guard let playbackId = muxPlaybackId else { return nil }
        return "https://image.mux.com/\(playbackId)/thumbnail.jpg"
    }

    enum Difficulty: String, Codable {
        case easy, moderate, challenging
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, equipment, difficulty
        case teamId = "team_id"
        case weekNumber = "week_number"
        case dayNumber = "day_number"
        case focusArea = "focus_area"
        case durationMinutes = "duration_minutes"
        case muxPlaybackId = "mux_playback_id"
        case muxAssetId = "mux_asset_id"
        case thumbnailUrl = "thumbnail_url"
    }

    // Low Back Liberation - Week 1 Sessions
    static let lowBackSessions: [Session] = [
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000001")!,
            teamId: Team.lowBackLiberation.id,
            weekNumber: 1, dayNumber: 1,
            title: "Assessment & Foundation",
            description: "Identify your movement patterns and establish your baseline.",
            focusArea: "Assessment",
            durationMinutes: 15,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat"],
            difficulty: .easy,
            isCompleted: true
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000002")!,
            teamId: Team.lowBackLiberation.id,
            weekNumber: 1, dayNumber: 2,
            title: "Hip Hinge Mastery",
            description: "The hip hinge is the #1 skill for protecting your low back.",
            focusArea: "Hips & Glutes",
            durationMinutes: 18,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat"],
            difficulty: .moderate,
            isCompleted: true
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000003")!,
            teamId: Team.lowBackLiberation.id,
            weekNumber: 1, dayNumber: 3,
            title: "Spine Decompression",
            description: "Gentle traction and decompression techniques.",
            focusArea: "Spine",
            durationMinutes: 12,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat", "foam roller"],
            difficulty: .easy,
            isCompleted: true
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000004")!,
            teamId: Team.lowBackLiberation.id,
            weekNumber: 1, dayNumber: 4,
            title: "Core Activation",
            description: "Learn to properly brace and stabilize your core.",
            focusArea: "Core",
            durationMinutes: 20,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat"],
            difficulty: .moderate,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000005")!,
            teamId: Team.lowBackLiberation.id,
            weekNumber: 1, dayNumber: 5,
            title: "Hip Flexor Release",
            description: "Release tight hip flexors that contribute to low back pain.",
            focusArea: "Hip Flexors",
            durationMinutes: 15,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat"],
            difficulty: .easy,
            isCompleted: false
        )
    ]

    // Pike Perfection - Week 1 Sessions
    static let pikeSessions: [Session] = [
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000001")!,
            teamId: Team.pikePerfection.id,
            weekNumber: 1, dayNumber: 1,
            title: "Pike Assessment",
            description: "Test your current pike and identify limiting factors.",
            focusArea: "Assessment",
            durationMinutes: 12,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat"],
            difficulty: .easy,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000002")!,
            teamId: Team.pikePerfection.id,
            weekNumber: 1, dayNumber: 2,
            title: "Hamstring Prep",
            description: "Prepare your hamstrings for deep stretching.",
            focusArea: "Hamstrings",
            durationMinutes: 20,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat", "strap"],
            difficulty: .moderate,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000003")!,
            teamId: Team.pikePerfection.id,
            weekNumber: 1, dayNumber: 3,
            title: "Hip Flexor Strength",
            description: "Strong hip flexors pull you deeper into your pike.",
            focusArea: "Hip Flexors",
            durationMinutes: 18,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat"],
            difficulty: .moderate,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000004")!,
            teamId: Team.pikePerfection.id,
            weekNumber: 1, dayNumber: 4,
            title: "Standing Pike Flow",
            description: "Progressive standing pike work with holds and pulses.",
            focusArea: "Full Pike",
            durationMinutes: 22,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat", "block"],
            difficulty: .moderate,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000005")!,
            teamId: Team.pikePerfection.id,
            weekNumber: 1, dayNumber: 5,
            title: "Seated Pike Deep Work",
            description: "Seated pike variations with weighted stretches.",
            focusArea: "Full Pike",
            durationMinutes: 25,
            muxPlaybackId: nil,
            muxAssetId: nil,
            thumbnailUrl: nil,
            equipment: ["mat", "weight"],
            difficulty: .challenging,
            isCompleted: false
        )
    ]

    static let previewSessions: [Session] = lowBackSessions
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var teamId: UUID
    var userId: UUID
    var content: String
    var createdAt: Date

    // Joined data
    var senderName: String = ""
    var senderInitials: String = ""
    var isCoach: Bool = false

    var text: String { content }
    var timestamp: Date { createdAt }

    enum CodingKeys: String, CodingKey {
        case id, content
        case teamId = "team_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }

    static let previewMessages: [ChatMessage] = [
        ChatMessage(
            id: UUID(),
            teamId: Team.lowBackLiberation.id,
            userId: UUID(),
            content: "Great work this week everyone! Remember: consistency beats intensity.",
            createdAt: Date().addingTimeInterval(-3600),
            senderName: "Dr. Dylan Peters",
            senderInitials: "DP",
            isCoach: true
        ),
        ChatMessage(
            id: UUID(),
            teamId: Team.lowBackLiberation.id,
            userId: UUID(),
            content: "Just finished Day 5! My back has never felt this good.",
            createdAt: Date().addingTimeInterval(-1800),
            senderName: "Sarah M.",
            senderInitials: "SM",
            isCoach: false
        ),
    ]
}

// MARK: - Badge
struct Badge: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var icon: String
    var requirementType: String?
    var requirementValue: Int?
    var isUnlocked: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, name, description, icon
        case requirementType = "requirement_type"
        case requirementValue = "requirement_value"
    }

    static let previewBadges: [Badge] = [
        Badge(id: UUID(), name: "First Session", description: "Complete your first session", icon: "target", isUnlocked: true),
        Badge(id: UUID(), name: "Week Warrior", description: "Complete 7 sessions", icon: "flame.fill", isUnlocked: true),
        Badge(id: UUID(), name: "Early Bird", description: "Complete a session before 7am", icon: "sunrise.fill", isUnlocked: true),
        Badge(id: UUID(), name: "Consistent", description: "Maintain a 14-day streak", icon: "bolt.fill", isUnlocked: false),
        Badge(id: UUID(), name: "Dedicated", description: "Complete 30 sessions", icon: "star.fill", isUnlocked: false),
    ]
}

// MARK: - Quiz
struct QuizQuestion {
    let id: Int
    let question: String
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

extension QuizQuestion {
    static let questions: [QuizQuestion] = [
        QuizQuestion(
            id: 0,
            question: "What's your main goal?",
            options: [
                QuizOption(id: "pain", title: "Reduce Pain", description: "Back, neck, or joint discomfort", icon: "cross.case.fill"),
                QuizOption(id: "flexibility", title: "Get Flexible", description: "Touch toes, splits, backbends", icon: "figure.flexibility"),
                QuizOption(id: "performance", title: "Perform Better", description: "Sports, lifting, activities", icon: "bolt.fill"),
                QuizOption(id: "general", title: "Feel Better", description: "Overall movement & wellness", icon: "sparkles"),
            ]
        ),
        QuizQuestion(
            id: 1,
            question: "How would you describe your flexibility?",
            options: [
                QuizOption(id: "stiff", title: "Very Stiff", description: "Can barely touch my knees", icon: "figure.stand"),
                QuizOption(id: "average", title: "Average", description: "Somewhat flexible", icon: "figure.walk"),
                QuizOption(id: "good", title: "Pretty Good", description: "Above average mobility", icon: "figure.run"),
                QuizOption(id: "advanced", title: "Very Flexible", description: "Looking to push further", icon: "figure.gymnastics"),
            ]
        ),
        QuizQuestion(
            id: 2,
            question: "Where do you feel the most tension?",
            options: [
                QuizOption(id: "lowback", title: "Low Back", description: "Pain or stiffness in lumbar spine", icon: "figure.american.football"),
                QuizOption(id: "hips", title: "Hips & Hamstrings", description: "Tight from sitting or activity", icon: "chair.fill"),
                QuizOption(id: "shoulders", title: "Shoulders & Neck", description: "Stress and posture", icon: "laptopcomputer"),
                QuizOption(id: "everywhere", title: "Everywhere", description: "Full body stiffness", icon: "figure.mixed.cardio"),
            ]
        ),
        QuizQuestion(
            id: 3,
            question: "How much time can you commit daily?",
            options: [
                QuizOption(id: "10min", title: "10-15 minutes", description: "Quick and focused", icon: "bolt.fill"),
                QuizOption(id: "20min", title: "15-25 minutes", description: "Solid session", icon: "target"),
                QuizOption(id: "30min", title: "25-40 minutes", description: "Deep work", icon: "flame.fill"),
                QuizOption(id: "flexible", title: "Varies", description: "Depends on the day", icon: "arrow.triangle.2.circlepath"),
            ]
        ),
    ]
}

// MARK: - User Progress
struct UserProgress: Identifiable, Codable {
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

// MARK: - Team Member
struct TeamMember: Identifiable, Codable {
    let id: UUID
    var teamId: UUID
    var userId: UUID
    var currentWeek: Int
    var joinedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case userId = "user_id"
        case currentWeek = "current_week"
        case joinedAt = "joined_at"
    }
}
