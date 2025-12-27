import SwiftUI

// MARK: - Cheer Model
struct Cheer: Identifiable, Codable {
    let id: UUID
    let fromUserId: UUID
    let toUserId: UUID
    let teamId: UUID
    let type: CheerType
    let message: String?
    let createdAt: Date

    enum CheerType: String, Codable, CaseIterable {
        case fire = "🔥"
        case clap = "👏"
        case muscle = "💪"
        case star = "⭐️"
        case heart = "❤️"
        case rocket = "🚀"

        var label: String {
            switch self {
            case .fire: return "On Fire!"
            case .clap: return "Great Job!"
            case .muscle: return "Strong!"
            case .star: return "Star!"
            case .heart: return "Love It!"
            case .rocket: return "Crushing It!"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, type, message
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case teamId = "team_id"
        case createdAt = "created_at"
    }
}

// MARK: - Team Activity Feed Item
struct TeamActivity: Identifiable {
    let id: UUID
    let userId: UUID
    let userName: String
    let userInitials: String
    let type: ActivityType
    let sessionTitle: String?
    let timestamp: Date
    var cheersReceived: [Cheer] = []
    var hasCheered: Bool = false

    enum ActivityType {
        case completedSession
        case startedProgram
        case achievedStreak(Int)
        case earnedBadge(String)
        case postedSelfie
    }

    var activityText: String {
        switch type {
        case .completedSession:
            return "completed \(sessionTitle ?? "a session")"
        case .startedProgram:
            return "started the program"
        case .achievedStreak(let days):
            return "hit a \(days)-day streak! 🔥"
        case .earnedBadge(let badge):
            return "earned the \(badge) badge"
        case .postedSelfie:
            return "shared a post-workout selfie"
        }
    }

    static let preview: [TeamActivity] = [
        TeamActivity(
            id: UUID(),
            userId: UUID(),
            userName: "Sarah M.",
            userInitials: "SM",
            type: .completedSession,
            sessionTitle: "Hip Hinge Mastery",
            timestamp: Date().addingTimeInterval(-1800),
            cheersReceived: [],
            hasCheered: false
        ),
        TeamActivity(
            id: UUID(),
            userId: UUID(),
            userName: "Mike R.",
            userInitials: "MR",
            type: .achievedStreak(7),
            sessionTitle: nil,
            timestamp: Date().addingTimeInterval(-3600),
            cheersReceived: [],
            hasCheered: true
        ),
        TeamActivity(
            id: UUID(),
            userId: UUID(),
            userName: "Emily K.",
            userInitials: "EK",
            type: .postedSelfie,
            sessionTitle: nil,
            timestamp: Date().addingTimeInterval(-7200),
            cheersReceived: [],
            hasCheered: false
        ),
    ]
}

// MARK: - Team Activity Feed View
struct TeamActivityFeed: View {
    @EnvironmentObject var appState: AppState
    @State private var activities: [TeamActivity] = TeamActivity.preview
    @State private var showCheerPicker: UUID? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Team Activity")
                    .font(FLEKKSFonts.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("Today")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textMuted)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Activity List
            VStack(spacing: 12) {
                ForEach($activities) { $activity in
                    ActivityCard(
                        activity: $activity,
                        showCheerPicker: $showCheerPicker,
                        onCheer: { cheerType in
                            sendCheer(to: activity, type: cheerType)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func sendCheer(to activity: TeamActivity, type: Cheer.CheerType) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }

        let cheer = Cheer(
            id: UUID(),
            fromUserId: appState.currentUser?.id ?? UUID(),
            toUserId: activity.userId,
            teamId: appState.selectedTeam?.id ?? UUID(),
            type: type,
            message: nil,
            createdAt: Date()
        )

        activities[index].cheersReceived.append(cheer)
        activities[index].hasCheered = true
        showCheerPicker = nil

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    @Binding var activity: TeamActivity
    @Binding var showCheerPicker: UUID?
    let onCheer: (Cheer.CheerType) -> Void

    @State private var showCheers = false

    private var isPickerOpen: Bool {
        showCheerPicker == activity.id
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 12) {
                // Avatar
                AvatarView(initials: activity.userInitials, size: 44)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(activity.userName)
                            .font(FLEKKSFonts.bodySemibold(15))
                            .foregroundColor(.textPrimary)

                        Text(activity.activityText)
                            .font(FLEKKSFonts.body(15))
                            .foregroundColor(.textSecondary)
                    }
                    .lineLimit(2)

                    Text(timeAgo(activity.timestamp))
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                // Cheer button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        if isPickerOpen {
                            showCheerPicker = nil
                        } else {
                            showCheerPicker = activity.id
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        if activity.hasCheered {
                            Image(systemName: "hands.clap.fill")
                                .foregroundColor(.accent)
                        } else {
                            Image(systemName: "hands.clap")
                                .foregroundColor(.textMuted)
                        }

                        if activity.cheersReceived.count > 0 {
                            Text("\(activity.cheersReceived.count)")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(activity.hasCheered ? .accent : .textMuted)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(activity.hasCheered ? Color.accentGlowStrong : Color.bgElevated)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(14)

            // Cheer reactions display
            if !activity.cheersReceived.isEmpty && !isPickerOpen {
                HStack(spacing: 4) {
                    ForEach(uniqueCheerTypes(activity.cheersReceived), id: \.self) { type in
                        Text(type.rawValue)
                            .font(.system(size: 16))
                    }

                    Text("\(activity.cheersReceived.count) cheers")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }

            // Cheer picker
            if isPickerOpen {
                CheerPicker(onSelect: onCheer)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private func uniqueCheerTypes(_ cheers: [Cheer]) -> [Cheer.CheerType] {
        Array(Set(cheers.map { $0.type })).prefix(5).map { $0 }
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}

// MARK: - Cheer Picker
struct CheerPicker: View {
    let onSelect: (Cheer.CheerType) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Cheer.CheerType.allCases, id: \.self) { type in
                Button(action: { onSelect(type) }) {
                    VStack(spacing: 4) {
                        Text(type.rawValue)
                            .font(.system(size: 28))

                        Text(type.label)
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.bgCard)
    }
}

// MARK: - Cheer Received Toast
struct CheerReceivedToast: View {
    let cheer: Cheer
    let fromName: String

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Text(cheer.type.rawValue)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 2) {
                Text(fromName)
                    .font(FLEKKSFonts.bodySemibold(15))
                    .foregroundColor(.textPrimary)

                Text("sent you a cheer!")
                    .font(FLEKKSFonts.body(14))
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                Color.bgCard
                LinearGradient(
                    colors: [Color.accent.opacity(0.1), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(FLEKKSGradients.borderGradient, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Quick Cheer Button (for use in lists)
struct QuickCheerButton: View {
    let hasCheered: Bool
    let cheerCount: Int
    let action: () -> Void

    @State private var isAnimating = false

    var body: some View {
        Button(action: {
            if !hasCheered {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
                action()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: hasCheered ? "hands.clap.fill" : "hands.clap")
                    .font(.system(size: 16))
                    .foregroundColor(hasCheered ? .accent : .textMuted)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)

                if cheerCount > 0 {
                    Text("\(cheerCount)")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(hasCheered ? .accent : .textMuted)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(hasCheered ? Color.accentGlowStrong : Color.bgElevated)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(hasCheered)
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()

        ScrollView {
            TeamActivityFeed()
                .environmentObject(AppState())
        }
    }
}
