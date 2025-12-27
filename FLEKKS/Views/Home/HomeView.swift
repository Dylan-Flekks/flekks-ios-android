import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    private let dayNumbers = [23, 24, 25, 26, 27, 28, 29]
    private let completedDays = [0, 1, 2] // Mon, Tue, Wed completed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Good morning")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                        Text("Alex")
                            .font(.custom("Georgia", size: 28))
                            .foregroundColor(.textPrimary)
                    }

                    Spacer()

                    // Streak badge
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("🔥")
                                .font(.system(size: 16))
                            Text("\(appState.currentStreak)")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.flekksOrange)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 28)

                // Today's Session Card
                TodaySessionCard()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                // This Week section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("This Week")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Button("View All") {}
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.accent)
                    }

                    // Week days
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { index in
                            WeekDayCard(
                                dayName: weekDays[index],
                                dayNumber: dayNumbers[index],
                                isToday: index == 3,
                                isCompleted: completedDays.contains(index)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                // Team Chat Preview
                VStack(alignment: .leading, spacing: 14) {
                    Text("Team Chat")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    TeamChatPreviewCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color.bgPrimary)
    }
}

struct TodaySessionCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Hero
            ZStack {
                FLEKKSGradients.heroGreen
                    .frame(height: 120)

                // Glow effect
                Circle()
                    .fill(FLEKKSGradients.tealGlow)
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)

                Text("🧘")
                    .font(.system(size: 48))
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("TODAY'S SESSION")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.accent)
                    .tracking(1.5)

                Text("Hip Opener Flow")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(.textPrimary)

                Text("with Dr. Dylan")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, 12)

                // Meta info
                HStack(spacing: 12) {
                    MetaTag(icon: "clock", text: "18 min")
                    MetaTag(icon: "flame", text: "Moderate")
                    MetaTag(icon: "target", text: "Hips")
                }
                .padding(.bottom, 18)

                Button(action: {}) {
                    Text("Start Session")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct MetaTag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12))
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct WeekDayCard: View {
    let dayName: String
    let dayNumber: Int
    let isToday: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textMuted)

            Text("\(dayNumber)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.accent)
            } else {
                Color.clear
                    .frame(height: 14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isToday ? Color.accentGlow : Color.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isToday ? Color.accent : Color.border, lineWidth: 1)
        )
    }
}

struct TeamChatPreviewCard: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                // Avatar stack
                HStack(spacing: -10) {
                    ForEach(["DD", "SM", "MR"], id: \.self) { initials in
                        ZStack {
                            Circle()
                                .fill(FLEKKSGradients.avatarGradient)
                                .frame(width: 32, height: 32)
                            Text(initials)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.bgPrimary)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.bgCard, lineWidth: 2)
                        )
                    }

                    ZStack {
                        Circle()
                            .fill(Color.bgElevated)
                            .frame(width: 32, height: 32)
                        Text("+12")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.bgCard, lineWidth: 2)
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Team Bulletproof")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("Sarah: Just finished Day 5! 🎉")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Unread badge
                Text("3")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Color.flekksRed)
                    .clipShape(Circle())
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
