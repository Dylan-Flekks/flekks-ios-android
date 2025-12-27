import SwiftUI

// MARK: - Coach Splash Page
// Each coach has their own branded landing page
struct CoachSplashView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var coachService = CoachService.shared

    let coachId: UUID
    @State private var profile: CoachProfile?
    @State private var isLoading = true
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if isLoading {
                LoadingView()
            } else if let profile = profile {
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Section
                        CoachHeroSection(coach: profile.coach, isGlowing: $isGlowing)

                        // Stats Section
                        CoachStatsSection(stats: profile.stats)
                            .padding(.top, -40)
                            .zIndex(1)

                        // About Section
                        CoachAboutSection(coach: profile.coach)

                        // Teams Section
                        CoachTeamsSection(teams: profile.teams) { team in
                            Task {
                                try await coachService.joinTeam(teamId: team.id)
                                appState.selectedTeam = Team(
                                    id: team.id,
                                    name: team.name,
                                    description: team.description,
                                    coach: Coach(
                                        id: profile.coach.id,
                                        name: profile.coach.name,
                                        credential: profile.coach.credential,
                                        avatarInitials: initials(from: profile.coach.name),
                                        bio: profile.coach.bio
                                    ),
                                    memberCount: team.memberCount,
                                    matchPercentage: 94,
                                    heroGradient: .green,
                                    isLive: true,
                                    focus: team.focus
                                )
                                appState.currentScreen = .main
                            }
                        }

                        // Testimonials
                        CoachTestimonialsSection()

                        Spacer(minLength: 100)
                    }
                }

                // Fixed CTA at bottom
                VStack {
                    Spacer()
                    CoachCTAButton(teamName: profile.primaryTeam?.name ?? "Team") {
                        if let team = profile.primaryTeam {
                            Task {
                                try await coachService.joinTeam(teamId: team.id)
                                appState.currentScreen = .main
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadProfile()
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }

    private func loadProfile() {
        Task {
            do {
                profile = try await coachService.fetchCoachProfile(id: coachId)
                isLoading = false
            } catch {
                print("Failed to load coach profile: \(error)")
                isLoading = false
            }
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Hero Section
struct CoachHeroSection: View {
    let coach: DBCoach
    @Binding var isGlowing: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            FLEKKSGradients.heroTealVibrant
                .frame(height: 320)

            // Animated glow
            Circle()
                .fill(FLEKKSGradients.tealGlowIntense)
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(y: -50)
                .scaleEffect(isGlowing ? 1.1 : 1.0)
                .opacity(isGlowing ? 0.8 : 0.5)

            // Content
            VStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(FLEKKSGradients.avatarGradient)
                        .frame(width: 100, height: 100)

                    if let avatarUrl = coach.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Text(initials(from: coach.name))
                                .font(FLEKKSFonts.heading(32))
                                .foregroundColor(.bgPrimary)
                        }
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                    } else {
                        Text(initials(from: coach.name))
                            .font(FLEKKSFonts.heading(32))
                            .foregroundColor(.bgPrimary)
                    }
                }
                .shadow(color: Color.accent.opacity(0.5), radius: 20, x: 0, y: 10)

                // Name & Credential
                VStack(spacing: 4) {
                    Text(coach.name)
                        .font(FLEKKSFonts.heading(28))
                        .foregroundColor(.textPrimary)

                    Text(coach.credential)
                        .font(FLEKKSFonts.bodyMedium(14))
                        .foregroundStyle(FLEKKSGradients.accentGradient)
                }

                // Verified badge
                if coach.isVerified {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(FLEKKSGradients.accentGradient)
                        Text("Verified Coach")
                            .font(FLEKKSFonts.labelMedium)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.bgElevated)
                    .clipShape(Capsule())
                }
            }
            .padding(.bottom, 60)
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Stats Section
struct CoachStatsSection: View {
    let stats: CoachStats

    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: "\(stats.totalMembers)", label: "Members")
            Divider().background(Color.border).frame(height: 40)
            StatItem(value: stats.formattedRating, label: "Rating", icon: "star.fill")
            Divider().background(Color.border).frame(height: 40)
            StatItem(value: "\(stats.totalSessions)", label: "Sessions")
        }
        .padding(.vertical, 20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradient, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    var icon: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(FLEKKSGradients.accentGradient)
                }
                Text(value)
                    .font(FLEKKSFonts.heading(24))
                    .foregroundColor(.textPrimary)
            }
            Text(label)
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - About Section
struct CoachAboutSection: View {
    let coach: DBCoach

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT")
                .font(FLEKKSFonts.labelSmall)
                .foregroundStyle(FLEKKSGradients.accentGradient)
                .tracking(1.5)

            Text(coach.bio)
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}

// MARK: - Teams Section
struct CoachTeamsSection: View {
    let teams: [DBTeam]
    let onJoin: (DBTeam) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROGRAMS")
                .font(FLEKKSFonts.labelSmall)
                .foregroundStyle(FLEKKSGradients.accentGradient)
                .tracking(1.5)
                .padding(.horizontal, 20)

            ForEach(teams, id: \.id) { team in
                CoachTeamCard(team: team) {
                    onJoin(team)
                }
            }
        }
    }
}

struct CoachTeamCard: View {
    let team: DBTeam
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(FLEKKSFonts.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text(team.focus)
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundStyle(FLEKKSGradients.accentGradient)
                }

                Spacer()

                Button(action: onJoin) {
                    Text("Join")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.bgPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(FLEKKSGradients.buttonGradient)
                        .clipShape(Capsule())
                }
            }

            Text(team.description)
                .font(FLEKKSFonts.body(14))
                .foregroundColor(.textSecondary)
                .lineLimit(2)

            HStack(spacing: 16) {
                Label("\(team.memberCount) members", systemImage: "person.2.fill")
                Label("6 weeks", systemImage: "calendar")
            }
            .font(FLEKKSFonts.labelMedium)
            .foregroundColor(.textMuted)
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Testimonials Section
struct CoachTestimonialsSection: View {
    let testimonials = [
        ("Sarah M.", "My hips have never felt this good. Dr. Dylan's programming is next level.", "⭐️⭐️⭐️⭐️⭐️"),
        ("Mike R.", "Finally, a flexibility program that actually works. 3 weeks in and I can touch my toes!", "⭐️⭐️⭐️⭐️⭐️"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHAT MEMBERS SAY")
                .font(FLEKKSFonts.labelSmall)
                .foregroundStyle(FLEKKSGradients.accentGradient)
                .tracking(1.5)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(testimonials, id: \.0) { name, text, stars in
                        TestimonialCard(name: name, text: text, stars: stars)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 24)
    }
}

struct TestimonialCard: View {
    let name: String
    let text: String
    let stars: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(stars)
                .font(.system(size: 12))

            Text("\"\(text)\"")
                .font(FLEKKSFonts.body(14))
                .foregroundColor(.textSecondary)
                .italic()

            Text("— \(name)")
                .font(FLEKKSFonts.bodySemibold(13))
                .foregroundColor(.textPrimary)
        }
        .padding(20)
        .frame(width: 280)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

// MARK: - Fixed CTA Button
struct CoachCTAButton: View {
    let teamName: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("Join \(teamName)")
                    .font(FLEKKSFonts.bodySemibold(16))
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.bgPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(FLEKKSGradients.buttonGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.accent.opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .background(
            LinearGradient(
                colors: [Color.bgPrimary.opacity(0), Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .allowsHitTesting(false),
            alignment: .bottom
        )
    }
}

#Preview {
    CoachSplashView(coachId: UUID())
        .environmentObject(AppState())
}
