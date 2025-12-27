import Foundation

// MARK: - User
struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var avatarInitials: String
    var joinedDate: Date
    var streakCount: Int
    var totalSessions: Int
    var totalMinutes: Int

    static let preview = User(
        id: UUID(),
        name: "Alex",
        email: "alex@example.com",
        avatarInitials: "A",
        joinedDate: Date(),
        streakCount: 12,
        totalSessions: 47,
        totalMinutes: 892
    )
}

// MARK: - Coach
struct Coach: Identifiable, Codable {
    let id: UUID
    var name: String
    var credential: String
    var avatarInitials: String
    var bio: String

    static let dylan = Coach(
        id: UUID(),
        name: "Dr. Dylan",
        credential: "DPT, CSCS",
        avatarInitials: "DD",
        bio: "Physical Therapist specializing in mobility and injury prevention"
    )

    static let maya = Coach(
        id: UUID(),
        name: "Maya Chen",
        credential: "Flexibility Coach",
        avatarInitials: "MC",
        bio: "Former dancer, splits and backbend specialist"
    )

    static let jordan = Coach(
        id: UUID(),
        name: "Jordan Brooks",
        credential: "Movement Coach",
        avatarInitials: "JB",
        bio: "Yoga-influenced flows for everyday mobility"
    )
}

// MARK: - Team
struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var coach: Coach
    var memberCount: Int
    var matchPercentage: Int
    var heroGradient: GradientStyle
    var isLive: Bool
    var focus: String

    enum GradientStyle: String, Codable {
        case green
        case purple
        case blue
    }

    static let bulletproof = Team(
        id: UUID(),
        name: "Bulletproof",
        description: "Desk worker focused. Undo the damage from sitting, build lasting mobility, prevent injury.",
        coach: Coach.dylan,
        memberCount: 847,
        matchPercentage: 94,
        heroGradient: .green,
        isLive: true,
        focus: "Injury Prevention"
    )

    static let fullRange = Team(
        id: UUID(),
        name: "Full Range",
        description: "For those chasing splits, backbends, and advanced flexibility goals.",
        coach: Coach.maya,
        memberCount: 523,
        matchPercentage: 78,
        heroGradient: .purple,
        isLive: false,
        focus: "Advanced Flexibility"
    )

    static let flowState = Team(
        id: UUID(),
        name: "Flow State",
        description: "Feel-good movement flows. Accessible, calming, perfect for beginners.",
        coach: Coach.jordan,
        memberCount: 612,
        matchPercentage: 82,
        heroGradient: .blue,
        isLive: false,
        focus: "Beginner Friendly"
    )

    static let allTeams: [Team] = [.bulletproof, .fullRange, .flowState]
}

// MARK: - Program
struct Program: Identifiable, Codable {
    let id: UUID
    var name: String
    var coach: Coach
    var weekCount: Int
    var currentWeek: Int
    var completedSessions: Int
    var totalSessions: Int
    var description: String

    var progressPercentage: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }

    static let deskReset = Program(
        id: UUID(),
        name: "Desk Reset",
        coach: Coach.dylan,
        weekCount: 6,
        currentWeek: 2,
        completedSessions: 7,
        totalSessions: 25,
        description: "Undo the damage from sitting"
    )
}

// MARK: - Session
struct Session: Identifiable, Codable {
    let id: UUID
    var title: String
    var duration: Int // minutes
    var focusArea: String
    var isCompleted: Bool
    var dayNumber: Int

    static let hipOpener = Session(
        id: UUID(),
        title: "Hip Opener Flow",
        duration: 18,
        focusArea: "Hips & Lower Back",
        isCompleted: false,
        dayNumber: 1
    )

    static let spinalReset = Session(
        id: UUID(),
        title: "Spinal Reset",
        duration: 15,
        focusArea: "Back & Shoulders",
        isCompleted: true,
        dayNumber: 2
    )

    static let previewSessions: [Session] = [
        .hipOpener,
        .spinalReset,
        Session(id: UUID(), title: "Shoulder Unlock", duration: 20, focusArea: "Shoulders & Neck", isCompleted: true, dayNumber: 3),
        Session(id: UUID(), title: "Full Body Flow", duration: 25, focusArea: "Full Body", isCompleted: false, dayNumber: 4),
        Session(id: UUID(), title: "Active Recovery", duration: 12, focusArea: "Gentle Movement", isCompleted: false, dayNumber: 5),
    ]
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var senderName: String
    var senderInitials: String
    var isCoach: Bool
    var text: String
    var timestamp: Date

