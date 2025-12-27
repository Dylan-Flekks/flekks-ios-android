import SwiftUI

// MARK: - Enhanced Chat Message Model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let senderId: UUID
    let senderName: String
    let senderInitials: String
    let text: String
    let timestamp: Date
    let isCoach: Bool
    var isPinned: Bool
    var isAnnouncement: Bool
    var reactions: [MessageReaction]
    var replyTo: UUID?
    var attachmentType: AttachmentType?

    enum AttachmentType: String, Codable {
        case image
        case video
        case workout
        case poll
    }

    static let previewMessages: [ChatMessage] = [
        ChatMessage(
            id: UUID(),
            senderId: UUID(),
            senderName: "Coach Tom",
            senderInitials: "TM",
            text: "Great work everyone! Remember, consistency beats intensity. See you tomorrow for hip mobility! 🔥",
            timestamp: Date().addingTimeInterval(-3600),
            isCoach: true,
            isPinned: true,
            isAnnouncement: true,
            reactions: [MessageReaction(type: .fire, count: 12), MessageReaction(type: .heart, count: 5)],
            replyTo: nil,
            attachmentType: nil
        ),
        ChatMessage(
            id: UUID(),
            senderId: UUID(),
            senderName: "Sarah M.",
            senderInitials: "SM",
            text: "Just finished the morning stretch! Already feeling more mobile 💪",
            timestamp: Date().addingTimeInterval(-1800),
            isCoach: false,
            isPinned: false,
            isAnnouncement: false,
            reactions: [MessageReaction(type: .clap, count: 8)],
            replyTo: nil,
            attachmentType: nil
        ),
        ChatMessage(
            id: UUID(),
            senderId: UUID(),
            senderName: "Mike R.",
            senderInitials: "MR",
            text: "Can anyone recommend a good warm-up before the pike sessions? I always feel tight starting out.",
            timestamp: Date().addingTimeInterval(-900),
            isCoach: false,
            isPinned: false,
            isAnnouncement: false,
            reactions: [],
            replyTo: nil,
            attachmentType: nil
        ),
        ChatMessage(
            id: UUID(),
            senderId: UUID(),
            senderName: "Coach Tom",
            senderInitials: "TM",
            text: "Great question Mike! Try the 5-minute hip circles from my warm-up series. I'll pin the session link above.",
            timestamp: Date().addingTimeInterval(-600),
            isCoach: true,
            isPinned: false,
            isAnnouncement: false,
            reactions: [MessageReaction(type: .fire, count: 3)],
            replyTo: nil,
            attachmentType: nil
        ),
        ChatMessage(
            id: UUID(),
            senderId: UUID(),
            senderName: "Emma L.",
            senderInitials: "EL",
            text: "Day 15 of my streak! Never thought I'd stick with stretching this long 🎉",
            timestamp: Date().addingTimeInterval(-300),
            isCoach: false,
            isPinned: false,
            isAnnouncement: false,
            reactions: [MessageReaction(type: .fire, count: 15), MessageReaction(type: .clap, count: 22)],
            replyTo: nil,
            attachmentType: nil
        ),
    ]
}

struct MessageReaction: Codable {
    let type: ReactionType
    var count: Int

    enum ReactionType: String, Codable, CaseIterable {
        case fire = "🔥"
        case clap = "👏"
        case heart = "❤️"
        case muscle = "💪"
        case star = "⭐️"
    }
}

// MARK: - Poll Model
struct TeamPoll: Identifiable {
    let id: UUID
    let question: String
    let options: [PollOption]
    let createdBy: String
    let createdAt: Date
    let endsAt: Date
    var totalVotes: Int

    struct PollOption: Identifiable {
        let id: UUID
        let text: String
        var votes: Int
        var hasVoted: Bool
    }

    static let preview = TeamPoll(
        id: UUID(),
        question: "What time works best for live sessions?",
        options: [
            PollOption(id: UUID(), text: "6 AM", votes: 45, hasVoted: false),
            PollOption(id: UUID(), text: "7 AM", votes: 82, hasVoted: true),
            PollOption(id: UUID(), text: "6 PM", votes: 67, hasVoted: false),
            PollOption(id: UUID(), text: "8 PM", votes: 31, hasVoted: false),
        ],
        createdBy: "Coach Tom",
        createdAt: Date().addingTimeInterval(-86400),
        endsAt: Date().addingTimeInterval(86400 * 2),
        totalVotes: 225
    )
}

