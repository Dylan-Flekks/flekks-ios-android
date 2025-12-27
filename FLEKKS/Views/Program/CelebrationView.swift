import SwiftUI

struct CelebrationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let session: Session
    let durationCompleted: Int  // in seconds

    @State private var showContent = false
    @State private var showConfetti = false
    @State private var flameScale: CGFloat = 0.5
    @State private var streakBounce = false

    private var completedMinutes: Int {
        durationCompleted / 60
    }

    var body: some View {
        ZStack {
            // Background
            Color.bgPrimary.ignoresSafeArea()

            // Animated gradient background
            ZStack {
                Circle()
                    .fill(FLEKKSGradients.tealGlowIntense)
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(y: -100)

                Circle()
                    .fill(RadialGradient(
                        colors: [Color.flekksOrange.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    ))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(y: 50)
            }
            .opacity(showContent ? 1 : 0)

            // Confetti Layer
            if showConfetti {
                ConfettiView()
            }

            // Main Content
            VStack(spacing: 0) {
                Spacer()

                // Celebration Icon
                VStack(spacing: 20) {
                    ZStack {
                        // Glow ring
                        Circle()
                            .stroke(
                                FLEKKSGradients.accentGradientVibrant,
                                lineWidth: 4
                            )
                            .frame(width: 140, height: 140)
                            .scaleEffect(showContent ? 1 : 0.5)
                            .opacity(showContent ? 1 : 0)

                        // Inner circle
                        Circle()
                            .fill(FLEKKSGradients.buttonGradient)
                            .frame(width: 120, height: 120)
                            .scaleEffect(showContent ? 1 : 0)

                        // Checkmark
                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.bgPrimary)
                            .scaleEffect(showContent ? 1 : 0)
                    }

                    Text("Session Complete!")
                        .font(FLEKKSFonts.heading(32))
                        .foregroundColor(.textPrimary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }

                Spacer()
                    .frame(height: 40)

                // Stats Cards
                VStack(spacing: 16) {
                    // Streak Card - Featured
                    HStack(spacing: 16) {
                        Text("🔥")
                            .font(.system(size: 44))
                            .scaleEffect(flameScale)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("STREAK")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.flekksOrange)
                                .tracking(1.5)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(appState.currentStreak)")
                                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                                    .foregroundColor(.textPrimary)
                                    .scaleEffect(streakBounce ? 1.1 : 1.0)

                                Text("days")
                                    .font(FLEKKSFonts.bodyMedium(18))
                                    .foregroundColor(.textSecondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(24)
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
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.flekksOrange.opacity(0.5), Color.flekksOrange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)

                    // Session Stats Row
                    HStack(spacing: 12) {
                        CelebrationStatCard(
                            icon: "clock.fill",
                            value: "\(completedMinutes)",
                            label: "Minutes"
                        )

                        CelebrationStatCard(
                            icon: "target",
                            value: session.focusArea,
                            label: "Focus",
                            isText: true
                        )

                        CelebrationStatCard(
                            icon: "flame.fill",
                            value: difficultyEmoji,
                            label: "Intensity",
                            isEmoji: true
                        )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 40)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    // Share Button
                    Button(action: shareWorkout) {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Share Your Progress")
                        }
                        .font(FLEKKSFonts.bodySemibold(16))
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    // Done Button
                    Button(action: {
                        appState.dismissCelebration()
                        dismiss()
                    }) {
                        Text("Done")
                            .font(FLEKKSFonts.bodySemibold(16))
                    }
                    .buttonStyle(TealGlowButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            animateEntry()
        }
    }

    private var difficultyEmoji: String {
        switch session.difficulty {
        case .easy: return "😌"
        case .moderate: return "💪"
        case .challenging: return "🔥"
        }
    }

    private func animateEntry() {
        // Staggered animations
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            showContent = true
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
            flameScale = 1.0
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.5)) {
            streakBounce = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.3)) {
                streakBounce = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showConfetti = true
        }
    }

    private func shareWorkout() {
        // Would open share sheet with workout summary
        print("Share workout")
    }
}

// MARK: - Celebration Stat Card
struct CelebrationStatCard: View {
    let icon: String
    let value: String
    let label: String
    var isText: Bool = false
    var isEmoji: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            if isEmoji {
                Text(value)
                    .font(.system(size: 28))
            } else {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(FLEKKSGradients.iconGradient)
            }

            if !isEmoji {
                Text(value)
                    .font(isText ? FLEKKSFonts.bodySemibold(14) : FLEKKSFonts.headingHeavy(22))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
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

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, screenHeight: geometry.size.height)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            createConfetti()
        }
    }

    private func createConfetti() {
        let colors: [Color] = [.accent, .flekksOrange, .accentLight, .tealBright, .white]
        let shapes = ["circle", "square", "triangle"]

        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: colors.randomElement()!,
                shape: shapes.randomElement()!,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...0.5),
                duration: Double.random(in: 2...4),
                rotation: Double.random(in: 0...360)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let shape: String
    let x: CGFloat
    let delay: Double
    let duration: Double
    let rotation: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let screenHeight: CGFloat

    @State private var yOffset: CGFloat = -50
    @State private var opacity: Double = 1
    @State private var currentRotation: Double = 0

    var body: some View {
        Group {
            switch piece.shape {
            case "circle":
                Circle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            case "square":
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            default:
                Triangle()
                    .fill(piece.color)
                    .frame(width: 10, height: 10)
            }
        }
        .position(x: piece.x, y: yOffset)
        .rotationEffect(.degrees(currentRotation))
        .opacity(opacity)
        .onAppear {
            withAnimation(
                .easeIn(duration: piece.duration)
                .delay(piece.delay)
            ) {
                yOffset = screenHeight + 50
                currentRotation = piece.rotation + 720
            }

            withAnimation(
                .easeIn(duration: piece.duration * 0.5)
                .delay(piece.delay + piece.duration * 0.5)
            ) {
                opacity = 0
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    CelebrationView(
        session: Session.lowBackSessions[0],
        durationCompleted: 900
    )
    .environmentObject(AppState())
}
