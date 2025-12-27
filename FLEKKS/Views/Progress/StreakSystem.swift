import SwiftUI

// MARK: - Streak Model
struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var streakFreezes: Int
    var freezesUsedThisMonth: Int
    var totalSessionsCompleted: Int
    var streakHistory: [StreakDay]
    var streakAtRisk: Bool

    struct StreakDay: Identifiable, Codable {
        let id: UUID
        let date: Date
        let completed: Bool
        let froze: Bool
        let sessionsCount: Int
    }

    var isStreakAtRisk: Bool {
        guard let lastDate = lastActivityDate else { return false }
        let hoursSinceLastActivity = Date().timeIntervalSince(lastDate) / 3600
        return hoursSinceLastActivity > 20 && hoursSinceLastActivity < 24
    }

    var hoursUntilStreakLoss: Int? {
        guard let lastDate = lastActivityDate else { return nil }
        let hoursSinceLast = Date().timeIntervalSince(lastDate) / 3600
        let hoursRemaining = 24 - hoursSinceLast
        return hoursRemaining > 0 ? Int(hoursRemaining) : nil
    }

    static let preview = StreakData(
        currentStreak: 15,
        longestStreak: 23,
        lastActivityDate: Date().addingTimeInterval(-3600 * 20),
        streakFreezes: 2,
        freezesUsedThisMonth: 0,
        totalSessionsCompleted: 47,
        streakHistory: generatePreviewHistory(),
        streakAtRisk: true
    )

    static func generatePreviewHistory() -> [StreakDay] {
        var days: [StreakDay] = []
        for i in 0..<30 {
            let date = Date().addingTimeInterval(-86400 * Double(29 - i))
            let completed = i > 14 || Bool.random()
            days.append(StreakDay(
                id: UUID(),
                date: date,
                completed: completed,
                froze: !completed && i > 10 && Bool.random(),
                sessionsCount: completed ? Int.random(in: 1...3) : 0
            ))
        }
        return days
    }
}

// MARK: - Streak View
struct StreakView: View {
    @EnvironmentObject var appState: AppState
    @State private var streakData: StreakData = StreakData.preview
    @State private var showFreezeConfirmation = false
    @State private var showRecoverySheet = false
    @State private var selectedWeek = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Streak Hero
                streakHero

                // Streak at Risk Alert
                if streakData.isStreakAtRisk {
                    streakAtRiskAlert
                }

                // Streak Calendar
                streakCalendar

                // Streak Stats
                streakStats

                // Streak Freeze Section
                streakFreezeSection

