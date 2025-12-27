import SwiftUI

// MARK: - Selfie Model
struct WorkoutSelfie: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let teamId: UUID
    let sessionId: UUID?
    let imageData: Data?
    let caption: String?
    let createdAt: Date

    // Joined data
    var userName: String = ""
    var userInitials: String = ""
    var sessionTitle: String?
    var cheersCount: Int = 0
    var hasCheered: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, caption
        case userId = "user_id"
        case teamId = "team_id"
        case sessionId = "session_id"
        case imageData = "image_data"
        case createdAt = "created_at"
    }

    static let preview: [WorkoutSelfie] = [
        WorkoutSelfie(
            id: UUID(),
            userId: UUID(),
            teamId: UUID(),
            sessionId: UUID(),
            imageData: nil,
            caption: "Day 5 done! Feeling the burn 🔥",
            createdAt: Date().addingTimeInterval(-3600),
            userName: "Sarah M.",
            userInitials: "SM",
            sessionTitle: "Hip Hinge Mastery",
            cheersCount: 12,
            hasCheered: false
        ),
        WorkoutSelfie(
            id: UUID(),
            userId: UUID(),
            teamId: UUID(),
            sessionId: UUID(),
            imageData: nil,
            caption: "Week 2 complete! 💪",
            createdAt: Date().addingTimeInterval(-7200),
            userName: "Mike R.",
            userInitials: "MR",
            sessionTitle: "Core Activation",
            cheersCount: 8,
            hasCheered: true
        ),
        WorkoutSelfie(
            id: UUID(),
            userId: UUID(),
            teamId: UUID(),
            sessionId: UUID(),
            imageData: nil,
            caption: nil,
            createdAt: Date().addingTimeInterval(-14400),
            userName: "Emily K.",
            userInitials: "EK",
            sessionTitle: "Spine Decompression",
            cheersCount: 5,
            hasCheered: false
        ),
    ]
}

// MARK: - Selfie Wall View
struct SelfieWallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selfies: [WorkoutSelfie] = WorkoutSelfie.preview
    @State private var showCamera = false
    @State private var selectedSelfie: WorkoutSelfie?

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Stats Header
                    HStack(spacing: 20) {
                        SelfieStatBox(value: "\(selfies.count)", label: "Photos", icon: "camera.fill")
                        SelfieStatBox(value: "\(totalCheers)", label: "Cheers", icon: "hands.clap.fill")
                    }
                    .padding(.horizontal, 20)

                    // Grid
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(selfies) { selfie in
                            SelfieGridItem(selfie: selfie)
                                .onTapGesture {
                                    selectedSelfie = selfie
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.top, 10)
                .padding(.bottom, 100)
            }

            // Floating camera button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showCamera = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.bgPrimary)
                            .frame(width: 60, height: 60)
                            .background(FLEKKSGradients.buttonGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.accent.opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Selfie Wall")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedSelfie) { selfie in
            SelfieDetailView(selfie: selfie)
        }
        .sheet(isPresented: $showCamera) {
            PostWorkoutSelfieCapture { newSelfie in
                selfies.insert(newSelfie, at: 0)
            }
            .environmentObject(appState)
        }
    }

    private var totalCheers: Int {
        selfies.reduce(0) { $0 + $1.cheersCount }
    }
}

// MARK: - Selfie Stat Box
struct SelfieStatBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(FLEKKSGradients.iconGradient)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(FLEKKSFonts.headingHeavy(22))
                    .foregroundColor(.textPrimary)
                Text(label)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Selfie Grid Item
struct SelfieGridItem: View {
    let selfie: WorkoutSelfie

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder gradient (would be actual image)
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hue: Double.random(in: 0...1), saturation: 0.3, brightness: 0.3),
                        Color(hue: Double.random(in: 0...1), saturation: 0.2, brightness: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Avatar placeholder
                VStack(spacing: 8) {
                    AvatarView(initials: selfie.userInitials, size: 50)
                    Text("📸")
                        .font(.system(size: 24))
                }
            }
            .aspectRatio(1, contentMode: .fill)

            // Overlay info
            VStack(alignment: .leading, spacing: 4) {
                Spacer()

                // User name
                Text(selfie.userName)
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.white)

                // Cheers count
                if selfie.cheersCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "hands.clap.fill")
                            .font(.system(size: 10))
                        Text("\(selfie.cheersCount)")
                            .font(FLEKKSFonts.labelSmall)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.6), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Selfie Detail View
struct SelfieDetailView: View {
    let selfie: WorkoutSelfie

    @State private var hasCheered: Bool
    @State private var cheerCount: Int

