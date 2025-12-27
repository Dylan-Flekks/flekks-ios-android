import SwiftUI

struct TeamChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var messageText = ""

    private let messages = ChatMessage.previewMessages

    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                        Text("Team Bulletproof")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)

                        Text("847 members • 23 online")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 16)

                // Tabs
                HStack(spacing: 6) {
                    TabButton(title: "Chat", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "Members", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButton(title: "Leaderboard", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color.bgCard)
            .overlay(
                Rectangle()
                    .fill(Color.border)
                    .frame(height: 1),
                alignment: .bottom
            )

            // Chat messages
            ScrollView {
                VStack(spacing: 18) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(20)
                .padding(.bottom, 80)
            }

            // Input area
            HStack(spacing: 12) {
                TextField("Message your team...", text: $messageText)
                    .font(.system(size: 15))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Button(action: {}) {
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
        .background(Color.bgPrimary)
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .accent : .textMuted)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .fill(isSelected ? Color.accent : Color.clear)
                        .frame(height: 2),
                    alignment: .bottom
                )
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(message.isCoach ? FLEKKSGradients.avatarGradient : Color.bgElevated)
                    .frame(width: 36, height: 36)

                Text(message.senderInitials)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(message.isCoach ? .bgPrimary : .textSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                // Name and badge
                HStack(spacing: 6) {
                    Text(message.senderName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    if message.isCoach {
                        Text("COACH")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.bgPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                // Message
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)

                // Time
                Text(formatTime(message.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(.textMuted)
            }
            .padding(12)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .clipShape(
                .rect(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
            )

            Spacer()
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    TeamChatView()
        .environmentObject(AppState())
}
