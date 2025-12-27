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
    }

    static let preview = User(
        id: UUID(),
        name: "Alex",
        email: "alex@example.com",
        avatarUrl: nil,
        joinedDate: Date(),
        streakCount: 12,
        totalSessions: 47,
        totalMinutes: 892
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

    // Dr. Dylan Peters - Physical Therapist (Low Back specialist)
    static let dylanPeters = Coach(
        id: UUID(uuidString: "c1111111-1111-4444-aaaa-111111111111")!,
        userId: UUID(uuidString: "a1b2c3d4-1111-4444-aaaa-111111111111"),
        name: "Dr. Dylan Peters",
        credential: "DPT, CSCS",
        bio: "Doctor of Physical Therapy specializing in spinal health, injury prevention, and movement optimization. 10+ years helping desk workers and athletes move pain-free.",
        avatarUrl: nil,
        heroImageUrl: nil,
        accentColor: "#00d4aa"
    )

    // Tina - Stretch Therapist (Pike & Pancake specialist)
    static let tina = Coach(
        id: UUID(uuidString: "c2222222-2222-4444-bbbb-222222222222")!,
        userId: UUID(uuidString: "a1b2c3d4-2222-4444-bbbb-222222222222"),
        name: "Tina",
        credential: "Certified Stretch Therapist",
        bio: "Former professional dancer turned flexibility specialist. I help people unlock their body's full range of motion through targeted stretching protocols. Your pike and pancake goals are my specialty!",
        avatarUrl: nil,
        heroImageUrl: nil,
        accentColor: "#9b59b6"
    )

    static let allCoaches: [Coach] = [.dylanPeters, .tina]
}

// MARK: - Team
struct Team: Identifiable, Codable, Equatable {
    let id: UUID
    var coachId: UUID
    var name: String
    var description: String
    var focus: String
    var heroGradient: GradientStyle
    var memberCount: Int
    var isActive: Bool

    // Joined data
    var coach: Coach?

    // Computed match percentage (based on quiz answers in real app)
    var matchPercentage: Int {
        switch name {
        case "Low Back Liberation": return 94
        case "Flexibility Lab": return 86
        default: return 80
        }
    }

    var isLive: Bool {
        name == "Low Back Liberation" // Dylan's team is live
    }

    enum GradientStyle: String, Codable {
        case green
        case purple
        case blue
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, focus
        case coachId = "coach_id"
        case heroGradient = "hero_gradient"
        case memberCount = "member_count"
        case isActive = "is_active"
        case coach
    }

    // Dr. Dylan's Team
    static let lowBackLiberation = Team(
        id: UUID(uuidString: "t1111111-1111-4444-aaaa-111111111111")!,
        coachId: Coach.dylanPeters.id,
        name: "Low Back Liberation",
        description: "Fix your low back for good. Science-backed protocols for desk workers, lifters, and anyone tired of living with back pain. No fluff, just results.",
        focus: "Low Back Pain Relief",
        heroGradient: .green,
        memberCount: 847,
        isActive: true,
        coach: .dylanPeters
    )

    // Tina's Team
    static let flexibilityLab = Team(
        id: UUID(uuidString: "t2222222-2222-4444-bbbb-222222222222")!,
        coachId: Coach.tina.id,
        name: "Flexibility Lab",
        description: "Deep flexibility work for serious progress. Whether you're chasing your pike, pancake, or just want to move better - this is where transformation happens.",
        focus: "Advanced Flexibility",
        heroGradient: .purple,
        memberCount: 523,
        isActive: true,
        coach: .tina
    )

    static let allTeams: [Team] = [.lowBackLiberation, .flexibilityLab]
}

// MARK: - Program
struct Program: Identifiable, Codable, Equatable {
    let id: UUID
    var teamId: UUID
    var name: String
    var description: String
    var weekCount: Int
    var isActive: Bool

    // Joined/computed data
    var coach: Coach?
    var currentWeek: Int = 1
    var completedSessions: Int = 0
    var totalSessions: Int = 0

    var progressPercentage: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case teamId = "team_id"
        case weekCount = "week_count"
        case isActive = "is_active"
    }

    // Dylan's Program
    static let lowBackReset = Program(
        id: UUID(uuidString: "p1111111-1111-4444-aaaa-111111111111")!,
        teamId: Team.lowBackLiberation.id,
        name: "6-Week Low Back Reset",
        description: "A comprehensive program to eliminate low back pain and build lasting resilience. Combines mobility, stability, and strength work.",
        weekCount: 6,
        isActive: true,
        coach: .dylanPeters,
        currentWeek: 2,
        completedSessions: 7,
        totalSessions: 30
    )

    // Tina's Programs
    static let pikePerfection = Program(
        id: UUID(uuidString: "p2222222-2222-4444-bbbb-111111111111")!,
        teamId: Team.flexibilityLab.id,
        name: "Pike Perfection",
        description: "Master the pike stretch with progressive overload and targeted techniques. Go from barely touching your toes to chest-to-knees flexibility.",
        weekCount: 8,
        isActive: true,
        coach: .tina,
        currentWeek: 1,
        completedSessions: 0,
        totalSessions: 40
    )

    static let pancakeProtocol = Program(
        id: UUID(uuidString: "p2222222-2222-4444-bbbb-222222222222")!,
        teamId: Team.flexibilityLab.id,
        name: "Pancake Protocol",
        description: "The ultimate middle splits and pancake progression. Unlock your hips and achieve that flat pancake position.",
        weekCount: 8,
        isActive: true,
        coach: .tina,
        currentWeek: 1,
        completedSessions: 0,
        totalSessions: 40
    )

    static let allPrograms: [Program] = [.lowBackReset, .pikePerfection, .pancakeProtocol]
}

