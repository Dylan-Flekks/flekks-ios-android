import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 20) {
                Circle()
                    .stroke(Color.bgElevated, lineWidth: 4)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(Color.accent, lineWidth: 4)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    )

                Text("Loading...")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 48))

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding(32)
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let initials: String
    var size: CGFloat = 44
    var useGradient: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .fill(useGradient ? AnyShapeStyle(FLEKKSGradients.avatarGradient) : AnyShapeStyle(Color.bgElevated))
                .frame(width: size, height: size)

            Text(initials)
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(useGradient ? .bgPrimary : .textSecondary)
        }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.bgElevated, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold))
                .foregroundColor(.textPrimary)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    var color: Color = .accent

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - Divider with Label
struct LabeledDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.border)
                .frame(height: 1)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textMuted)

            Rectangle()
                .fill(Color.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Animated Checkmark
struct AnimatedCheckmark: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accent)
                .frame(width: 64, height: 64)

            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.bgPrimary)
                .scaleEffect(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Streak Flame
struct StreakFlame: View {
    let count: Int
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 6) {
            Text("🔥")
                .font(.system(size: 24))
                .scaleEffect(isAnimating ? 1.1 : 1.0)

            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.flekksOrange)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview Provider
#Preview("Components") {
    ScrollView {
        VStack(spacing: 32) {
            LoadingView()
                .frame(height: 120)

            EmptyStateView(
                icon: "🧘",
                title: "No sessions yet",
                message: "Start your first session to begin your flexibility journey",
                actionTitle: "Get Started"
            ) {}

            HStack(spacing: 16) {
                AvatarView(initials: "DD")
                AvatarView(initials: "MC", useGradient: false)
            }

            ProgressRing(progress: 0.68)

            HStack(spacing: 8) {
                TagView(text: "Beginner")
                TagView(text: "Hips", color: .flekksOrange)
            }

            LabeledDivider(label: "OR")

            AnimatedCheckmark()

            StreakFlame(count: 12)
        }
        .padding()
    }
    .background(Color.bgPrimary)
}
