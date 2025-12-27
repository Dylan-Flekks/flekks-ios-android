import SwiftUI

// MARK: - Badge Model
struct Badge: Identifiable, Codable {
    let id: UUID
    let type: BadgeType
    let tier: BadgeTier
    let earnedAt: Date?
    let progress: Double  // 0-1 for progress towards earning

    var isEarned: Bool {
        earnedAt != nil
    }

    enum BadgeType: String, Codable, CaseIterable {
        // Streak badges
        case streakStarter = "Streak Starter"
        case weekWarrior = "Week Warrior"
        case monthlyMaster = "Monthly Master"
        case centurion = "Centurion"

        // Session completion badges
        case firstSession = "First Session"
        case tenSessions = "10 Sessions"
        case fiftySessions = "50 Sessions"
        case hundredSessions = "100 Sessions"

        // Time-based badges
        case earlyBird = "Early Bird"
        case nightOwl = "Night Owl"
        case weekendWarrior = "Weekend Warrior"

        // Focus area mastery
        case hipHero = "Hip Hero"
        case spineSpecialist = "Spine Specialist"
        case shoulderStar = "Shoulder Star"
        case hamstringHero = "Hamstring Hero"
        case fullBodyMaster = "Full Body Master"

        // Social badges
        case teamPlayer = "Team Player"
        case cheerLeader = "Cheer Leader"
        case inspirer = "Inspirer"

        // Challenge badges
        case challengeChampion = "Challenge Champion"
        case perfectWeek = "Perfect Week"

        var icon: String {
            switch self {
            case .streakStarter: return "🔥"
            case .weekWarrior: return "⚔️"
            case .monthlyMaster: return "🏆"
            case .centurion: return "💯"
            case .firstSession: return "🌟"
            case .tenSessions: return "⭐️"
            case .fiftySessions: return "🌠"
            case .hundredSessions: return "💫"
            case .earlyBird: return "🌅"
            case .nightOwl: return "🦉"
            case .weekendWarrior: return "🎉"
            case .hipHero: return "🦵"
            case .spineSpecialist: return "🧘"
            case .shoulderStar: return "🙆"
            case .hamstringHero: return "🏃"
            case .fullBodyMaster: return "🏅"
            case .teamPlayer: return "🤝"
            case .cheerLeader: return "📣"
            case .inspirer: return "✨"
            case .challengeChampion: return "🎯"
            case .perfectWeek: return "💎"
            }
        }

        var description: String {
            switch self {
            case .streakStarter: return "Complete a 3-day streak"
            case .weekWarrior: return "Complete a 7-day streak"
            case .monthlyMaster: return "Complete a 30-day streak"
            case .centurion: return "Complete a 100-day streak"
            case .firstSession: return "Complete your first session"
            case .tenSessions: return "Complete 10 sessions"
            case .fiftySessions: return "Complete 50 sessions"
            case .hundredSessions: return "Complete 100 sessions"
            case .earlyBird: return "Complete 5 sessions before 8am"
            case .nightOwl: return "Complete 5 sessions after 9pm"
            case .weekendWarrior: return "Complete 10 weekend sessions"
            case .hipHero: return "Complete 20 hip-focused sessions"
            case .spineSpecialist: return "Complete 20 spine sessions"
            case .shoulderStar: return "Complete 20 shoulder sessions"
            case .hamstringHero: return "Complete 20 hamstring sessions"
            case .fullBodyMaster: return "Master all body areas"
            case .teamPlayer: return "Join a team and complete 5 sessions"
            case .cheerLeader: return "Send 50 cheers to teammates"
            case .inspirer: return "Receive 100 cheers from others"
            case .challengeChampion: return "Complete 10 weekly challenges"
            case .perfectWeek: return "Complete all challenges in a week"
            }
        }