// MARK: - Team Chat View
struct TeamChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var messageText = ""
    @State private var showReactionPicker = false
    @State private var selectedMessage: ChatMessage?
    @State private var showPoll = false
    @State private var showCoachMenu = false

    private let messages = ChatMessage.previewMessages
    private let pinnedMessages: [ChatMessage] = ChatMessage.previewMessages.filter { $0.isPinned }
    private let activePoll = TeamPoll.preview

    var body: some View {
        VStack(spacing: 0) {
            // Header
            teamHeader

            // Content based on tab
            Group {
                switch selectedTab {
                case 0:
                    chatContent
                case 1:
                    TeamActivityFeed()
                case 2:
                    SelfieWallView()
                case 3:
                    LeaderboardView()
                default:
                    chatContent
                }
            }
        }
        .background(Color.bgPrimary)
        .ignoresSafeArea(.all, edges: .top)
    }

    private var teamHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Team avatar
                ZStack {
                    Circle()
                        .fill(FLEKKSGradients.avatarGradient)
                        .frame(width: 52, height: 52)

                    Text("BP")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.bgPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text("Team Bulletproof")
                            .font(FLEKKSFonts.bodySemibold(18))
                            .foregroundColor(.textPrimary)

                        // Live indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.accent)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.accent)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentGlow)
                        .clipShape(Capsule())
                    }

                    Text("847 members • 23 online")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Button(action: { showCoachMenu = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)

            // Enhanced Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ChatTabButton(title: "Chat", icon: "bubble.left.fill", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    ChatTabButton(title: "Activity", icon: "bolt.fill", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    ChatTabButton(title: "Selfies", icon: "camera.fill", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    ChatTabButton(title: "Leaderboard", icon: "trophy.fill", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
        }
        .background(Color.bgCard)
        .overlay(
            Rectangle()
                .fill(Color.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var chatContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    // Pinned messages
                    if !pinnedMessages.isEmpty {
                        PinnedMessagesSection(messages: pinnedMessages)
                    }

                    // Active Poll
                    if showPoll {
                        PollCard(poll: activePoll)
                    }

                    // Coach Announcement Banner
                    if let announcement = messages.first(where: { $0.isAnnouncement }) {
                        AnnouncementBanner(message: announcement)
                    }

                    // Messages
                    ForEach(messages.filter { !$0.isAnnouncement }) { message in
                        EnhancedChatBubble(
                            message: message,
                            onReact: { selectedMessage = message; showReactionPicker = true },
                            onReply: { /* Handle reply */ }
                        )
                    }
                }
                .padding(20)
                .padding(.bottom, 80)
            }

            // Enhanced Input area
            chatInputArea
        }
    }

    private var chatInputArea: some View {
        VStack(spacing: 0) {
            // Quick actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionPill(icon: "camera.fill", label: "Photo") {
                        // Open camera
                    }
                    QuickActionPill(icon: "flame.fill", label: "Cheer") {
                        // Send cheer
                    }
                    QuickActionPill(icon: "chart.bar.fill", label: "Poll") {
                        showPoll.toggle()
                    }
                    QuickActionPill(icon: "play.rectangle.fill", label: "Session") {
                        // Share session
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }

            // Text input
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.textMuted)
                }

                TextField("Message your team...", text: $messageText)
                    .font(FLEKKSFonts.body(15))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(messageText.isEmpty ? .bgElevated : .accent)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .padding(.bottom, 80)
            .background(Color.bgPrimary)
            .overlay(
                Rectangle()
                    .fill(Color.border)
                    .frame(height: 1),
                alignment: .top
            )
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        // Would send message to backend
        messageText = ""
    }
}

// MARK: - Chat Tab Button
struct ChatTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(FLEKKSFonts.labelMedium)
            }
            .foregroundColor(isSelected ? .bgPrimary : .textMuted)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Pinned Messages Section
struct PinnedMessagesSection: View {
    let messages: [ChatMessage]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 8) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.flekksOrange)

                    Text("Pinned Messages")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textSecondary)

                    Text("(\(messages.count))")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.textMuted)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(messages) { message in
                        PinnedMessageRow(message: message)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.flekksOrange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.flekksOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PinnedMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack(spacing: 10) {
            Text(message.senderInitials)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.flekksOrange)
                .frame(width: 28, height: 28)
                .background(Color.flekksOrange.opacity(0.2))
                .clipShape(Circle())

            Text(message.text)
                .font(FLEKKSFonts.body(13))
                .foregroundColor(.textSecondary)
                .lineLimit(2)

            Spacer()
        }
        .padding(10)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Announcement Banner