    init(selfie: WorkoutSelfie) {
        self.selfie = selfie
        _hasCheered = State(initialValue: selfie.hasCheered)
        _cheerCount = State(initialValue: selfie.cheersCount)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Image (placeholder)
                        ZStack {
                            LinearGradient(
                                colors: [Color.tealDeep, Color.bgCard],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack(spacing: 16) {
                                AvatarView(initials: selfie.userInitials, size: 80)
                                Text("📸")
                                    .font(.system(size: 48))
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)

                        // User info
                        VStack(spacing: 12) {
                            HStack {
                                AvatarView(initials: selfie.userInitials, size: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selfie.userName)
                                        .font(FLEKKSFonts.bodySemibold(16))
                                        .foregroundColor(.textPrimary)

                                    if let sessionTitle = selfie.sessionTitle {
                                        Text("Completed \(sessionTitle)")
                                            .font(FLEKKSFonts.body(13))
                                            .foregroundColor(.textSecondary)
                                    }
                                }

                                Spacer()

                                Text(timeAgo(selfie.createdAt))
                                    .font(FLEKKSFonts.labelSmall)
                                    .foregroundColor(.textMuted)
                            }

                            if let caption = selfie.caption {
                                Text(caption)
                                    .font(FLEKKSFonts.body(15))
                                    .foregroundColor(.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Action row
                            HStack(spacing: 20) {
                                Button(action: sendCheer) {
                                    HStack(spacing: 8) {
                                        Image(systemName: hasCheered ? "hands.clap.fill" : "hands.clap")
                                            .font(.system(size: 18))
                                        Text("\(cheerCount)")
                                            .font(FLEKKSFonts.bodySemibold(15))
                                    }
                                    .foregroundColor(hasCheered ? .accent : .textSecondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(hasCheered ? Color.accentGlowStrong : Color.bgElevated)
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                .disabled(hasCheered)

                                Spacer()

                                Button(action: {}) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18))
                                        .foregroundColor(.textSecondary)
                                        .frame(width: 44, height: 44)
                                        .background(Color.bgElevated)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {}
                        .foregroundColor(.accent)
                }
            }
        }
    }

    private func sendCheer() {
        guard !hasCheered else { return }
        hasCheered = true
        cheerCount += 1

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}

// MARK: - Post Workout Selfie Capture
struct PostWorkoutSelfieCapture: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let onCapture: (WorkoutSelfie) -> Void

    @State private var caption: String = ""
    @State private var showCamera = false
    @State private var capturedImage: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Camera preview / captured image placeholder
                    ZStack {
                        if capturedImage {
                            // Captured image placeholder
                            ZStack {
                                LinearGradient(
                                    colors: [Color.tealMid.opacity(0.3), Color.bgCard],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )

                                VStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.accent)
                                    Text("Photo captured!")
                                        .font(FLEKKSFonts.bodyMedium(16))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        } else {
                            // Camera preview placeholder
                            ZStack {
                                Color.bgCard

                                VStack(spacing: 16) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 48))
                                        .foregroundStyle(FLEKKSGradients.iconGradient)

                                    Text("Tap to take selfie")
                                        .font(FLEKKSFonts.bodyMedium(16))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .onTapGesture {
                                // Simulate camera capture
                                withAnimation(.spring()) {
                                    capturedImage = true
                                }
                            }
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(capturedImage ? FLEKKSGradients.borderGradient : Color.border, lineWidth: 2)
                    )
                    .padding(.horizontal, 40)

                    // Caption input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a caption")
                            .font(FLEKKSFonts.labelMedium)
                            .foregroundColor(.textSecondary)

                        TextField("How are you feeling?", text: $caption)
                            .font(FLEKKSFonts.body(16))
                            .foregroundColor(.textPrimary)
                            .padding(16)
                            .background(Color.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Action buttons
                    VStack(spacing: 12) {
                        if capturedImage {
                            Button(action: postSelfie) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Post to Selfie Wall")
                                }
                            }
                            .buttonStyle(TealGlowButtonStyle())

                            Button(action: {
                                capturedImage = false
                            }) {
                                Text("Retake")
                                    .font(FLEKKSFonts.bodySemibold(15))
                                    .foregroundColor(.textSecondary)
                            }
                        } else {
                            Button(action: {
                                capturedImage = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 18))
                                    Text("Take Selfie")
                                }
                            }
                            .buttonStyle(TealGlowButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Post-Workout Selfie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private func postSelfie() {
        let newSelfie = WorkoutSelfie(
            id: UUID(),
            userId: appState.currentUser?.id ?? UUID(),
            teamId: appState.selectedTeam?.id ?? UUID(),
            sessionId: appState.currentSession?.id,
            imageData: nil,
            caption: caption.isEmpty ? nil : caption,
            createdAt: Date(),
            userName: appState.currentUser?.name ?? "You",
            userInitials: appState.currentUser?.avatarInitials ?? "?",
            sessionTitle: appState.currentSession?.title,
            cheersCount: 0,
            hasCheered: false
        )

        onCapture(newSelfie)
        dismiss()
    }
}

#Preview {
    NavigationView {
        SelfieWallView()
            .environmentObject(AppState())
    }
}