        var category: BadgeCategory {
            switch self {
            case .streakStarter, .weekWarrior, .monthlyMaster, .centurion:
                return .streak
            case .firstSession, .tenSessions, .fiftySessions, .hundredSessions:
                return .sessions
            case .earlyBird, .nightOwl, .weekendWarrior:
                return .time
            case .hipHero, .spineSpecialist, .shoulderStar, .hamstringHero, .fullBodyMaster:
                return .mastery
            case .teamPlayer, .cheerLeader, .inspirer:
                return .social
            case .challengeChampion, .perfectWeek:
                return .challenges
            }
        }

        var targetValue: Int {
            switch self {
            case .streakStarter: return 3
            case .weekWarrior: return 7
            case .monthlyMaster: return 30
            case .centurion: return 100
            case .firstSession: return 1
            case .tenSessions: return 10
            case .fiftySessions: return 50
            case .hundredSessions: return 100
            case .earlyBird, .nightOwl: return 5
            case .weekendWarrior: return 10
            case .hipHero, .spineSpecialist, .shoulderStar, .hamstringHero: return 20
            case .fullBodyMaster: return 4  // All 4 area badges
            case .teamPlayer: return 5
            case .cheerLeader: return 50
            case .inspirer: return 100
            case .challengeChampion: return 10
            case .perfectWeek: return 1
            }
        }

        var xpReward: Int {
            switch self {
            case .streakStarter: return 50
            case .weekWarrior: return 100
            case .monthlyMaster: return 500
            case .centurion: return 1000
            case .firstSession: return 25
            case .tenSessions: return 100
            case .fiftySessions: return 250
            case .hundredSessions: return 500
            case .earlyBird, .nightOwl, .weekendWarrior: return 75
            case .hipHero, .spineSpecialist, .shoulderStar, .hamstringHero: return 150
            case .fullBodyMaster: return 500
            case .teamPlayer: return 100
            case .cheerLeader: return 150
            case .inspirer: return 200
            case .challengeChampion: return 300
            case .perfectWeek: return 200
            }
        }
    }

    enum BadgeTier: String, Codable {
        case bronze
        case silver
        case gold
        case platinum

        var color: Color {
            switch self {
            case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
            case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
            case .gold: return Color(red: 1.0, green: 0.84, blue: 0)
            case .platinum: return Color(red: 0.9, green: 0.95, blue: 1.0)
            }
        }

