import SwiftUI

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable {
    let id: UUID
    let userId: UUID
    let userName: String
    let userInitials: String
    let rank: Int
    let sessionsCompleted: Int
    let currentStreak: Int
    let totalMinutes: Int
    var isCurrentUser: Bool = false

    static let preview: [LeaderboardEntry] = [
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "Sarah M.", userInitials: "SM", rank: 1, sessionsCompleted: 24, currentStreak: 12, totalMinutes: 456),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "Mike R.", userInitials: "MR", rank: 2, sessionsCompleted: 21, currentStreak: 8, totalMinutes: 398),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "Emily K.", userInitials: "EK", rank: 3, sessionsCompleted: 19, currentStreak: 7, totalMinutes: 361, isCurrentUser: true),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "James W.", userInitials: "JW", rank: 4, sessionsCompleted: 18, currentStreak: 5, totalMinutes: 342),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "Lisa P.", userInitials: "LP", rank: 5, sessionsCompleted: 16, currentStreak: 4, totalMinutes: 304),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "David C.", userInitials: "DC", rank: 6, sessionsCompleted: 14, currentStreak: 3, totalMinutes: 266),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "Anna S.", userInitials: "AS", rank: 7, sessionsCompleted: 12, currentStreak: 2, totalMinutes: 228),
        LeaderboardEntry(id: UUID(), userId: UUID(), userName: "Tom B.", userInitials: "TB", rank: 8, sessionsCompleted: 10, currentStreak: 1, totalMinutes: 190),
    ]
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @EnvironmentObject var appState: AppState

    @State private var entries: [LeaderboardEntry] = LeaderboardEntry.preview
    @State private var selectedMetric: LeaderboardMetric = .sessions
    @State private var timeRange: TimeRange = .allTime

    enum LeaderboardMetric: String, CaseIterable {
        case sessions = "Sessions"
        case streak = "Streak"
        case minutes = "Minutes"
    }

    enum TimeRange: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case allTime = "All Time"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Metric Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LeaderboardMetric.allCases, id: \.self) { metric in
                        MetricPill(
                            title: metric.rawValue,
                            isSelected: selectedMetric == metric
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMetric = metric
                            }
                        }
                    }

                    Divider()
                        .frame(height: 24)
                        .padding(.horizontal, 8)

                    ForEach(TimeRange.allCases, id: \.self) { range in
                        MetricPill(
                            title: range.rawValue,
                            isSelected: timeRange == range,
                            isSecondary: true
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                timeRange = range
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)

            // Top 3 Podium
            TopThreePodium(entries: Array(sortedEntries.prefix(3)), metric: selectedMetric)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            // Full Rankings
            VStack(alignment: .leading, spacing: 14) {
                Text("Full Rankings")
                    .font(FLEKKSFonts.titleSmall)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    ForEach(sortedEntries) { entry in
                        LeaderboardRow(entry: entry, metric: selectedMetric)
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer(minLength: 100)
        }
        .background(Color.bgPrimary)
    }

    private var sortedEntries: [LeaderboardEntry] {
        switch selectedMetric {
        case .sessions:
            return entries.sorted { $0.sessionsCompleted > $1.sessionsCompleted }
        case .streak:
            return entries.sorted { $0.currentStreak > $1.currentStreak }
        case .minutes:
            return entries.sorted { $0.totalMinutes > $1.totalMinutes }
        }
    }
}

// MARK: - Metric Pill
struct MetricPill: View {
    let title: String
    let isSelected: Bool
    var isSecondary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(isSelected ? (isSecondary ? .textPrimary : .bgPrimary) : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? (isSecondary ? Color.bgElevated : AnyView(FLEKKSGradients.buttonGradient))
                        : AnyView(Color.bgCard)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected && isSecondary ? FLEKKSGradients.borderGradient : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Top Three Podium
struct TopThreePodium: View {
    let entries: [LeaderboardEntry]
    let metric: LeaderboardView.LeaderboardMetric

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if entries.count > 1 {
                // 2nd place
                PodiumSpot(entry: entries[1], place: 2, metric: metric, height: 100)
            }

            if entries.count > 0 {
                // 1st place
                PodiumSpot(entry: entries[0], place: 1, metric: metric, height: 130)
            }

            if entries.count > 2 {
                // 3rd place
                PodiumSpot(entry: entries[2], place: 3, metric: metric, height: 80)
            }
        }
    }
}

