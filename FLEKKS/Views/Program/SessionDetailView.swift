import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared
    @Environment(\.dismiss) private var dismiss

    let session: Session
    let coach: Coach?

    @State private var showScheduleSheet = false
    @State private var showShareSheet = false
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0
    @State private var isGlowing = false

    private var isSaved: Bool {
        appState.savedSessions.contains(session.id)
    }

    private var isScheduled: Bool {
        appState.scheduledSessions[session.id] != nil
    }

    private var isDownloaded: Bool {
        appState.downloadedSessions.contains(session.id)
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection

                    // Content
                    VStack(spacing: 24) {
                        // Session Info
                        sessionInfoSection

                        // Action Buttons Row
                        actionButtonsRow

                        // Session Details Card
                        sessionDetailsCard

                        // Equipment Section
                        if !session.equipment.isEmpty {
                            equipmentSection
                        }

                        // Coach Section
                        if let coach = coach {
                            coachSection(coach: coach)
                        }

                        // What You'll Do Section
                        whatYoullDoSection

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }

            // Fixed Bottom CTA
            VStack {
                Spacer()
                startSessionButton
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
        .sheet(isPresented: $showScheduleSheet) {
            ScheduleSessionSheet(session: session)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSessionSheet(session: session, coach: coach)
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            // Background gradient
            heroGradient
                .frame(height: 280)

            // Glow effect
            Circle()
                .fill(FLEKKSGradients.tealGlowIntense)
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: 20)
                .scaleEffect(isGlowing ? 1.1 : 1.0)
                .opacity(isGlowing ? 0.8 : 0.5)

            // Session icon
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(iconForFocusArea(session.focusArea))
                        .font(.system(size: 100))
                        .scaleEffect(isGlowing ? 1.05 : 1.0)
                        .offset(x: -20, y: -20)
                }
            }
            .frame(height: 280)

            // Top bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }

                Spacer()

                // Day badge
                Text("Day \(session.dayNumber) • Week \(session.weekNumber)")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
    }

    // MARK: - Session Info Section
    private var sessionInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Focus area tag
            Text(session.focusArea.uppercased())
                .font(FLEKKSFonts.labelSmall)
                .foregroundStyle(FLEKKSGradients.accentGradient)
                .tracking(1.5)

            // Title
            Text(session.title)
                .font(FLEKKSFonts.heading(28))
                .foregroundColor(.textPrimary)

            // Coach name
            if let coach = coach {
                Text("with \(coach.name)")
                    .font(FLEKKSFonts.bodyMedium(15))
                    .foregroundColor(.textSecondary)
            }

            // Description
            Text(session.description)
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
                .padding(.top, 8)

            // Meta tags
            HStack(spacing: 12) {
                MetaTag(icon: "clock", text: "\(session.durationMinutes) min")
                MetaTag(icon: "flame", text: difficultyText)
                if session.isCompleted {
                    MetaTag(icon: "checkmark.circle.fill", text: "Completed")
                }
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Action Buttons Row
    private var actionButtonsRow: some View {
        HStack(spacing: 12) {
            // Save Button
            ActionButton(
                icon: isSaved ? "bookmark.fill" : "bookmark",
                label: isSaved ? "Saved" : "Save",
                isActive: isSaved
            ) {
                withAnimation(.spring(response: 0.3)) {
                    appState.toggleSaveSession(session.id)
                }
            }

            // Schedule Button
            ActionButton(
                icon: isScheduled ? "calendar.badge.checkmark" : "calendar",
                label: isScheduled ? "Scheduled" : "Schedule",
                isActive: isScheduled
            ) {
                showScheduleSheet = true
            }

            // Share Button
            ActionButton(
                icon: "square.and.arrow.up",
                label: "Share",
                isActive: false
            ) {
                showShareSheet = true
            }

            // Download Button
            ActionButton(
                icon: isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle",
                label: isDownloaded ? "Downloaded" : "Download",
                isActive: isDownloaded,
                isLoading: isDownloading,
                progress: downloadProgress
            ) {
                downloadSession()
            }
        }
    }

    // MARK: - Session Details Card
    private var sessionDetailsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Session Details")
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(.textPrimary)
                Spacer()
            }

            HStack(spacing: 20) {
                DetailItem(icon: "clock.fill", title: "Duration", value: "\(session.durationMinutes) min")
                DetailItem(icon: "flame.fill", title: "Intensity", value: difficultyText)
                DetailItem(icon: "target", title: "Focus", value: session.focusArea)
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

    // MARK: - Equipment Section
    private var equipmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment Needed")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            HStack(spacing: 10) {
                ForEach(session.equipment, id: \.self) { item in
                    EquipmentTag(name: item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    // MARK: - Coach Section
    private func coachSection(coach: Coach) -> some View {
        HStack(spacing: 14) {
            AvatarView(initials: coach.avatarInitials, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(coach.name)
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(.textPrimary)
                Text(coach.credential)
                    .font(FLEKKSFonts.body(13))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Button(action: {
                appState.viewCoachProfile(coach.id)
            }) {
                Text("View Profile")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundStyle(FLEKKSGradients.accentGradient)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.accentGlowStrong)
                    .clipShape(Capsule())
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

    // MARK: - What You'll Do Section
    private var whatYoullDoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What You'll Do")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                ExercisePreviewRow(number: 1, name: "Warm-Up Flow", duration: "3 min")
                ExercisePreviewRow(number: 2, name: "Active Stretching", duration: "\(max(session.durationMinutes - 8, 5)) min")
                ExercisePreviewRow(number: 3, name: "Deep Hold Work", duration: "3 min")
                ExercisePreviewRow(number: 4, name: "Cool Down", duration: "2 min")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    // MARK: - Start Session Button
    private var startSessionButton: some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [Color.bgPrimary.opacity(0), Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)

            VStack(spacing: 12) {
                Button(action: {
                    appState.startSession(session)
                    dismiss()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Start Session")
                            .font(FLEKKSFonts.bodySemibold(17))
                    }
                }
                .buttonStyle(TealGlowButtonStyle())

                if session.isCompleted {
                    Text("You've already completed this session")
                        .font(FLEKKSFonts.body(12))
                        .foregroundColor(.textMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .background(Color.bgPrimary)
        }
    }

    // MARK: - Helpers
    private var heroGradient: LinearGradient {
        if let team = appState.selectedTeam {
            switch team.heroGradient {
            case .green: return FLEKKSGradients.heroGreen
            case .purple: return FLEKKSGradients.heroPurple
            case .blue: return FLEKKSGradients.heroBlue
            case .teal: return FLEKKSGradients.heroTeal
            }
        }
        return FLEKKSGradients.heroGreen
    }

    private var difficultyText: String {
        switch session.difficulty {
        case .easy: return "Easy"
        case .moderate: return "Moderate"
        case .challenging: return "Challenging"
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
        case let a where a.contains("glute"): return "🍑"
        case let a where a.contains("assessment"): return "📋"
        default: return "✨"
        }
    }

    private func downloadSession() {
        guard !isDownloaded && !isDownloading else { return }

        isDownloading = true
        downloadProgress = 0

        // Simulate download progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            downloadProgress += 0.05
            if downloadProgress >= 1.0 {
                timer.invalidate()
                isDownloading = false
                appState.addDownloadedSession(session.id)
            }
        }
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    var isLoading: Bool = false
    var progress: Double = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if isLoading {
                        Circle()
                            .stroke(Color.bgElevated, lineWidth: 3)
                            .frame(width: 44, height: 44)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))

                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accent)
                    } else {
                        Circle()
                            .fill(isActive ? Color.accentGlowStrong : Color.bgElevated)
                            .frame(width: 44, height: 44)

                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isActive ? .accent : .textSecondary)
                    }
                }

                Text(label)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(isActive ? .accent : .textMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

// MARK: - Detail Item Component
struct DetailItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(FLEKKSGradients.iconGradient)

            Text(value)
                .font(FLEKKSFonts.bodySemibold(14))
                .foregroundColor(.textPrimary)

            Text(title)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Equipment Tag Component
struct EquipmentTag: View {
    let name: String

    private var icon: String {
        switch name.lowercased() {
        case "mat": return "rectangle.fill"
        case "foam roller": return "cylinder.fill"
        case "strap", "band": return "link"
        case "block", "blocks": return "cube.fill"
        case "weight", "weights": return "scalemass.fill"
        case "wall": return "square.fill"
        default: return "circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(FLEKKSGradients.iconGradient)

            Text(name.capitalized)
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Exercise Preview Row
struct ExercisePreviewRow: View {
    let number: Int
    let name: String
    let duration: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.bgElevated)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textSecondary)
            }

            Text(name)
                .font(FLEKKSFonts.bodyMedium(15))
                .foregroundColor(.textPrimary)

            Spacer()

            Text(duration)
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(.textMuted)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SessionDetailView(
        session: Session.lowBackSessions[0],
        coach: Coach.dylanPeters
    )
    .environmentObject(AppState())
}