        var gradient: LinearGradient {
            switch self {
            case .bronze:
                return LinearGradient(colors: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.35, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .silver:
                return LinearGradient(colors: [Color(red: 0.85, green: 0.85, blue: 0.9), Color(red: 0.6, green: 0.6, blue: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .gold:
                return LinearGradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.4), Color(red: 0.85, green: 0.65, blue: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .platinum:
                return LinearGradient(colors: [Color(red: 0.95, green: 0.98, blue: 1.0), Color(red: 0.7, green: 0.8, blue: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    enum BadgeCategory: String, CaseIterable {
        case streak = "Streaks"
        case sessions = "Sessions"
        case time = "Time"
        case mastery = "Mastery"
        case social = "Social"
        case challenges = "Challenges"

        var icon: String {
            switch self {
            case .streak: return "flame.fill"
            case .sessions: return "checkmark.circle.fill"
            case .time: return "clock.fill"
            case .mastery: return "star.fill"
            case .social: return "person.2.fill"
            case .challenges: return "trophy.fill"
            }
        }
    }

    static let allBadges: [Badge] = BadgeType.allCases.map { type in
        Badge(
            id: UUID(),
            type: type,
            tier: .bronze,
            earnedAt: nil,
            progress: Double.random(in: 0...1)  // Preview data
        )
    }

    static let previewEarned: [Badge] = [
        Badge(id: UUID(), type: .firstSession, tier: .bronze, earnedAt: Date().addingTimeInterval(-86400 * 10), progress: 1.0),
        Badge(id: UUID(), type: .streakStarter, tier: .bronze, earnedAt: Date().addingTimeInterval(-86400 * 7), progress: 1.0),
        Badge(id: UUID(), type: .weekWarrior, tier: .silver, earnedAt: Date().addingTimeInterval(-86400 * 3), progress: 1.0),
        Badge(id: UUID(), type: .earlyBird, tier: .bronze, earnedAt: Date(), progress: 1.0),
    ]
}

// MARK: - Badges View
struct BadgesView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: Badge.BadgeCategory?
    @State private var selectedBadge: Badge?
    @State private var earnedBadges: [Badge] = Badge.previewEarned
    @State private var allBadges: [Badge] = Badge.allBadges

    private var totalXP: Int {
        earnedBadges.reduce(0) { $0 + $1.type.xpReward }
    }

    private var filteredBadges: [Badge] {
        if let category = selectedCategory {
            return allBadges.filter { $0.type.category == category }
        }
        return allBadges
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header Stats
            badgeStatsHeader

            // Category Filter
            categoryFilter

            // Badges Grid
            badgesGrid
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailSheet(badge: badge)
        }
    }

    private var badgeStatsHeader: some View {
        HStack(spacing: 16) {
            // Earned count
            VStack(spacing: 4) {
                Text("\(earnedBadges.count)")
                    .font(FLEKKSFonts.headingHeavy(32))
                    .foregroundColor(.textPrimary)

                Text("Earned")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Total available
            VStack(spacing: 4) {
                Text("\(Badge.BadgeType.allCases.count)")
                    .font(FLEKKSFonts.headingHeavy(32))
                    .foregroundColor(.textSecondary)

                Text("Total")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // XP Earned
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(totalXP)")
                        .font(FLEKKSFonts.headingHeavy(32))
                        .foregroundColor(.flekksOrange)
                }

                Text("XP")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    Color.bgCard
                    Color.flekksOrange.opacity(0.1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All button
                CategoryPill(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    onTap: { selectedCategory = nil }
                )

                ForEach(Badge.BadgeCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        onTap: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var badgesGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
            ForEach(filteredBadges) { badge in
                BadgeCard(
                    badge: badge,
                    isEarned: earnedBadges.contains { $0.type == badge.type },
                    onTap: { selectedBadge = badge }
                )
            }
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))

                Text(title)
                    .font(FLEKKSFonts.labelMedium)
            }
            .foregroundColor(isSelected ? .bgPrimary : .textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgCard], startPoint: .top, endPoint: .bottom))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: Badge
    let isEarned: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                // Badge Icon
                ZStack {
                    if isEarned {
                        Circle()
                            .fill(badge.tier.gradient)
                            .frame(width: 70, height: 70)

                        Circle()
                            .stroke(badge.tier.color.opacity(0.5), lineWidth: 3)
                            .frame(width: 78, height: 78)
                    } else {
                        Circle()
                            .fill(Color.bgElevated)
                            .frame(width: 70, height: 70)

                        // Progress ring
                        Circle()
                            .trim(from: 0, to: badge.progress)
                            .stroke(
                                Color.textMuted.opacity(0.5),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 78, height: 78)
                            .rotationEffect(.degrees(-90))
                    }

                    Text(badge.type.icon)
                        .font(.system(size: 30))
                        .grayscale(isEarned ? 0 : 0.8)
                        .opacity(isEarned ? 1 : 0.5)
                }

                // Badge Name
                Text(badge.type.rawValue)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(isEarned ? .textPrimary : .textMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 32)

                // XP Reward
                if isEarned {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("+\(badge.type.xpReward)")
                            .font(FLEKKSFonts.labelSmall)
                    }
                    .foregroundColor(.flekksOrange)
                } else {
                    Text("\(Int(badge.progress * 100))%")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                }
            }
            .padding(14)
            .background(isEarned ? badge.tier.color.opacity(0.1) : Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isEarned ? badge.tier.color.opacity(0.3) : FLEKKSGradients.borderGradientSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badge Detail Sheet
struct BadgeDetailSheet: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Large Badge Display
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(
                                badge.isEarned ?
                                RadialGradient(colors: [badge.tier.color.opacity(0.4), Color.clear], center: .center, startRadius: 0, endRadius: 100) :
                                    RadialGradient(colors: [Color.textMuted.opacity(0.2), Color.clear], center: .center, startRadius: 0, endRadius: 100)
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 30)

                        if badge.isEarned {
                            Circle()
                                .fill(badge.tier.gradient)
                                .frame(width: 140, height: 140)

                            Circle()
                                .stroke(badge.tier.color.opacity(0.6), lineWidth: 4)
                                .frame(width: 152, height: 152)
                        } else {
                            Circle()
                                .fill(Color.bgElevated)
                                .frame(width: 140, height: 140)

                            // Progress ring
                            Circle()
                                .trim(from: 0, to: badge.progress)
                                .stroke(
                                    Color.accent,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 152, height: 152)
                                .rotationEffect(.degrees(-90))
                        }

                        Text(badge.type.icon)
                            .font(.system(size: 60))
                            .grayscale(badge.isEarned ? 0 : 0.8)
                            .opacity(badge.isEarned ? 1 : 0.5)
                    }

                    // Badge Info
                    VStack(spacing: 12) {
                        Text(badge.type.rawValue)
                            .font(FLEKKSFonts.heading(28))
                            .foregroundColor(.textPrimary)

                        if badge.isEarned {
                            HStack(spacing: 6) {
                                Text(badge.tier.rawValue.capitalized)
                                    .font(FLEKKSFonts.bodySemibold(14))
                                    .foregroundColor(badge.tier.color)

                                Text("Tier")
                                    .font(FLEKKSFonts.body(14))
                                    .foregroundColor(.textMuted)
                            }
                        }

                        Text(badge.type.description)
                            .font(FLEKKSFonts.body(16))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    // Progress or Earned Info
                    if badge.isEarned, let earnedAt = badge.earnedAt {
                        VStack(spacing: 8) {
                            Text("Earned")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            Text(earnedAt, style: .date)
                                .font(FLEKKSFonts.bodyMedium(16))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(20)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        // Progress bar
                        VStack(spacing: 12) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.bgElevated)
                                        .frame(height: 12)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(FLEKKSGradients.accentGradientVibrant)
                                        .frame(width: geometry.size.width * badge.progress, height: 12)
                                }
                            }
                            .frame(height: 12)

                            HStack {
                                Text("\(Int(badge.progress * Double(badge.type.targetValue)))/\(badge.type.targetValue)")
                                    .font(FLEKKSFonts.bodySemibold(14))
                                    .foregroundColor(.textPrimary)

                                Spacer()

                                Text("\(Int(badge.progress * 100))% complete")
                                    .font(FLEKKSFonts.labelMedium)
                                    .foregroundColor(.textMuted)
                            }
                        }
                        .padding(20)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }

                    // XP Reward
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.flekksOrange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(badge.isEarned ? "Reward Earned" : "Reward")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)

                            Text("+\(badge.type.xpReward) XP")
                                .font(FLEKKSFonts.headingHeavy(22))
                                .foregroundColor(.flekksOrange)
                        }

                        Spacer()
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            Color.bgCard
                            Color.flekksOrange.opacity(0.1)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accent)
                }
            }
        }
    }
}

// MARK: - Recently Earned Badges Banner
struct RecentBadgesBanner: View {
    let recentBadges: [Badge]
    var onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Achievements")
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(.textPrimary)

                Spacer()

                Button(action: onViewAll) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(FLEKKSFonts.labelMedium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.accent)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentBadges) { badge in
                        RecentBadgePill(badge: badge)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }
}

struct RecentBadgePill: View {
    let badge: Badge

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(badge.tier.gradient)
                    .frame(width: 40, height: 40)

                Text(badge.type.icon)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(badge.type.rawValue)
                    .font(FLEKKSFonts.bodySemibold(13))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("+\(badge.type.xpReward)")
                        .font(FLEKKSFonts.labelSmall)
                }
                .foregroundColor(.flekksOrange)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(badge.tier.color.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(badge.tier.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()

        ScrollView {
            BadgesView()
                .padding(20)
                .environmentObject(AppState())
        }
    }
}
