import SwiftUI

struct SavedSessionsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared
    @Environment(\.dismiss) private var dismiss

    private var savedSessionsList: [Session] {
        dataService.sessions.filter { appState.savedSessions.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if savedSessionsList.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Stats
                        HStack(spacing: 20) {
                            StatBox(
                                value: "\(savedSessionsList.count)",
                                label: "Saved",
                                icon: "bookmark.fill"
                            )
                            StatBox(
                                value: "\(totalMinutes)",
                                label: "Total Min",
                                icon: "clock.fill"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // Sessions List
                        VStack(spacing: 12) {
                            ForEach(savedSessionsList) { session in
                                SavedSessionCard(
                                    session: session,
                                    coach: getCoach(for: session),
                                    onTap: {
                                        appState.viewSessionDetail(session)
                                    },
                                    onStart: {
                                        appState.startSession(session)
                                    },
                                    onRemove: {
                                        withAnimation {
                                            appState.toggleSaveSession(session.id)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationTitle("Saved Sessions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !savedSessionsList.isEmpty {
                    Menu {
                        Button(role: .destructive) {
                            withAnimation {
                                appState.savedSessions.removeAll()
                            }
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.accent)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(FLEKKSGradients.tealGlow)
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)

                Image(systemName: "bookmark")
                    .font(.system(size: 60))
                    .foregroundStyle(FLEKKSGradients.iconGradient)
            }

            Text("No Saved Sessions")
                .font(FLEKKSFonts.heading(24))
                .foregroundColor(.textPrimary)

            Text("Save sessions you want to do later by tapping the bookmark icon")
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

    private var totalMinutes: Int {
        savedSessionsList.reduce(0) { $0 + $1.durationMinutes }
    }

    private func getCoach(for session: Session) -> Coach? {
        if let team = dataService.teams.first(where: { $0.id == session.teamId }) {
            return team.coach
        }
        return nil
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(FLEKKSGradients.iconGradient)
                Text(value)
                    .font(FLEKKSFonts.headingHeavy(24))
                    .foregroundColor(.textPrimary)
            }
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

// MARK: - Saved Session Card
struct SavedSessionCard: View {
    let session: Session
    let coach: Coach?
    let onTap: () -> Void
    let onStart: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(FLEKKSGradients.heroTealVibrant)
                        .frame(width: 60, height: 60)

                    Text(iconForFocusArea(session.focusArea))
                        .font(.system(size: 28))
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    if let coach = coach {
                        Text("with \(coach.name)")
                            .font(FLEKKSFonts.body(12))
                            .foregroundColor(.textSecondary)
                    }

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
                VStack(spacing: 8) {
                    Button(action: onStart) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.bgPrimary)
                            .frame(width: 36, height: 36)
                            .background(FLEKKSGradients.buttonGradient)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button(action: onRemove) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 12))
                            .foregroundColor(.textMuted)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
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
}

#Preview {
    NavigationView {
        SavedSessionsView()
            .environmentObject(AppState())
    }
}
