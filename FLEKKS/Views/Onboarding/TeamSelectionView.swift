import SwiftUI

struct TeamSelectionView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Back button
                    Button(action: {
                        appState.currentScreen = .quiz
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(GhostButtonStyle())
                    .padding(.top, 60)
                    .padding(.bottom, 16)

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR MATCHES")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundStyle(FLEKKSGradients.accentGradient)
                            .tracking(2)

                        Text("Choose your team")
                            .font(FLEKKSFonts.heading(32))
                            .foregroundColor(.textPrimary)

                        Text("Join a coach and train with others on the same path")
                            .font(FLEKKSFonts.body(14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.bottom, 28)

                    // Team cards
                    VStack(spacing: 16) {
                        ForEach(dataService.teams) { team in
                            TeamCard(team: team) {
                                appState.selectTeam(team)
                            } onCoachTap: {
                                if let coachId = team.coach?.id {
                                    appState.viewCoachProfile(coachId)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Task {
                await dataService.fetchTeams()
            }
        }
    }
}

struct TeamCard: View {
    let team: Team
    let onTap: () -> Void
    let onCoachTap: () -> Void

    var heroGradient: LinearGradient {
        switch team.heroGradient {
        case .green: return FLEKKSGradients.heroGreen
        case .purple: return FLEKKSGradients.heroPurple
        case .blue: return FLEKKSGradients.heroBlue
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Hero section
            ZStack(alignment: .topLeading) {
                heroGradient
                    .frame(height: 100)

                // Glow effect
                Circle()
                    .fill(FLEKKSGradients.tealGlowSoft)
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .offset(x: 200, y: -30)

                HStack {
                    // Live badge
                    if team.isLive {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.flekksGreen)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Spacer()

                    // Match percentage
                    Text("\(team.matchPercentage)% MATCH")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.bgPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(FLEKKSGradients.buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(12)
            }

            // Content
            VStack(alignment: .leading, spacing: 14) {
                // Coach info - tappable
                if let coach = team.coach {
                    Button(action: onCoachTap) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(FLEKKSGradients.avatarGradient)
                                    .frame(width: 44, height: 44)

                                Text(coach.avatarInitials)
                                    .font(FLEKKSFonts.labelMedium)
                                    .foregroundColor(.bgPrimary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(coach.name)
                                    .font(FLEKKSFonts.bodySemibold(15))
                                    .foregroundColor(.textPrimary)
                                Text(coach.credential)
                                    .font(FLEKKSFonts.body(12))
                                    .foregroundColor(.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.textMuted)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Team name
                Text(team.name)
                    .font(FLEKKSFonts.heading(22))
                    .foregroundColor(.textPrimary)

                // Description
                Text(team.description)
                    .font(FLEKKSFonts.body(14))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)

                // Stats
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(FLEKKSGradients.iconGradient)
                        Text("\(team.memberCount) members")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 11))
                            .foregroundStyle(FLEKKSGradients.iconGradient)
                        Text(team.focus)
                    }
                }
                .font(FLEKKSFonts.body(12))
                .foregroundColor(.textMuted)

                // Join button
                Button(action: onTap) {
                    Text("Join Team")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    TeamSelectionView()
        .environmentObject(AppState())
}