// MARK: - Podium Spot
struct PodiumSpot: View {
    let entry: LeaderboardEntry
    let place: Int
    let metric: LeaderboardView.LeaderboardMetric
    let height: CGFloat

    private var placeColor: Color {
        switch place {
        case 1: return Color(hex: "FFD700")  // Gold
        case 2: return Color(hex: "C0C0C0")  // Silver
        case 3: return Color(hex: "CD7F32")  // Bronze
        default: return .textMuted
        }
    }

    private var placeEmoji: String {
        switch place {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    private var metricValue: String {
        switch metric {
        case .sessions: return "\(entry.sessionsCompleted)"
        case .streak: return "\(entry.currentStreak)"
        case .minutes: return "\(entry.totalMinutes)"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Medal
            Text(placeEmoji)
                .font(.system(size: place == 1 ? 32 : 24))

            // Avatar
            ZStack {
                Circle()
                    .fill(place == 1 ? FLEKKSGradients.avatarGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                    .frame(width: place == 1 ? 64 : 52, height: place == 1 ? 64 : 52)

                Text(entry.userInitials)
                    .font(.system(size: place == 1 ? 22 : 18, weight: .bold))
                    .foregroundColor(place == 1 ? .bgPrimary : .textSecondary)
            }
            .overlay(
                Circle()
                    .stroke(placeColor, lineWidth: place == 1 ? 3 : 2)
            )

            // Name
            Text(entry.userName)
                .font(FLEKKSFonts.bodySemibold(place == 1 ? 14 : 12))
                .foregroundColor(.textPrimary)
                .lineLimit(1)

            // Metric value
            Text(metricValue)
                .font(FLEKKSFonts.headingHeavy(place == 1 ? 24 : 20))
                .foregroundColor(.textPrimary)

            // Podium block
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [placeColor.opacity(0.3), placeColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: height)
                .overlay(
                    Text("\(place)")
                        .font(FLEKKSFonts.headingHeavy(28))
                        .foregroundColor(placeColor)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let metric: LeaderboardView.LeaderboardMetric

    private var metricValue: String {
        switch metric {
        case .sessions: return "\(entry.sessionsCompleted) sessions"
        case .streak: return "\(entry.currentStreak) day streak"
        case .minutes: return "\(entry.totalMinutes) min"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Rank
            Text("\(entry.rank)")
                .font(FLEKKSFonts.headingHeavy(16))
                .foregroundColor(entry.rank <= 3 ? rankColor : .textMuted)
                .frame(width: 28)

            // Avatar
            AvatarView(
                initials: entry.userInitials,
                size: 40,
                useGradient: entry.rank <= 3
            )

            // Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.userName)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)

                    if entry.isCurrentUser {
                        Text("YOU")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentGlowStrong)
                            .clipShape(Capsule())
                    }
                }

                Text(metricValue)
                    .font(FLEKKSFonts.body(13))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Streak indicator for streak metric
            if metric == .streak && entry.currentStreak > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 16))
                    Text("\(entry.currentStreak)")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.flekksOrange)
                }
            }
        }
        .padding(14)
        .background(entry.isCurrentUser ? Color.accentGlow : Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    entry.isCurrentUser ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle,
                    lineWidth: entry.isCurrentUser ? 1.5 : 1
                )
        )
    }

    private var rankColor: Color {
        switch entry.rank {
        case 1: return Color(hex: "FFD700")
        case 2: return Color(hex: "C0C0C0")
        case 3: return Color(hex: "CD7F32")
        default: return .textMuted
        }
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()

        ScrollView {
            LeaderboardView()
                .environmentObject(AppState())
        }
    }
}
