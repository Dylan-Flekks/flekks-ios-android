import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private var userName: String {
        appState.currentUser?.name.components(separatedBy: " ").first ?? "there"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(FLEKKSFonts.bodyMedium(14))
                            .foregroundColor(.textMuted)
                        Text(userName)
                            .font(FLEKKSFonts.heading(28))
                            .foregroundColor(.textPrimary)
                    }

                    Spacer()

                    // Streak badge with gradient
                    Button(action: {
                        appState.navigateToTab(.progress)
                    }) {
                        HStack(spacing: 6) {
                            Text("🔥")
                                .font(.system(size: 18))
                            Text("\(appState.currentStreak)")
                                .font(FLEKKSFonts.headingHeavy(18))
                                .foregroundStyle(FLEKKSGradients.streakGradient)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 28)

                // Today's Session Card
                if let session = dataService.todaySession {
                    TodaySessionCard(
                        session: session,
                        coach: dataService.currentProgram?.coach,
                        isSaved: appState.savedSessions.contains(session.id),
                        onTap: {
                            appState.viewSessionDetail(session)
                        },
                        onStart: {
                            appState.startSession(session)
                        },
                        onSave: {
                            appState.toggleSaveSession(session.id)
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }

                // This Week section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("This Week")
                            .font(FLEKKSFonts.titleSmall)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Button("View All") {
                            appState.navigateToTab(.program)
                        }
                        .font(FLEKKSFonts.labelLarge)
                        .foregroundStyle(FLEKKSGradients.accentGradient)
                    }

                    // Week days
                    WeekProgressView(sessions: dataService.sessions)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                // Current Program Progress
                if let program = dataService.currentProgram {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your Program")
                            .font(FLEKKSFonts.titleSmall)
                            .foregroundColor(.textPrimary)

                        ProgramProgressCard(program: program) {
                            appState.navigateToTab(.program)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }

                // Team Chat Preview
                if let team = appState.selectedTeam {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Team Chat")
                            .font(FLEKKSFonts.titleSmall)
                            .foregroundColor(.textPrimary)

                        TeamChatPreviewCard(team: team) {
                            appState.navigateToTab(.team)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.bgPrimary)
        .onAppear {
            if let team = appState.selectedTeam {
                Task {
                    await dataService.fetchPrograms(teamId: team.id)
                    if let program = dataService.currentProgram {
                        await dataService.fetchSessions(programId: program.id)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $appState.showSessionDetail) {
            if let session = appState.selectedSessionForDetail {
                NavigationView {
                    SessionDetailView(
                        session: session,
                        coach: dataService.currentProgram?.coach ?? appState.selectedTeam?.coach
                    )
                    .environmentObject(appState)
                }
            }
        }
    }
}

// MARK: - Today's Session Card
struct TodaySessionCard: View {
    let session: Session
    let coach: Coach?
    var isSaved: Bool = false
    var onTap: (() -> Void)? = nil
    let onStart: () -> Void
    var onSave: (() -> Void)? = nil

    @State private var isGlowing = false

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 0) {
                // Hero with enhanced gradient
                ZStack {
                    // Base gradient
                    FLEKKSGradients.heroTealVibrant
                        .frame(height: 140)

                    // Multiple glow layers
                    Circle()
                        .fill(FLEKKSGradients.tealGlowIntense)
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(y: 20)
                        .scaleEffect(isGlowing ? 1.1 : 1.0)
                        .opacity(isGlowing ? 0.9 : 0.6)

                    // Session icon based on focus area
                    Text(iconForFocusArea(session.focusArea))
                        .font(.system(size: 56))
                        .scaleEffect(isGlowing ? 1.05 : 1.0)

                    // Top right action buttons
                    VStack {
                        HStack {
                            Spacer()

                            // Save button
                            if let onSave = onSave {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        onSave()
                                    }
                                }) {
                                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(isSaved ? .accent : .white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.black.opacity(0.4))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)

                        Spacer()
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        isGlowing = true
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("TODAY'S SESSION")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundStyle(FLEKKSGradients.accentGradient)
                            .tracking(1.5)

                        Spacer()

                        if session.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("COMPLETED")
                                    .font(FLEKKSFonts.labelSmall)
                            }
                            .foregroundColor(.accent)
                        }
                    }

                    Text(session.title)
                        .font(FLEKKSFonts.heading(22))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)

                    if let coach = coach {
                        Text("with \(coach.name)")
                            .font(FLEKKSFonts.bodyMedium(14))
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, 8)
                    }

                    // Meta info with gradient icons
                    HStack(spacing: 12) {
                        MetaTag(icon: "clock", text: "\(session.durationMinutes) min")
                        MetaTag(icon: "flame", text: intensityForDuration(session.durationMinutes))
                        MetaTag(icon: "target", text: session.focusArea)
                    }
                    .padding(.bottom, 16)

                    // Action buttons row
                    HStack(spacing: 12) {
                        Button(action: onStart) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Start Session")
                                    .font(FLEKKSFonts.bodySemibold(15))
                            }
                        }
                        .buttonStyle(TealGlowButtonStyle())

                        // View Details Button
                        Button(action: { onTap?() }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .frame(width: 52, height: 52)
                                .background(Color.bgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForFocusArea(_ area: String) -> String {
        switch area.lowercased() {
        case let a where a.contains("hip"): return "🦵"
        case let a where a.contains("back") || a.contains("spine"): return "🧘"
        case let a where a.contains("core"): return "💪"
        case let a where a.contains("shoulder"): return "🙆"
        case let a where a.contains("hamstring"): return "🏃"
        case let a where a.contains("pike"): return "🤸"
        default: return "✨"
        }
    }

    private func intensityForDuration(_ minutes: Int) -> String {
        switch minutes {
        case ..<15: return "Light"
        case 15..<25: return "Moderate"
        default: return "Intense"
        }
    }
}

// MARK: - Meta Tag
struct MetaTag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(FLEKKSGradients.iconGradient)
            Text(text)
                .font(FLEKKSFonts.labelMedium)
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Week Progress View
struct WeekProgressView: View {
    let sessions: [Session]

    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]

    private var currentDayOfWeek: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Convert Sunday = 1 to Monday = 0 format
        return weekday == 1 ? 6 : weekday - 2
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                let dayNumber = Calendar.current.component(.day, from: Date().addingTimeInterval(Double((index - currentDayOfWeek) * 86400)))
                let isCompleted = index < sessions.filter({ $0.isCompleted }).count

                WeekDayCard(
                    dayName: weekDays[index],
                    dayNumber: dayNumber,
                    isToday: index == currentDayOfWeek,
                    isCompleted: isCompleted
                )
            }
        }
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
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)

            Text("\(dayNumber)")
                .font(FLEKKSFonts.bodyBold(16))
                .foregroundColor(.textPrimary)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(FLEKKSGradients.accentGradient)
            } else {
                Color.clear
                    .frame(height: 14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isToday ? Color.accentGlowStrong : Color.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isToday ? FLEKKSGradients.borderGradient : LinearGradient(colors: [Color.border], startPoint: .top, endPoint: .bottom),
                    lineWidth: isToday ? 1.5 : 1
                )
        )
    }
}

