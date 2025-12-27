import Foundation
import Supabase

// MARK: - Real-time Chat Service
@MainActor
class ChatService: ObservableObject {
    static let shared = ChatService()

    private let supabase = SupabaseService.shared
    private var messageChannel: RealtimeChannelV2?

    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Fetch Messages for Team
    func fetchMessages(teamId: UUID, limit: Int = 50) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            // Fetch messages with user data joined
            let dbMessages: [DBChatMessage] = try await supabase.client.database
                .from("chat_messages")
                .select("*, user:users(*)")
                .eq("team_id", value: teamId.uuidString)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value

            // Convert to app model
            self.messages = dbMessages.reversed().map { dbMessage in
                ChatMessage(
                    id: dbMessage.id,
                    senderName: dbMessage.user?.name ?? "Unknown",
                    senderInitials: initials(from: dbMessage.user?.name ?? "?"),
                    isCoach: false, // TODO: Check if user is coach
                    text: dbMessage.content,
                    timestamp: dbMessage.createdAt
                )
            }

        } catch {
            errorMessage = "Failed to load messages"
            throw error
        }
    }

    // MARK: - Send Message
    func sendMessage(teamId: UUID, content: String) async throws {
        guard let userId = supabase.currentUser?.id else {
            throw ChatError.notAuthenticated
        }

        let newMessage = DBChatMessage(
            id: UUID(),
            teamId: teamId,
            userId: userId,
            content: content,
            createdAt: Date(),
            user: nil
        )

        do {
            try await supabase.client.database
                .from("chat_messages")
                .insert(newMessage)
                .execute()
        } catch {
            errorMessage = "Failed to send message"
            throw error
        }
    }

    // MARK: - Subscribe to Real-time Messages
    func subscribeToMessages(teamId: UUID) async {
        // Unsubscribe from previous channel
        await unsubscribeFromMessages()

        do {
            messageChannel = await supabase.client.realtimeV2.channel("team-\(teamId.uuidString)")

            let insertions = await messageChannel!.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "chat_messages",
                filter: "team_id=eq.\(teamId.uuidString)"
            )

            await messageChannel!.subscribe()

            // Listen for new messages
            for await insertion in insertions {
                await handleNewMessage(insertion.record)
            }

        } catch {
            print("Failed to subscribe to messages: \(error)")
        }
    }

    // MARK: - Unsubscribe
    func unsubscribeFromMessages() async {
        if let channel = messageChannel {
            await channel.unsubscribe()
            messageChannel = nil
        }
    }

    // MARK: - Handle New Message
    private func handleNewMessage(_ record: [String: AnyJSON]) async {
        guard
            let idString = record["id"]?.stringValue,
            let id = UUID(uuidString: idString),
            let content = record["content"]?.stringValue,
            let userIdString = record["user_id"]?.stringValue,
            let userId = UUID(uuidString: userIdString)
        else { return }

        // Fetch user data
        do {
            let user: DBUser = try await supabase.client.database
                .from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value

            let message = ChatMessage(
                id: id,
                senderName: user.name,
                senderInitials: initials(from: user.name),
                isCoach: false, // TODO: Check coach status
                text: content,
                timestamp: Date()
            )

            await MainActor.run {
                self.messages.append(message)
            }

        } catch {
            print("Failed to fetch user for message: \(error)")
        }
    }

    // MARK: - Get Online Members
    func getOnlineMembers(teamId: UUID) async -> Int {
        // Use Supabase Presence for online tracking
        // This is a simplified version
        do {
            let channel = await supabase.client.realtimeV2.channel("presence-\(teamId.uuidString)")
            await channel.subscribe()

            // In a real implementation, you'd track presence state
            return 0
        } catch {
            return 0
        }
    }

    // MARK: - Helper
    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
}

// MARK: - Chat Errors
enum ChatError: LocalizedError {
    case notAuthenticated
    case sendFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to send messages."
        case .sendFailed:
            return "Failed to send message. Please try again."
        case .fetchFailed:
            return "Failed to load messages."
        }
    }
}

// MARK: - Typing Indicator (optional feature)
@MainActor
class TypingIndicator: ObservableObject {
    @Published var typingUsers: [String] = []

    private var typingTimer: Timer?
    private let supabase = SupabaseService.shared

    func startTyping(teamId: UUID, userName: String) async {
        // Broadcast typing state via presence
    }

    func stopTyping() {
        typingTimer?.invalidate()
        typingTimer = nil
    }

    var typingText: String? {
        guard !typingUsers.isEmpty else { return nil }

        if typingUsers.count == 1 {
            return "\(typingUsers[0]) is typing..."
        } else if typingUsers.count == 2 {
            return "\(typingUsers[0]) and \(typingUsers[1]) are typing..."
        } else {
            return "Several people are typing..."
        }
    }
}