struct AnnouncementBanner: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.accent)

                Text("COACH ANNOUNCEMENT")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.accent)
                    .tracking(1.5)

                Spacer()

                Text(formatTime(message.timestamp))
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }

            Text(message.text)
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textPrimary)
                .lineSpacing(4)

            // Reactions
            if !message.reactions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(message.reactions, id: \.type) { reaction in
                        HStack(spacing: 4) {
                            Text(reaction.type.rawValue)
                                .font(.system(size: 14))
                            Text("\(reaction.count)")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.bgElevated)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                Color.bgCard
                FLEKKSGradients.tealGlow.opacity(0.3)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradient, lineWidth: 1.5)
        )
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Poll Card
struct PollCard: View {
    let poll: TeamPoll
    @State private var selectedOption: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.flekksOrange)

                Text("TEAM POLL")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.flekksOrange)
                    .tracking(1.5)

                Spacer()

                Text("\(poll.totalVotes) votes")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }

            // Question
            Text(poll.question)
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            // Options
            VStack(spacing: 10) {
                ForEach(poll.options) { option in
                    PollOptionRow(
                        option: option,
                        totalVotes: poll.totalVotes,
                        isSelected: selectedOption == option.id || option.hasVoted,
                        onSelect: { selectedOption = option.id }
                    )
                }
            }

            // Footer
            HStack {
                Text("By \(poll.createdBy)")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)

                Spacer()

                Text("Ends in 2 days")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.flekksOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PollOptionRow: View {
    let option: TeamPoll.PollOption
    let totalVotes: Int
    let isSelected: Bool
    let onSelect: () -> Void

    private var percentage: Double {
        guard totalVotes > 0 else { return 0 }
        return Double(option.votes) / Double(totalVotes)
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .leading) {
                // Background progress
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accent.opacity(0.2) : Color.bgElevated)
                        .frame(width: geometry.size.width * percentage)
                }

                HStack {
                    // Radio button
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.accent : Color.textMuted, lineWidth: 2)
                            .frame(width: 20, height: 20)

                        if isSelected {
                            Circle()
                                .fill(Color.accent)
                                .frame(width: 12, height: 12)
                        }
                    }

                    Text(option.text)
                        .font(FLEKKSFonts.bodyMedium(14))
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("\(Int(percentage * 100))%")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(isSelected ? .accent : .textSecondary)
                }
                .padding(12)
            }
            .frame(height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accent.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Enhanced Chat Bubble
struct EnhancedChatBubble: View {
    let message: ChatMessage
    let onReact: () -> Void
    let onReply: () -> Void

    @State private var showActions = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(message.isCoach ? FLEKKSGradients.avatarGradient : Color.bgElevated)
                    .frame(width: 40, height: 40)

                Text(message.senderInitials)
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(message.isCoach ? .bgPrimary : .textSecondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                // Name and badge
                HStack(spacing: 6) {
                    Text(message.senderName)
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.textPrimary)

                    if message.isCoach {
                        Text("COACH")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.bgPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(FLEKKSGradients.buttonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    Text(formatTime(message.timestamp))
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                }

                // Message content
                Text(message.text)
                    .font(FLEKKSFonts.body(14))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)

                // Reactions
                if !message.reactions.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(message.reactions, id: \.type) { reaction in
                            HStack(spacing: 3) {
                                Text(reaction.type.rawValue)
                                    .font(.system(size: 12))
                                Text("\(reaction.count)")
                                    .font(FLEKKSFonts.labelSmall)
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.bgElevated)
                            .clipShape(Capsule())
                        }

                        // Add reaction button
                        Button(action: onReact) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 12))
                                .foregroundColor(.textMuted)
                                .frame(width: 26, height: 26)
                                .background(Color.bgElevated)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(14)
            .background(message.isCoach ? Color.accentGlow : Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .clipShape(
                .rect(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(message.isCoach ? Color.accent.opacity(0.3) : Color.clear, lineWidth: 1)
            )

            Spacer()
        }
        .contextMenu {
            Button(action: onReply) {
                Label("Reply", systemImage: "arrowshape.turn.up.left")
            }
            Button(action: onReact) {
                Label("React", systemImage: "face.smiling")
            }
            Button(action: {}) {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Quick Action Pill
struct QuickActionPill: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(FLEKKSFonts.labelSmall)
            }
            .foregroundColor(.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.bgCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TeamChatView()
        .environmentObject(AppState())
}
