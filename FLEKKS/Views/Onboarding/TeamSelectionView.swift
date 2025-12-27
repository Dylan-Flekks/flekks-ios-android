import SwiftUI

struct TeamSelectionView: View {
    @EnvironmentObject var appState: AppState

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
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.accent)
                            .tracking(2)

                        Text("Choose your team")
                            .font(.custom("Georgia", size: 32))
                            .foregroundColor(.textPrimary)

                        Text("Join a coach and train with others on the same path")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.bottom, 28)

                    // Team cards
                    VStack(spacing: 16) {
                        ForEach(Team.allTeams) { team in
                            TeamCard(team: team) {
                                appState.selectTeam(team)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TeamCard: View {
    let team: Team
    let onTap: () -> Void

    var heroGradient: LinearGradient {
        switch team.heroGradient {
        case .green: return FLEKKSGradients.heroGreen
        case .purple: return FLEKKSGradients.heroPurple
        case .blue: return FLEKKSGradients.heroBlue
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Hero section
                ZStack(alignment: .topLeading) {
                    heroGradient
                        .frame(height: 100)

                    HStack {
                        // Live badge
                        if team.isLive {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.flekksGreen)
                                    .frame(width: 6, height: 6)
                                Text("LIVE")
                                    .font(.system(size: 10, weight: .semibold))
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
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.bgPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(12)
                }

                // Content
                VStack(alignment: .leading, spacing: 14) {
                    // Coach info
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(FLEKKSGradients.avatarGradient)
                                .frame(width: 44, height: 44)

                            Text(team.coach.avatarInitials)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.bgPrimary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(team.coach.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text(team.coach.credential)
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                    }

                    // Team name
                    Text(team.name)
                        .font(.custom("Georgia", size: 22))
                        .foregroundColor(.textPrimary)

                    // Description
                    Text(team.description)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)

                    // Stats
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 11))
                            Text("\(team.memberCount) members")
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.system(size: 11))
                            Text(team.focus)
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TeamSelectionView()
        .environmentObject(AppState())
}
