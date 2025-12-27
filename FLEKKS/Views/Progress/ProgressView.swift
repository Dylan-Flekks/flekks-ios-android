import SwiftUI

// MARK: - Progress Tab Container
struct UserProgressView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSection = 0
    @State private var showStreakDetail = false
    @State private var showBadgesDetail = false
    @State private var showFlexibilityDetail = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                progressHeader

                // Section Tabs
                sectionTabs

                // Content based on selected section
                switch selectedSection {
                case 0:
                    overviewSection
                case 1:
                    WeeklyChallengesView()
                case 2:
                    FlexibilityTrackerView()
                case 3:
                    BadgesView()
                default:
                    overviewSection
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.bgPrimary)
        .sheet(isPresented: $showStreakDetail) {
            StreakView()
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(FLEKKSFonts.heading(32))
                .foregroundColor(.textPrimary)

            Text("Track your flexibility journey")
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ProgressTabPill(title: "Overview", isSelected: selectedSection == 0) {
                    selectedSection = 0
                }
                ProgressTabPill(title: "Challenges", isSelected: selectedSection == 1) {
                    selectedSection = 1
                }
                ProgressTabPill(title: "Flexibility", isSelected: selectedSection == 2) {
                    selectedSection = 2
                }
                ProgressTabPill(title: "Badges", isSelected: selectedSection == 3) {
                    selectedSection = 3
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var overviewSection: some View {
        VStack(spacing: 20) {
            // Streak Card - Tappable
            Button(action: { showStreakDetail = true }) {
                streakCard
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // Stats Grid
            statsGrid
                .padding(.horizontal, 20)

            // Recent Badges Preview
            if !Badge.previewEarned.isEmpty {
                RecentBadgesBanner(recentBadges: Badge.previewEarned) {
                    selectedSection = 3
                }
                .padding(.horizontal, 20)
            }

            // Weekly Progress
            weeklyProgressCard
                .padding(.horizontal, 20)

            // Quick Actions
            quickActionsSection
                .padding(.horizontal, 20)
        }
    }

    private var streakCard: some View {
        HStack(spacing: 20) {
            // Flame with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.flekksOrange.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                VStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 32))

                    Text("\(appState.currentStreak)")
                        .font(FLEKKSFonts.headingHeavy(36))
                        .foregroundColor(.textPrimary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("CURRENT STREAK")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
                    .tracking(1.5)

                Text("days in a row")
                    .font(FLEKKSFonts.bodyMedium(16))
                    .foregroundColor(.textSecondary)

                // Streak status
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                    Text("Personal best: 21 days")
                        .font(FLEKKSFonts.labelMedium)
                }
                .foregroundColor(.flekksOrange)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.textMuted)
        }
        .padding(20)
        .background(
            ZStack {
                Color.bgCard
                LinearGradient(
                    colors: [Color.flekksOrange.opacity(0.1), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.flekksOrange.opacity(0.5), Color.flekksOrange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }

    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                EnhancedStatCard(
                    title: "SESSIONS",
                    value: "47",
                    subtitle: "completed",
                    icon: "checkmark.circle.fill",
                    color: .accent
                )
                EnhancedStatCard(
                    title: "MINUTES",
                    value: "892",
                    subtitle: "total time",
                    icon: "clock.fill",
                    color: .tealBright
                )
            }

            HStack(spacing: 12) {
                EnhancedStatCard(
                    title: "THIS WEEK",
                    value: "4",
                    subtitle: "sessions",
                    icon: "calendar",
                    color: .accentLight
                )
                EnhancedStatCard(
                    title: "XP EARNED",
                    value: "1,250",
                    subtitle: "points",
                    icon: "star.fill",
                    color: .flekksOrange
                )
            }
        }
    }

    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week")
                    .font(FLEKKSFonts.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("4/7 days")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textMuted)
            }

            // Week day circles
            HStack(spacing: 8) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    WeekDayCircle(
                        day: day,
                        isCompleted: ["M", "T", "W", "T"].contains(day),
                        isToday: day == "F"
                    )
                }
            }

            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.bgElevated)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(FLEKKSGradients.accentGradientVibrant)
                            .frame(width: geometry.size.width * 0.57, height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("57% of weekly goal")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)

                    Spacer()

                    Text("3 more to go")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.accent)
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions")
                .font(FLEKKSFonts.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: 12) {
                QuickActionCard(
                    icon: "ruler",
                    title: "Log Progress",
                    color: .accent
                ) {
                    selectedSection = 2
                }

                QuickActionCard(
                    icon: "trophy.fill",
                    title: "View Badges",
                    color: .flekksOrange
                ) {
                    selectedSection = 3
                }

                QuickActionCard(
                    icon: "target",
                    title: "Challenges",
                    color: .tealBright
                ) {
                    selectedSection = 1
                }
            }
        }
    }
}

// MARK: - Progress Tab Pill
struct ProgressTabPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FLEKKSFonts.bodySemibold(14))
                .foregroundColor(isSelected ? .bgPrimary : .textSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(isSelected ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgCard], startPoint: .top, endPoint: .bottom))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
                )
        }
    }
}

// MARK: - Enhanced Stat Card
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }

            Text(title)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)
                .tracking(1.5)

            Text(value)
                .font(FLEKKSFonts.headingHeavy(32))
                .foregroundColor(.textPrimary)

            Text(subtitle)
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Week Day Circle
struct WeekDayCircle: View {
    let day: String
    let isCompleted: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(day)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)

            ZStack {
                Circle()
                    .fill(isCompleted ? Color.accent : Color.bgElevated)
                    .frame(width: 36, height: 36)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.bgPrimary)
                }
            }
            .overlay(
                Circle()
                    .stroke(isToday ? Color.accent : Color.clear, lineWidth: 2)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Legacy Badge Model (for compatibility)
struct Badge: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let isUnlocked: Bool

    static let previewBadges: [Badge] = [
        Badge(id: UUID(), name: "First Stretch", icon: "🌟", isUnlocked: true),
        Badge(id: UUID(), name: "Week Warrior", icon: "⚔️", isUnlocked: true),
        Badge(id: UUID(), name: "Early Bird", icon: "🌅", isUnlocked: true),
        Badge(id: UUID(), name: "Hip Hero", icon: "🦵", isUnlocked: true),
        Badge(id: UUID(), name: "Monthly Master", icon: "🏆", isUnlocked: false),
        Badge(id: UUID(), name: "Centurion", icon: "💯", isUnlocked: false),
        Badge(id: UUID(), name: "Full Split", icon: "🤸", isUnlocked: false),
        Badge(id: UUID(), name: "Flexibility God", icon: "👑", isUnlocked: false),
    ]
}

#Preview {
    UserProgressView()
        .environmentObject(AppState())
}
