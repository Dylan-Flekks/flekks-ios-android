import SwiftUI

// MARK: - Challenge Model
struct WeeklyChallenge: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let type: ChallengeType
    let target: Int
    var current: Int
    let reward: ChallengeReward
    let startDate: Date
    let endDate: Date

    enum ChallengeType {
        case sessions
        case minutes
        case streak
        case earlyBird  // Complete before 8am
        case consistency  // X days in a row
        case focusArea(String)
    }

    struct ChallengeReward {
        let badgeIcon: String
        let badgeName: String
        let xpPoints: Int
    }

    var progress: Double {
        min(Double(current) / Double(target), 1.0)
    }

    var isComplete: Bool {
        current >= target
    }

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }

    static let preview: [WeeklyChallenge] = [
        WeeklyChallenge(
            id: UUID(),
            title: "Session Warrior",
            description: "Complete 5 sessions this week",
            icon: "flame.fill",
            type: .sessions,
            target: 5,
            current: 3,
            reward: ChallengeReward(badgeIcon: "⚔️", badgeName: "Session Warrior", xpPoints: 100),
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 4)
        ),
        WeeklyChallenge(
            id: UUID(),
            title: "Early Bird",
            description: "Complete 2 sessions before 8am",
            icon: "sunrise.fill",
            type: .earlyBird,
            target: 2,
            current: 1,
            reward: ChallengeReward(badgeIcon: "🌅", badgeName: "Early Bird", xpPoints: 75),
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 4)
        ),
        WeeklyChallenge(
            id: UUID(),
            title: "Minute Master",
            description: "Accumulate 60 minutes of stretching",
            icon: "clock.fill",
            type: .minutes,
            target: 60,
            current: 45,
            reward: ChallengeReward(badgeIcon: "⏱️", badgeName: "Minute Master", xpPoints: 50),
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 4)
        ),
        WeeklyChallenge(
            id: UUID(),
            title: "Hip Focus",
            description: "Complete 3 hip-focused sessions",
            icon: "figure.flexibility",
            type: .focusArea("Hip"),
            target: 3,
            current: 3,
            reward: ChallengeReward(badgeIcon: "🦵", badgeName: "Hip Hero", xpPoints: 80),
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 4)
        ),
    ]
}

// MARK: - Weekly Challenges View
struct WeeklyChallengesView: View {
    @EnvironmentObject var appState: AppState

    @State private var challenges: [WeeklyChallenge] = WeeklyChallenge.preview
    @State private var selectedChallenge: WeeklyChallenge?

    private var completedCount: Int {
        challenges.filter { $0.isComplete }.count
    }

