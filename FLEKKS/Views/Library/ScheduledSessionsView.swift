import SwiftUI

struct ScheduledSessionsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared
    @Environment(\.dismiss) private var dismiss

    private var scheduledSessionsList: [(session: Session, date: Date)] {
        appState.scheduledSessions.compactMap { (sessionId, date) in
            if let session = dataService.sessions.first(where: { $0.id == sessionId }) {
                return (session, date)
            }
            return nil
        }.sorted { $0.date < $1.date }
    }

    private var upcomingSessions: [(session: Session, date: Date)] {
        scheduledSessionsList.filter { $0.date > Date() }
    }

    private var pastSessions: [(session: Session, date: Date)] {
        scheduledSessionsList.filter { $0.date <= Date() }
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if scheduledSessionsList.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Upcoming Sessions
                        if !upcomingSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Upcoming")
                                    .font(FLEKKSFonts.titleSmall)
                                    .foregroundColor(.textPrimary)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(upcomingSessions, id: \.session.id) { item in
                                        ScheduledSessionCard(
                                            session: item.session,
                                            scheduledDate: item.date,
                                            coach: getCoach(for: item.session),
                                            onTap: {
                                                appState.viewSessionDetail(item.session)
                                            },
                                            onStart: {
                                                appState.startSession(item.session)
                                            },
                                            onReschedule: {
                                                appState.viewSessionDetail(item.session)
                                            },
                                            onRemove: {
                                                withAnimation {
                                                    appState.unscheduleSession(item.session.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Past Scheduled (missed)
                        if !pastSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Missed")
                                        .font(FLEKKSFonts.titleSmall)
                                        .foregroundColor(.textPrimary)

                                    Spacer()

                                    Button("Clear All") {
                                        withAnimation {
                                            for item in pastSessions {
                                                appState.unscheduleSession(item.session.id)
                                            }
                                        }
                                    }
                                    .font(FLEKKSFonts.labelMedium)
                                    .foregroundColor(.flekksRed)
                                }
                                .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(pastSessions, id: \.session.id) { item in
                                        ScheduledSessionCard(
                                            session: item.session,
                                            scheduledDate: item.date,
                                            coach: getCoach(for: item.session),
                                            isPast: true,
                                            onTap: {
                                                appState.viewSessionDetail(item.session)
                                            },
                                            onStart: {
                                                appState.startSession(item.session)
                                            },
                                            onReschedule: {
                                                appState.viewSessionDetail(item.session)
                                            },
                                            onRemove: {
                                                withAnimation {
                                                    appState.unscheduleSession(item.session.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Scheduled")
        .navigationBarTitleDisplayMode(.large)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(FLEKKSGradients.tealGlow)
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)

                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundStyle(FLEKKSGradients.iconGradient)
            }

            Text("No Scheduled Sessions")
                .font(FLEKKSFonts.heading(24))
                .foregroundColor(.textPrimary)

            Text("Schedule sessions to plan your flexibility training ahead of time")
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { dismiss() }) {
                Text("Browse Sessions")
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.horizontal, 60)
            .padding(.top, 10)
        }
    }

    private func getCoach(for session: Session) -> Coach? {
        if let team = dataService.teams.first(where: { $0.id == session.teamId }) {
            return team.coach
        }
        return nil
    }
}

// MARK: - Scheduled Session Card
struct ScheduledSessionCard: View {
    let session: Session
    let scheduledDate: Date
    let coach: Coach?
    var isPast: Bool = false
    let onTap: () -> Void
    let onStart: () -> Void
    let onReschedule: () -> Void
    let onRemove: () -> Void

    private var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(scheduledDate) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if Calendar.current.isDateInTomorrow(scheduledDate) {
            formatter.dateFormat = "'Tomorrow at' h:mm a"
        } else {
            formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        }
        return formatter.string(from: scheduledDate)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Date Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: isPast ? "clock.badge.exclamationmark" : "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(isPast ? .flekksRed : (isToday ? .accent : .textMuted))

                        Text(formattedDate)
                            .font(FLEKKSFonts.labelMedium)
                            .foregroundColor(isPast ? .flekksRed : (isToday ? .accent : .textSecondary))
                    }

                    Spacer()

                    if isPast {
                        Text("MISSED")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.flekksRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.flekksRed.opacity(0.15))
                            .clipShape(Capsule())
                    } else if isToday {
                        Text("TODAY")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentGlowStrong)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isPast ? Color.flekksRed.opacity(0.05) : (isToday ? Color.accentGlow : Color.bgElevated))

                // Session Info
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.bgElevated)
                            .frame(width: 50, height: 50)

                        Text(iconForFocusArea(session.focusArea))
                            .font(.system(size: 24))
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.title)
                            .font(FLEKKSFonts.bodySemibold(15))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            Text("\(session.durationMinutes) min")
                            Text("•")
                            Text(session.focusArea)
                        }
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                    }

                    Spacer()

                    // Actions
                    HStack(spacing: 8) {
                        if !isPast {
                            Button(action: onStart) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.bgPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(FLEKKSGradients.buttonGradient)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button(action: onReschedule) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 14))
                                    .foregroundColor(.accent)
                                    .frame(width: 36, height: 36)
                                    .background(Color.accentGlowStrong)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        Button(action: onRemove) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.textMuted)
                                .frame(width: 28, height: 28)
                                .background(Color.bgElevated)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(14)
            }
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isPast ? Color.flekksRed.opacity(0.3) :
                            (isToday ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle),
                        lineWidth: 1
                    )
            )
            .opacity(isPast ? 0.8 : 1)
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
}

#Preview {
    NavigationView {
        ScheduledSessionsView()
            .environmentObject(AppState())
    }
}
