import SwiftUI

struct UserProgressView: View {
    @EnvironmentObject var appState: AppState

    private let badges = Badge.previewBadges

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Text("Progress")
                    .font(.custom("Georgia", size: 32))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 24)

                VStack(spacing: 14) {
                    // Main streak card
                    VStack(spacing: 10) {
                        Text("CURRENT STREAK")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.textMuted)
                            .tracking(1.5)

                        Text("\(appState.currentStreak)")
                            .font(.custom("Georgia", size: 56))
                            .foregroundColor(.accent)

                        Text("days in a row")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.border, lineWidth: 1)
                    )

                    // Stats grid
                    HStack(spacing: 14) {
                        StatCard(
                            title: "SESSIONS",
                            value: "47",
                            subtitle: "completed"
                        )
                        StatCard(
                            title: "MINUTES",
                            value: "892",
                            subtitle: "total time"
                        )
                    }

                    HStack(spacing: 14) {
                        StatCard(
                            title: "LONGEST STREAK",
                            value: "21",
                            subtitle: "days"
                        )
                        StatCard(
                            title: "THIS WEEK",
                            value: "4",
                            subtitle: "sessions"
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                // Badges section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Badges")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                        ForEach(badges) { badge in
                            BadgeCard(badge: badge)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
        }
        .background(Color.bgPrimary)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textMuted)
                .tracking(1.5)

            Text(value)
                .font(.custom("Georgia", size: 36))
                .foregroundColor(.accent)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct BadgeCard: View {
    let badge: Badge

    var body: some View {
        VStack(spacing: 6) {
            Text(badge.icon)
                .font(.system(size: 28))

            Text(badge.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.border, lineWidth: 1)
        )
        .opacity(badge.isUnlocked ? 1.0 : 0.35)
    }
}

#Preview {
    UserProgressView()
        .environmentObject(AppState())
}
