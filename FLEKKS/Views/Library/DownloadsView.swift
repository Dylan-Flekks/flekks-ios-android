import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared
    @Environment(\.dismiss) private var dismiss

    private var downloadedSessionsList: [Session] {
        dataService.sessions.filter { appState.downloadedSessions.contains($0.id) }
    }

    private var totalStorageUsed: String {
        // Estimate ~50MB per session video
        let totalMB = downloadedSessionsList.count * 50
        if totalMB >= 1000 {
            return String(format: "%.1f GB", Double(totalMB) / 1000.0)
        }
        return "\(totalMB) MB"
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if downloadedSessionsList.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Storage Info Card
                        storageCard

                        // Downloads List
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Downloaded Sessions")
                                    .font(FLEKKSFonts.titleSmall)
                                    .foregroundColor(.textPrimary)

                                Spacer()

                                Text("\(downloadedSessionsList.count) sessions")
                                    .font(FLEKKSFonts.labelMedium)
                                    .foregroundColor(.textMuted)
                            }

                            VStack(spacing: 12) {
                                ForEach(downloadedSessionsList) { session in
                                    DownloadedSessionCard(
                                        session: session,
                                        coach: getCoach(for: session),
                                        onTap: {
                                            appState.viewSessionDetail(session)
                                        },
                                        onStart: {
                                            appState.startSession(session)
                                        },
                                        onDelete: {
                                            withAnimation {
                                                appState.removeDownloadedSession(session.id)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Downloads")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !downloadedSessionsList.isEmpty {
                    Menu {
                        Button(role: .destructive) {
                            withAnimation {
                                appState.downloadedSessions.removeAll()
                            }
                        } label: {
                            Label("Delete All Downloads", systemImage: "trash")
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

                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(FLEKKSGradients.iconGradient)
            }

            Text("No Downloads")
                .font(FLEKKSFonts.heading(24))
                .foregroundColor(.textPrimary)

            Text("Download sessions to train offline without WiFi or cell service")
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

    private var storageCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Storage Used")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.textSecondary)

                    Text(totalStorageUsed)
                        .font(FLEKKSFonts.headingHeavy(28))
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.bgElevated, lineWidth: 6)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: min(Double(downloadedSessionsList.count) / 20.0, 1.0))
                        .stroke(
                            FLEKKSGradients.accentGradientVibrant,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "internaldrive.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(FLEKKSGradients.iconGradient)
                }
            }

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 8, height: 8)
                    Text("\(downloadedSessionsList.count) Sessions")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textSecondary)
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.bgElevated)
                        .frame(width: 8, height: 8)
                    Text("Available Space")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textMuted)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func getCoach(for session: Session) -> Coach? {
        if let team = dataService.teams.first(where: { $0.id == session.teamId }) {
            return team.coach
        }
        return nil
    }
}

// MARK: - Downloaded Session Card
struct DownloadedSessionCard: View {
    let session: Session
    let coach: Coach?
    let onTap: () -> Void
    let onStart: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon with downloaded badge
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.bgElevated)
                            .frame(width: 56, height: 56)

                        Text(iconForFocusArea(session.focusArea))
                            .font(.system(size: 26))
                    }

                    // Downloaded badge
                    ZStack {
                        Circle()
                            .fill(Color.accent)
                            .frame(width: 20, height: 20)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.bgPrimary)
                    }
                    .offset(x: 4, y: 4)
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
                        Text("•")
                        Text("~50 MB")
                    }
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)

                    HStack(spacing: 4) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 10))
                        Text("Available offline")
                            .font(FLEKKSFonts.labelSmall)
                    }
                    .foregroundColor(.accent)
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

                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.flekksRed)
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
        .confirmationDialog("Delete Download?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the downloaded video. You can download it again anytime.")
        }
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
        DownloadsView()
            .environmentObject(AppState())
    }
}