                // Streak Milestones
                streakMilestones
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .background(Color.bgPrimary)
        .sheet(isPresented: $showFreezeConfirmation) {
            StreakFreezeSheet(
                streakData: $streakData,
                onFreeze: freezeStreak
            )
        }
        .sheet(isPresented: $showRecoverySheet) {
            StreakRecoverySheet(
                lostStreak: streakData.longestStreak,
                onRecover: recoverStreak
            )
        }
    }

    private var streakHero: some View {
        VStack(spacing: 20) {
            // Flame animation
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.flekksOrange.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)

                // Fire ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.flekksOrange, .flekksRed],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 140, height: 140)

                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.flekksOrange.opacity(0.2), Color.flekksOrange.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 130, height: 130)

                // Streak number
                VStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 36))

                    Text("\(streakData.currentStreak)")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.textPrimary)

                    Text("day streak")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            // Status message
            if streakData.isStreakAtRisk, let hours = streakData.hoursUntilStreakLoss {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.flekksOrange)

                    Text("\(hours) hours to keep your streak!")
                        .font(FLEKKSFonts.bodyMedium(14))
                        .foregroundColor(.flekksOrange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.flekksOrange.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(24)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    streakData.isStreakAtRisk ?
                    LinearGradient(colors: [Color.flekksOrange.opacity(0.5), Color.flekksRed.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        FLEKKSGradients.borderGradientSubtle,
                    lineWidth: streakData.isStreakAtRisk ? 2 : 1
                )
        )
    }

    private var streakAtRiskAlert: some View {
        Button(action: { /* Navigate to quick session */ }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.flekksOrange)
                        .frame(width: 44, height: 44)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak at Risk!")
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)

                    Text("Complete a quick 5-min session to save it")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textMuted)
            }
            .padding(16)
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
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.flekksOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var streakCalendar: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity")
                    .font(FLEKKSFonts.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                // Week navigation
                HStack(spacing: 16) {
                    Button(action: { selectedWeek = max(0, selectedWeek - 1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }

                    Text("This Week")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textSecondary)

                    Button(action: { selectedWeek = min(3, selectedWeek + 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }
                }
            }

            // Week view
            HStack(spacing: 8) {
                ForEach(0..<7) { dayIndex in
                    let dayOffset = selectedWeek * 7 + dayIndex
                    if dayOffset < streakData.streakHistory.count {
                        let day = streakData.streakHistory[streakData.streakHistory.count - 1 - dayOffset]
                        StreakDayCell(day: day)
                    }
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

    private var streakStats: some View {
        HStack(spacing: 12) {
            StreakStatBox(
                value: "\(streakData.currentStreak)",
                label: "Current",
                icon: "flame.fill",
                color: .flekksOrange
            )

            StreakStatBox(
                value: "\(streakData.longestStreak)",
                label: "Longest",
                icon: "trophy.fill",
                color: .accent
            )

            StreakStatBox(
                value: "\(streakData.totalSessionsCompleted)",
                label: "Sessions",
                icon: "checkmark.circle.fill",
                color: .tealBright
            )
        }
    }

    private var streakFreezeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Streak Freeze")
                    .font(FLEKKSFonts.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                // Premium badge
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text("PREMIUM")
                        .font(FLEKKSFonts.labelSmall)
                }
                .foregroundColor(.flekksOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.flekksOrange.opacity(0.15))
                .clipShape(Capsule())
            }

            Text("Protect your streak when life gets in the way. Use a freeze to skip a day without losing your progress.")
                .font(FLEKKSFonts.body(14))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)

            // Freeze tokens
            HStack(spacing: 16) {
                // Available freezes
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(0..<2) { i in
                            Image(systemName: i < streakData.streakFreezes ? "snowflake" : "snowflake")
                                .font(.system(size: 24))
                                .foregroundColor(i < streakData.streakFreezes ? .accent : .textMuted.opacity(0.3))
                        }
                    }

                    Text("\(streakData.streakFreezes) available")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Use freeze button
                Button(action: { showFreezeConfirmation = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accent)

                        Text("Use Freeze")
                            .font(FLEKKSFonts.labelMedium)
                            .foregroundColor(.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentGlow)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.accent.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(streakData.streakFreezes == 0)
                .opacity(streakData.streakFreezes == 0 ? 0.5 : 1)
            }

            // Monthly reset info
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                Text("Freezes reset on the 1st of each month")
                    .font(FLEKKSFonts.labelSmall)
            }
            .foregroundColor(.textMuted)
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private var streakMilestones: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streak Milestones")
                .font(FLEKKSFonts.titleSmall)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                StreakMilestoneRow(days: 7, title: "Week Warrior", isAchieved: streakData.currentStreak >= 7)
                StreakMilestoneRow(days: 14, title: "Two Week Titan", isAchieved: streakData.currentStreak >= 14)
                StreakMilestoneRow(days: 30, title: "Monthly Master", isAchieved: streakData.currentStreak >= 30)
                StreakMilestoneRow(days: 100, title: "Centurion", isAchieved: streakData.currentStreak >= 100)
                StreakMilestoneRow(days: 365, title: "Year of Flexibility", isAchieved: streakData.currentStreak >= 365)
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

    private func freezeStreak() {
        if streakData.streakFreezes > 0 {
            streakData.streakFreezes -= 1
            streakData.freezesUsedThisMonth += 1
        }
    }

    private func recoverStreak() {
        // Would handle streak recovery logic
        showRecoverySheet = false
    }
}

// MARK: - Streak Day Cell
struct StreakDayCell: View {
    let day: StreakData.StreakDay

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: day.date).prefix(1))
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day.date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(day.date)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayOfWeek)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)

            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)

                if day.completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.bgPrimary)
                } else if day.froze {
                    Image(systemName: "snowflake")
                        .font(.system(size: 14))
                        .foregroundColor(.accent)
                } else {
                    Text(dayNumber)
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(isToday ? .accent : .textMuted)
                }
            }
            .overlay(
                Circle()
                    .stroke(isToday ? Color.accent : Color.clear, lineWidth: 2)
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var backgroundColor: Color {
        if day.completed {
            return .accent
        } else if day.froze {
            return .accent.opacity(0.2)
        } else {
            return .bgElevated
        }
    }
}

