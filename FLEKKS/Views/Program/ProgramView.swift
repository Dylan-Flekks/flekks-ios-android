import SwiftUI

struct ProgramView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared

    @State private var selectedWeek: Int = 1

    private var program: Program? {
        dataService.currentProgram
    }

    private var weekSessions: [Session] {
        dataService.sessions.filter { $0.weekNumber == selectedWeek }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero header
                ZStack(alignment: .bottomLeading) {
                    heroGradient
                        .frame(height: 200)

                    // Teal glow
                    Circle()
                        .fill(FLEKKSGradients.tealGlow)
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: 100, y: -50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT PROGRAM")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundStyle(FLEKKSGradients.accentGradient)
                            .tracking(1.5)

                        Text(program?.name ?? "Select a Program")
                            .font(FLEKKSFonts.heading(32))
                            .foregroundColor(.textPrimary)

                        if let coach = program?.coach {
                            Text("with \(coach.name)")
                                .font(FLEKKSFonts.body(14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(24)
                }

                VStack(spacing: 24) {
                    // Progress card
                    if let program = program {
                        ProgressCard(program: program, dataService: dataService)
                    }

                    // Week selector
                    if let program = program {
                        WeekSelector(
                            weekCount: program.weekCount,
                            selectedWeek: $selectedWeek,
                            currentWeek: program.currentWeek
                        )
                    }

                    // Week section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Week \(selectedWeek)")
                                .font(FLEKKSFonts.heading(16))
                                .foregroundColor(.textPrimary)
                            Spacer()

                            if selectedWeek == program?.currentWeek {
                                Text("IN PROGRESS")
                                    .font(FLEKKSFonts.labelSmall)
                                    .foregroundStyle(FLEKKSGradients.accentGradient)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Color.accentGlowStrong)
                                    .clipShape(Capsule())
                            }
                        }

                        // Session list
                        if weekSessions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 40))
                                    .foregroundStyle(FLEKKSGradients.iconGradient)
                                Text("Sessions coming soon")
                                    .font(FLEKKSFonts.bodyMedium(14))
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(weekSessions) { session in
                                    SessionRow(
                                        session: session,
                                        isSaved: appState.savedSessions.contains(session.id),
                                        isScheduled: appState.scheduledSessions[session.id] != nil,
                                        onTap: {
                                            appState.viewSessionDetail(session)
                                        },
                                        onQuickStart: {
                                            appState.startSession(session)
                                        },
                                        onSave: {
                                            appState.toggleSaveSession(session.id)
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
        .background(Color.bgPrimary)
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            if let program = program {
                selectedWeek = program.currentWeek
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

    private var heroGradient: LinearGradient {
        if let team = appState.selectedTeam {
            switch team.heroGradient {
            case .green: return FLEKKSGradients.heroGreen
            case .purple: return FLEKKSGradients.heroPurple
            case .blue: return FLEKKSGradients.heroBlue
            }
        }
        return FLEKKSGradients.heroGreen
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let program: Program
    let dataService: DataService

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Your Progress")
                    .font(FLEKKSFonts.bodySemibold(14))
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(Int(dataService.progressPercentage * 100))%")
                    .font(FLEKKSFonts.headingHeavy(17))
                    .foregroundStyle(FLEKKSGradients.accentGradient)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.bgElevated)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(FLEKKSGradients.accentGradientVibrant)
                        .frame(width: geometry.size.width * dataService.progressPercentage, height: 8)
                }
            }
            .frame(height: 8)

            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(FLEKKSGradients.iconGradient)
                    Text("Week \(program.currentWeek) of \(program.weekCount)")
                }
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(FLEKKSGradients.iconGradient)
                    Text("\(dataService.completedSessionsCount) sessions done")
                }
            }
            .font(FLEKKSFonts.body(12))
            .foregroundColor(.textSecondary)
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

// MARK: - Week Selector
struct WeekSelector: View {
    let weekCount: Int
    @Binding var selectedWeek: Int
    let currentWeek: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(1...weekCount, id: \.self) { week in
                    WeekButton(
                        week: week,
                        isSelected: week == selectedWeek,
                        isCurrent: week == currentWeek,
                        isCompleted: week < currentWeek
                    ) {
                        selectedWeek = week
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct WeekButton: View {
    let week: Int
    let isSelected: Bool
    let isCurrent: Bool
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("Week")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(isSelected ? .bgPrimary : .textMuted)
                Text("\(week)")
                    .font(FLEKKSFonts.headingHeavy(18))
                    .foregroundColor(isSelected ? .bgPrimary : .textPrimary)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? .bgPrimary : .accent)
                } else if isCurrent {
                    Circle()
                        .fill(isSelected ? Color.bgPrimary : Color.accent)
                        .frame(width: 6, height: 6)
                } else {
                    Color.clear.frame(height: 10)
                }
            }
            .frame(width: 60, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? FLEKKSGradients.buttonGradient : Color.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.clear : (isCurrent ? FLEKKSGradients.borderGradient : LinearGradient(colors: [.border], startPoint: .top, endPoint: .bottom)),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: Session
    var isSaved: Bool = false
    var isScheduled: Bool = false
    let onTap: () -> Void
    var onQuickStart: (() -> Void)? = nil
    var onSave: (() -> Void)? = nil

    @State private var showActions = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    // Day number badge
                    ZStack {
                        Circle()
                            .fill(session.isCompleted ? FLEKKSGradients.avatarGradient : Color.bgElevated)
                            .frame(width: 44, height: 44)

                        if session.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.bgPrimary)
                        } else {
                            VStack(spacing: 0) {
                                Text("DAY")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.textMuted)
                                Text("\(session.dayNumber)")
                                    .font(FLEKKSFonts.headingHeavy(16))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(session.title)
                                .font(FLEKKSFonts.bodySemibold(15))
                                .foregroundColor(session.isCompleted ? .textMuted : .textPrimary)
                                .lineLimit(1)

                            if isSaved {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.accent)
                            }

                            if isScheduled {
                                Image(systemName: "calendar.badge.checkmark")
                                    .font(.system(size: 10))
                                    .foregroundColor(.flekksOrange)
                            }
                        }

                        HStack(spacing: 8) {
                            Text(session.focusArea)
                                .font(FLEKKSFonts.body(12))
                                .foregroundColor(.textSecondary)

                            Text("•")
                                .foregroundColor(.textMuted)

                            Text("\(session.durationMinutes) min")
                                .font(FLEKKSFonts.body(12))
                                .foregroundColor(.textMuted)
                        }
                    }

                    Spacer()

                    // Action buttons
                    HStack(spacing: 8) {
                        // Save button
                        if let onSave = onSave {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    onSave()
                                }
                            }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(isSaved ? .accent : .textMuted)
                                    .frame(width: 36, height: 36)
                                    .background(Color.bgElevated)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        // Play/Start button
                        if !session.isCompleted {
                            if let onQuickStart = onQuickStart {
                                Button(action: onQuickStart) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.bgPrimary)
                                        .frame(width: 40, height: 40)
                                        .background(FLEKKSGradients.buttonGradient)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.textMuted)
                            }
                        } else {
                            // Completed indicator
                            Text("Done")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.accentGlowStrong)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        session.isCompleted ? Color.border : FLEKKSGradients.borderGradientSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProgramView()
        .environmentObject(AppState())
}
