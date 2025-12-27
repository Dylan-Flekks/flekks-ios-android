import SwiftUI

struct SessionPlayerView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared
    @StateObject private var musicService = MusicService.shared

    let session: Session

    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 0
    @State private var timer: Timer?
    @State private var showCompleteAlert = false
    @State private var isGlowing = false
    @State private var showMusicSettings = false
    @State private var currentExerciseIndex = 0

    // Simulated exercises for the session
    private let exercises: [(name: String, duration: Int, icon: String)] = [
        ("Warm-Up Breathing", 60, "wind"),
        ("90/90 Hip Stretch", 45, "🦵"),
        ("Pigeon Pose Hold", 60, "🧘"),
        ("Hip Circles", 30, "arrow.triangle.2.circlepath"),
        ("Figure-4 Stretch", 45, "🔄"),
        ("Frog Stretch", 60, "🐸"),
        ("Butterfly Stretch", 45, "🦋"),
        ("Deep Squat Hold", 60, "⬇️"),
        ("Cool Down", 90, "❄️"),
    ]

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Video area (placeholder)
                ZStack {
                    heroGradient
                        .frame(height: 280)

                    // Glow effect
                    Circle()
                        .fill(FLEKKSGradients.tealGlowIntense)
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .scaleEffect(isGlowing ? 1.1 : 1.0)
                        .opacity(isGlowing ? 0.8 : 0.5)

                    VStack(spacing: 16) {
                        Text(iconForFocusArea(session.focusArea))
                            .font(.system(size: 80))
                            .scaleEffect(isGlowing ? 1.05 : 1.0)

                        if !session.hasMuxVideo {
                            Text("Video Coming Soon")
                                .font(FLEKKSFonts.bodyMedium(14))
                                .foregroundColor(.textMuted)
                        }
                    }

                    // Top controls overlay
                    VStack {
                        HStack {
                            Button(action: { appState.endSession() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            // Music button
                            Button(action: { showMusicSettings = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: musicService.connectedProvider == .none ? "music.note" : musicService.connectedProvider.icon)
                                        .font(.system(size: 14))
                                    if musicService.playbackState == .playing {
                                        Text("Playing")
                                            .font(FLEKKSFonts.labelSmall)
                                    }
                                }
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())
                            }

                            // Session progress
                            Text("Day \(session.dayNumber)")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())
                        }
                        .padding()
                        Spacer()
                    }
                }

                // Session info
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(FLEKKSFonts.heading(24))
                                .foregroundColor(.textPrimary)

                            Text(session.focusArea)
                                .font(FLEKKSFonts.body(14))
                                .foregroundColor(.textSecondary)
                        }

                        // Progress bar
                        VStack(spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.bgElevated)
                                        .frame(height: 6)

                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(FLEKKSGradients.accentGradientVibrant)
                                        .frame(width: geometry.size.width * (currentTime / max(totalTime, 1)), height: 6)
                                }
                            }
                            .frame(height: 6)

                            HStack {
                                Text(formatTime(currentTime))
                                    .font(FLEKKSFonts.labelMedium)
                                    .foregroundColor(.textMuted)
                                Spacer()
                                Text(formatTime(totalTime))
                                    .font(FLEKKSFonts.labelMedium)
                                    .foregroundColor(.textMuted)
                            }
                        }

                        // Playback controls
                        HStack(spacing: 32) {
                            Button(action: { seekBack() }) {
                                Image(systemName: "gobackward.15")
                                    .font(.system(size: 28))
                                    .foregroundColor(.textSecondary)
                            }

                            Button(action: togglePlayback) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 72))
                                    .foregroundStyle(FLEKKSGradients.accentGradient)
                            }

                            Button(action: { seekForward() }) {
                                Image(systemName: "goforward.15")
                                    .font(.system(size: 28))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)

                        // Current move indicator
                        CurrentExerciseCard(
                            exercise: exercises[min(currentExerciseIndex, exercises.count - 1)],
                            exerciseNumber: currentExerciseIndex + 1,
                            totalExercises: exercises.count
                        )

                        // Music Mini Player (if connected)
                        if musicService.connectedProvider != .none {
                            MusicMiniPlayer(musicService: musicService)
                                .padding(.top, 8)
                        }

                        // Upcoming exercises
                        if currentExerciseIndex < exercises.count - 1 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("UP NEXT")
                                    .font(FLEKKSFonts.labelSmall)
                                    .foregroundColor(.textMuted)
                                    .tracking(1.5)

                                VStack(spacing: 8) {
                                    ForEach(Array(exercises.dropFirst(currentExerciseIndex + 1).prefix(3).enumerated()), id: \.offset) { index, exercise in
                                        UpcomingExerciseRow(
                                            exercise: exercise,
                                            number: currentExerciseIndex + index + 2
                                        )
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }

                        Spacer(minLength: 20)

                        // Complete session button
                        Button(action: { showCompleteAlert = true }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark Complete")
                            }
                            .font(FLEKKSFonts.bodySemibold(16))
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.bottom, 20)
                    }
                    .padding(24)
                }
            }
        }
        .onAppear {
            totalTime = Double(session.durationMinutes * 60)
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
            // Auto-play music if enabled
            if musicService.autoPlayOnWorkoutStart && musicService.connectedProvider != .none {
                musicService.play()
            }
        }
        .onDisappear {
            timer?.invalidate()
            musicService.stop()
        }
        .alert("Complete Session?", isPresented: $showCompleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Complete") {
                completeSession()
            }
        } message: {
            Text("Mark this session as complete and record your progress.")
        }
        .sheet(isPresented: $showMusicSettings) {
            MusicSettingsView(musicService: musicService)
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

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            // Resume music if paused
            if musicService.playbackState == .paused {
                musicService.resume()
            }

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if currentTime < totalTime {
                    currentTime += 1

                    // Update current exercise based on time
                    updateCurrentExercise()

                    // Simulate coach speaking at exercise transitions
                    simulateCoachCues()
                } else {
                    timer?.invalidate()
                    isPlaying = false
                    showCompleteAlert = true
                }
            }
        } else {
            timer?.invalidate()
            musicService.pause()
        }
    }

    private func seekBack() {
        currentTime = max(0, currentTime - 15)
        updateCurrentExercise()
    }

    private func seekForward() {
        currentTime = min(totalTime, currentTime + 15)
        updateCurrentExercise()
    }

    private func updateCurrentExercise() {
        var accumulatedTime: Double = 0
        for (index, exercise) in exercises.enumerated() {
            accumulatedTime += Double(exercise.duration)
            if currentTime < accumulatedTime {
                if currentExerciseIndex != index {
                    currentExerciseIndex = index
                    // Coach speaks during transitions
                    musicService.startCoachSpeaking()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        musicService.stopCoachSpeaking()
                    }
                }
                break
            }
        }
    }

    private func simulateCoachCues() {
        // Simulate coach speaking at certain intervals
        let exerciseTimes = exercises.reduce(into: [Double]()) { result, exercise in
            let lastTime = result.last ?? 0
            result.append(lastTime + Double(exercise.duration))
        }

        // Check if we're near an exercise boundary (within 3 seconds)
        for time in exerciseTimes {
            if abs(currentTime - time) < 1 {
                musicService.startCoachSpeaking()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    musicService.stopCoachSpeaking()
                }
                break
            }
        }
    }

    private func completeSession() {
        timer?.invalidate()
        musicService.stop()
        let completedDuration = Int(currentTime)
        Task {
            try? await dataService.markSessionComplete(
                session: session,
                durationSeconds: completedDuration
            )
            appState.recordSessionComplete(session: session, duration: completedDuration)
            appState.endSession()
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
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
}

// MARK: - Current Exercise Card
struct CurrentExerciseCard: View {
    let exercise: (name: String, duration: Int, icon: String)
    let exerciseNumber: Int
    let totalExercises: Int

    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CURRENT MOVE")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundStyle(FLEKKSGradients.accentGradient)
                    .tracking(1.5)

                Spacer()

                Text("\(exerciseNumber)/\(totalExercises)")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textMuted)
            }

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.bgElevated)
                        .frame(width: 56, height: 56)

                    if exercise.icon.count == 1 || exercise.icon.unicodeScalars.first?.properties.isEmoji == true {
                        Text(exercise.icon)
                            .font(.system(size: 28))
                    } else {
                        Image(systemName: exercise.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(FLEKKSGradients.iconGradient)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(FLEKKSFonts.bodySemibold(16))
                        .foregroundColor(.textPrimary)
                    Text("Hold for \(exercise.duration) seconds")
                        .font(FLEKKSFonts.body(13))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Countdown timer
                ZStack {
                    Circle()
                        .stroke(Color.bgElevated, lineWidth: 4)
                        .frame(width: 56, height: 56)

                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(exercise.duration))
                        .stroke(FLEKKSGradients.accentGradientVibrant, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))

                    Text("0:\(String(format: "%02d", timeRemaining))")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundStyle(FLEKKSGradients.accentGradient)
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .onAppear {
            timeRemaining = exercise.duration
            startTimer()
        }
        .onChange(of: exercise.name) { _, _ in
            timeRemaining = exercise.duration
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
}

// MARK: - Upcoming Exercise Row
struct UpcomingExerciseRow: View {
    let exercise: (name: String, duration: Int, icon: String)
    let number: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(.textMuted)
                .frame(width: 24)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.bgElevated)
                    .frame(width: 40, height: 40)

                if exercise.icon.count == 1 || exercise.icon.unicodeScalars.first?.properties.isEmoji == true {
                    Text(exercise.icon)
                        .font(.system(size: 18))
                        .opacity(0.7)
                } else {
                    Image(systemName: exercise.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(FLEKKSFonts.bodyMedium(14))
                    .foregroundColor(.textSecondary)

                Text("\(exercise.duration)s")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }

            Spacer()
        }
        .padding(10)
        .background(Color.bgCard.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SessionPlayerView(session: Session.lowBackSessions[0])
        .environmentObject(AppState())
}