// MARK: - Streak Stat Box
struct StreakStatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(FLEKKSFonts.headingHeavy(24))
                .foregroundColor(.textPrimary)

            Text(label)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)
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
}

// MARK: - Streak Milestone Row
struct StreakMilestoneRow: View {
    let days: Int
    let title: String
    let isAchieved: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isAchieved ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 44)

                if isAchieved {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.bgPrimary)
                } else {
                    Text("\(days)")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FLEKKSFonts.bodySemibold(14))
                    .foregroundColor(isAchieved ? .textPrimary : .textSecondary)

                Text("\(days) day streak")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }

            Spacer()

            if isAchieved {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.flekksOrange)
            }
        }
        .padding(12)
        .background(isAchieved ? Color.accentGlow : Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Streak Freeze Sheet
struct StreakFreezeSheet: View {
    @Binding var streakData: StreakData
    let onFreeze: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(FLEKKSGradients.tealGlow)
                            .frame(width: 150, height: 150)
                            .blur(radius: 50)

                        Circle()
                            .fill(Color.bgCard)
                            .frame(width: 100, height: 100)

                        Image(systemName: "snowflake")
                            .font(.system(size: 44))
                            .foregroundColor(.accent)
                    }

                    VStack(spacing: 12) {
                        Text("Use Streak Freeze?")
                            .font(FLEKKSFonts.heading(24))
                            .foregroundColor(.textPrimary)

                        Text("This will protect your \(streakData.currentStreak)-day streak for today. You have \(streakData.streakFreezes) freeze\(streakData.streakFreezes == 1 ? "" : "s") remaining.")
                            .font(FLEKKSFonts.body(15))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: {
                            onFreeze()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "snowflake")
                                Text("Use Freeze")
                            }
                            .font(FLEKKSFonts.bodySemibold(16))
                        }
                        .buttonStyle(TealGlowButtonStyle())

                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(FLEKKSFonts.bodyMedium(14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.accent)
                }
            }
        }
    }
}

// MARK: - Streak Recovery Sheet
struct StreakRecoverySheet: View {
    let lostStreak: Int
    let onRecover: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Sad flame
                    ZStack {
                        Circle()
                            .fill(Color.flekksOrange.opacity(0.1))
                            .frame(width: 150, height: 150)

                        Text("😢")
                            .font(.system(size: 60))
                    }

                    VStack(spacing: 12) {
                        Text("Streak Lost")
                            .font(FLEKKSFonts.heading(24))
                            .foregroundColor(.textPrimary)

                        Text("Your \(lostStreak)-day streak has ended. But don't worry - you can recover it!")
                            .font(FLEKKSFonts.body(15))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    // Recovery options
                    VStack(spacing: 16) {
                        RecoveryOptionCard(
                            icon: "play.fill",
                            title: "Complete a Session",
                            subtitle: "Start a new streak today",
                            isPrimary: true,
                            action: { dismiss() }
                        )

                        RecoveryOptionCard(
                            icon: "flame.fill",
                            title: "Restore Streak",
                            subtitle: "Use 500 XP to recover",
                            isPrimary: false,
                            action: onRecover
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Text("Start Fresh")
                            .font(FLEKKSFonts.bodyMedium(14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecoveryOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isPrimary ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isPrimary ? .bgPrimary : .flekksOrange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)

                    Text(subtitle)
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textMuted)
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isPrimary ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle, lineWidth: isPrimary ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak Alert Banner (for use in other views)
struct StreakAlertBanner: View {
    let hoursRemaining: Int
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text("🔥")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep your streak alive!")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.textPrimary)

                    Text("\(hoursRemaining)h remaining")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.flekksOrange)
                }

                Spacer()

                Text("Train Now")
                    .font(FLEKKSFonts.bodySemibold(13))
                    .foregroundColor(.bgPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(FLEKKSGradients.buttonGradient)
                    .clipShape(Capsule())
            }
            .padding(14)
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.flekksOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StreakView()
        .environmentObject(AppState())
}