// MARK: - Program Progress Card
struct ProgramProgressCard: View {
    let program: Program
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(program.name)
                            .font(FLEKKSFonts.bodySemibold(16))
                            .foregroundColor(.textPrimary)

                        if let coach = program.coach {
                            Text("with \(coach.name)")
                                .font(FLEKKSFonts.body(13))
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Spacer()

                    Text("Week \(program.currentWeek)")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundStyle(FLEKKSGradients.accentGradient)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGlowStrong)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Progress bar
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.bgElevated)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(FLEKKSGradients.accentGradientVibrant)
                                .frame(width: geometry.size.width * program.progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(program.completedSessions)/\(program.totalSessions) sessions")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                        Spacer()
                        Text("\(Int(program.progressPercentage * 100))%")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundStyle(FLEKKSGradients.accentGradient)
                    }
                }
            }
            .padding(18)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Team Chat Preview Card
struct TeamChatPreviewCard: View {
    let team: Team
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar stack with gradient
                HStack(spacing: -10) {
                    ForEach(["DP", "SM", "MR"], id: \.self) { initials in
                        ZStack {
                            Circle()
                                .fill(FLEKKSGradients.avatarGradient)
                                .frame(width: 32, height: 32)
                            Text(initials)
                                .font(FLEKKSFonts.labelSmall)
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
                        Text("+\(max(0, team.memberCount - 3))")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textSecondary)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.bgCard, lineWidth: 2)
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.textPrimary)
                    Text("Sarah: Just finished Day 5! 🎉")
                        .font(FLEKKSFonts.body(12))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Unread badge
                Text("3")
                    .font(FLEKKSFonts.labelSmall)
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
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