// MARK: - Session
struct Session: Identifiable, Codable, Equatable {
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

    // Local state
    var isCompleted: Bool = false

    var duration: Int { durationMinutes }

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case programId = "program_id"
        case weekNumber = "week_number"
        case dayNumber = "day_number"
        case focusArea = "focus_area"
        case durationMinutes = "duration_minutes"
        case videoUrl = "video_url"
        case thumbnailUrl = "thumbnail_url"
    }

    // Low Back Reset - Week 1 Sessions
    static let lowBackSessions: [Session] = [
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000001")!,
            programId: Program.lowBackReset.id,
            weekNumber: 1,
            dayNumber: 1,
            title: "Assessment & Foundation",
            description: "Identify your movement patterns and establish your baseline.",
            focusArea: "Assessment",
            durationMinutes: 15,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: true
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000002")!,
            programId: Program.lowBackReset.id,
            weekNumber: 1,
            dayNumber: 2,
            title: "Hip Hinge Mastery",
            description: "The hip hinge is the #1 skill for protecting your low back.",
            focusArea: "Hips & Glutes",
            durationMinutes: 18,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: true
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000003")!,
            programId: Program.lowBackReset.id,
            weekNumber: 1,
            dayNumber: 3,
            title: "Spine Decompression",
            description: "Gentle traction and decompression techniques.",
            focusArea: "Spine",
            durationMinutes: 12,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: true
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000004")!,
            programId: Program.lowBackReset.id,
            weekNumber: 1,
            dayNumber: 4,
            title: "Core Activation",
            description: "Learn to properly brace and stabilize your core.",
            focusArea: "Core",
            durationMinutes: 20,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s1111111-1111-4444-aaaa-000000000005")!,
            programId: Program.lowBackReset.id,
            weekNumber: 1,
            dayNumber: 5,
            title: "Hip Flexor Release",
            description: "Tight hip flexors contribute to low back pain. Release them.",
            focusArea: "Hip Flexors",
            durationMinutes: 15,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: false
        )
    ]

    // Pike Perfection - Week 1 Sessions
    static let pikeSessions: [Session] = [
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000001")!,
            programId: Program.pikePerfection.id,
            weekNumber: 1,
            dayNumber: 1,
            title: "Pike Assessment",
            description: "Test your current pike and identify limiting factors.",
            focusArea: "Assessment",
            durationMinutes: 12,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000002")!,
            programId: Program.pikePerfection.id,
            weekNumber: 1,
            dayNumber: 2,
            title: "Hamstring Prep",
            description: "Prepare your hamstrings for deep stretching.",
            focusArea: "Hamstrings",
            durationMinutes: 20,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000003")!,
            programId: Program.pikePerfection.id,
            weekNumber: 1,
            dayNumber: 3,
            title: "Hip Flexor Strength",
            description: "Strong hip flexors pull you deeper into your pike.",
            focusArea: "Hip Flexors",
            durationMinutes: 18,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000004")!,
            programId: Program.pikePerfection.id,
            weekNumber: 1,
            dayNumber: 4,
            title: "Standing Pike Flow",
            description: "Progressive standing pike work with holds and pulses.",
            focusArea: "Full Pike",
            durationMinutes: 22,
            videoUrl: nil,
            thumbnailUrl: nil,
            isCompleted: false
        ),
        Session(
            id: UUID(uuidString: "s2222222-2222-4444-bbbb-000000000005")!,
            programId: Program.pikePerfection.id,
            weekNumber: 1,
            dayNumber: 5,
            title: "Seated Pike Deep Work",
            description: "Seated pike variations with weighted stretches.",
            focusArea: "Full Pike",
            durationMinutes: 25,
            videoUrl: nil,
            thumbnailUrl: nil,
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
            userId: Coach.dylanPeters.userId ?? UUID(),
            content: "Great work this week everyone! Remember: consistency beats intensity. Even 10 minutes counts.",
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
        ChatMessage(
            id: UUID(),
            teamId: Team.lowBackLiberation.id,
            userId: UUID(),
            content: "Anyone else struggling with the hip hinge? Tips?",
            createdAt: Date().addingTimeInterval(-900),
            senderName: "Mike R.",
            senderInitials: "MR",
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
        Badge(id: UUID(), name: "Team Player", description: "Send 10 chat messages", icon: "person.2.fill", isUnlocked: true),
        Badge(id: UUID(), name: "30 Days", description: "Maintain a 30-day streak", icon: "trophy.fill", isUnlocked: false),
        Badge(id: UUID(), name: "Master", description: "Complete 100 sessions", icon: "crown.fill", isUnlocked: false),
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
