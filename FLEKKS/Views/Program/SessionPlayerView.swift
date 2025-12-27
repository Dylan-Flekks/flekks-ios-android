import SwiftUI

struct SessionPlayerView: View {
    @Environment(\.dismiss) var dismiss

    let session: Session

    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 1080 // 18 minutes in seconds

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Video area (placeholder)
                ZStack {
                    FLEKKSGradients.heroGreen
                        .frame(height: 300)

                    // Glow effect
                    Circle()
                        .fill(FLEKKSGradients.tealGlow)
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)

                    VStack(spacing: 16) {
                        Text("🧘")
                            .font(.system(size: 80))

                        Text("Video Player")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }

                    // Close button
                    VStack {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }
                }

                // Session info
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.title)
                            .font(.custom("Georgia", size: 24))
                            .foregroundColor(.textPrimary)

                        Text(session.focusArea)
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }

                    // Progress bar
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.bgElevated)
                                    .frame(height: 4)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.accent)
                                    .frame(width: geometry.size.width * (currentTime / totalTime), height: 4)
                            }
                        }
                        .frame(height: 4)

                        HStack {
                            Text(formatTime(currentTime))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textMuted)
                            Spacer()
                            Text(formatTime(totalTime))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textMuted)
                        }
                    }

                    // Playback controls
                    HStack(spacing: 32) {
                        Button(action: { currentTime = max(0, currentTime - 15) }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 28))
                                .foregroundColor(.textSecondary)
                        }

                        Button(action: { isPlaying.toggle() }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 72))
                                .foregroundColor(.accent)
                        }

                        Button(action: { currentTime = min(totalTime, currentTime + 15) }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 28))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    // Current move indicator
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CURRENT MOVE")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.accent)
                            .tracking(1.5)

                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.bgElevated)
                                    .frame(width: 56, height: 56)
                                Text("🦵")
                                    .font(.system(size: 28))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("90/90 Hip Stretch")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                                Text("Hold for 45 seconds each side")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                            }

                            Spacer()

                            Text("0:45")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.accent)
                        }
                        .padding(16)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.border, lineWidth: 1)
                        )
                    }
                }
                .padding(24)

                Spacer()
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    SessionPlayerView(session: Session.hipOpener)
}