    static let previewMessages: [ChatMessage] = [
        ChatMessage(
            id: UUID(),
            senderName: "Dr. Dylan",
            senderInitials: "DD",
            isCoach: true,
            text: "Great work this week everyone! Remember: consistency beats intensity. Even 10 minutes counts.",
            timestamp: Date().addingTimeInterval(-3600)
        ),
        ChatMessage(
            id: UUID(),
            senderName: "Sarah M.",
            senderInitials: "SM",
            isCoach: false,
            text: "Just finished Day 5! My hips have never felt this good.",
            timestamp: Date().addingTimeInterval(-1800)
        ),
        ChatMessage(
            id: UUID(),
            senderName: "Mike R.",
            senderInitials: "MR",
            isCoach: false,
            text: "Anyone else struggling with the pigeon pose? Tips?",
            timestamp: Date().addingTimeInterval(-900)
        ),
    ]
}

// MARK: - Badge
struct Badge: Identifiable {
    let id: UUID
    var name: String
    var icon: String
    var isUnlocked: Bool

    static let previewBadges: [Badge] = [
        Badge(id: UUID(), name: "First Session", icon: "🎯", isUnlocked: true),
        Badge(id: UUID(), name: "Week Warrior", icon: "🔥", isUnlocked: true),
        Badge(id: UUID(), name: "Early Bird", icon: "🌅", isUnlocked: true),
        Badge(id: UUID(), name: "Consistent", icon: "⚡️", isUnlocked: false),
        Badge(id: UUID(), name: "Flexible", icon: "🧘", isUnlocked: false),
        Badge(id: UUID(), name: "Team Player", icon: "👥", isUnlocked: true),
        Badge(id: UUID(), name: "30 Days", icon: "🏆", isUnlocked: false),
        Badge(id: UUID(), name: "Master", icon: "👑", isUnlocked: false),
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
                QuizOption(id: "pain", title: "Reduce Pain", description: "Back, neck, or joint discomfort", icon: "💆"),
                QuizOption(id: "flexibility", title: "Get Flexible", description: "Touch toes, splits, backbends", icon: "🧘"),
                QuizOption(id: "performance", title: "Perform Better", description: "Sports, lifting, activities", icon: "⚡️"),
                QuizOption(id: "general", title: "Feel Better", description: "Overall movement & wellness", icon: "✨"),
            ]
        ),
        QuizQuestion(
            id: 1,
            question: "How would you describe your flexibility?",
            options: [
                QuizOption(id: "stiff", title: "Very Stiff", description: "Can barely touch my knees", icon: "🪨"),
                QuizOption(id: "average", title: "Average", description: "Somewhat flexible", icon: "🌱"),
                QuizOption(id: "good", title: "Pretty Good", description: "Above average mobility", icon: "🌿"),
                QuizOption(id: "advanced", title: "Very Flexible", description: "Looking to push further", icon: "🌳"),
            ]
        ),
        QuizQuestion(
            id: 2,
            question: "Where do you feel the most tension?",
            options: [
                QuizOption(id: "hips", title: "Hips & Lower Back", description: "Tight from sitting", icon: "🪑"),
                QuizOption(id: "shoulders", title: "Shoulders & Neck", description: "Stress and posture", icon: "💻"),
                QuizOption(id: "legs", title: "Legs & Hamstrings", description: "Tight from activity", icon: "🏃"),
                QuizOption(id: "everywhere", title: "Everywhere", description: "Full body stiffness", icon: "🫠"),
            ]
        ),
        QuizQuestion(
            id: 3,
            question: "How much time can you commit daily?",
            options: [
                QuizOption(id: "10min", title: "10-15 minutes", description: "Quick and focused", icon: "⚡️"),
                QuizOption(id: "20min", title: "15-25 minutes", description: "Solid session", icon: "🎯"),
                QuizOption(id: "30min", title: "25-40 minutes", description: "Deep work", icon: "🔥"),
                QuizOption(id: "flexible", title: "Varies", description: "Depends on the day", icon: "🔄"),
            ]
        ),
    ]
}