    private var totalXP: Int {
        challenges.filter { $0.isComplete }.reduce(0) { $0 + $1.reward.xpPoints }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header with progress
            challengeHeader

            // Challenge Cards
            VStack(spacing: 14) {
                ForEach(challenges) { challenge in
                    ChallengeCard(challenge: challenge)
                        .onTapGesture {
                            selectedChallenge = challenge
                        }
                }
            }
        }
        .sheet(item: $selectedChallenge) { challenge in
            ChallengeDetailSheet(challenge: challenge)
        }
    }

    private var challengeHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Challenges")
                        .font(FLEKKSFonts.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text("\(challenges.first?.daysRemaining ?? 0) days remaining")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                // XP Badge
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.flekksOrange)

                    Text("\(totalXP) XP")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.flekksOrange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.flekksOrange.opacity(0.15))
                .clipShape(Capsule())
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
                            .frame(width: geometry.size.width * (Double(completedCount) / Double(challenges.count)), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(completedCount)/\(challenges.count) completed")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    if completedCount == challenges.count {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                            Text("All complete!")
                        }
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.accent)
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

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: WeeklyChallenge

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(challenge.isComplete ? FLEKKSGradients.avatarGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                    .frame(width: 50, height: 50)

                if challenge.isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.bgPrimary)
                } else {
                    Image(systemName: challenge.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(FLEKKSGradients.iconGradient)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(challenge.title)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(challenge.isComplete ? .textSecondary : .textPrimary)

                    if challenge.isComplete {
                        Text("✓")
                            .font(FLEKKSFonts.labelMedium)
                            .foregroundColor(.accent)
                    }
                }

                Text(challenge.description)
                    .font(FLEKKSFonts.body(13))
                    .foregroundColor(.textMuted)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.bgElevated)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(challenge.isComplete ? Color.accent : FLEKKSGradients.progressGradient)
                            .frame(width: geometry.size.width * challenge.progress, height: 6)
                    }
                }
                .frame(height: 6)
            }

            Spacer()

            // Progress text
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(challenge.current)/\(challenge.target)")
                    .font(FLEKKSFonts.bodySemibold(14))
                    .foregroundColor(challenge.isComplete ? .accent : .textPrimary)

                // Reward preview
                HStack(spacing: 4) {
                    Text(challenge.reward.badgeIcon)
                        .font(.system(size: 14))
                    Text("+\(challenge.reward.xpPoints)")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.flekksOrange)
                }
            }
        }
        .padding(16)
        .background(challenge.isComplete ? Color.accentGlow : Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    challenge.isComplete ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Challenge Detail Sheet
struct ChallengeDetailSheet: View {
    let challenge: WeeklyChallenge
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Challenge Icon
                        ZStack {
                            Circle()
                                .fill(FLEKKSGradients.tealGlow)
                                .frame(width: 150, height: 150)
                                .blur(radius: 40)

                            Circle()
                                .fill(challenge.isComplete ? FLEKKSGradients.avatarGradient : LinearGradient(colors: [Color.bgCard], startPoint: .top, endPoint: .bottom))
                                .frame(width: 100, height: 100)

                            if challenge.isComplete {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundColor(.bgPrimary)
                            } else {
                                Image(systemName: challenge.icon)
                                    .font(.system(size: 40))
                                    .foregroundStyle(FLEKKSGradients.iconGradient)
                            }
                        }

                        // Title and description
                        VStack(spacing: 8) {
                            Text(challenge.title)
                                .font(FLEKKSFonts.heading(24))
                                .foregroundColor(.textPrimary)

                            Text(challenge.description)
                                .font(FLEKKSFonts.body(16))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        // Progress
                        VStack(spacing: 12) {
                            Text("\(challenge.current) / \(challenge.target)")
                                .font(FLEKKSFonts.headingHeavy(36))
                                .foregroundColor(.textPrimary)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.bgElevated)
                                        .frame(height: 12)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(FLEKKSGradients.accentGradientVibrant)
                                        .frame(width: geometry.size.width * challenge.progress, height: 12)
                                }
                            }
                            .frame(height: 12)
                            .padding(.horizontal, 40)

                            Text("\(Int(challenge.progress * 100))% complete")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)
                        }

                        // Reward Card
                        VStack(spacing: 14) {
                            Text("Reward")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            HStack(spacing: 20) {
                                // Badge
                                VStack(spacing: 8) {
                                    Text(challenge.reward.badgeIcon)
                                        .font(.system(size: 40))

                                    Text(challenge.reward.badgeName)
                                        .font(FLEKKSFonts.bodySemibold(14))
                                        .foregroundColor(.textPrimary)
                                }

                                // XP
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.flekksOrange.opacity(0.15))
                                            .frame(width: 56, height: 56)

                                        Image(systemName: "star.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.flekksOrange)
                                    }

                                    Text("+\(challenge.reward.xpPoints) XP")
                                        .font(FLEKKSFonts.bodySemibold(14))
                                        .foregroundColor(.flekksOrange)
                                }
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // Time remaining
                        if !challenge.isComplete {
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                Text("\(challenge.daysRemaining) days remaining")
                                    .font(FLEKKSFonts.bodyMedium(14))
                            }
                            .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
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

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()

        ScrollView {
            WeeklyChallengesView()
                .padding(.horizontal, 20)
                .environmentObject(AppState())
        }
    }
}
