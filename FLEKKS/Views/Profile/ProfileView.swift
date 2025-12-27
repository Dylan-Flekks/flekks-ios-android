import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 14) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(FLEKKSGradients.avatarGradient)
                            .frame(width: 88, height: 88)

                        Text("A")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.bgPrimary)
                    }

                    Text("Alex")
                        .font(.custom("Georgia", size: 28))
                        .foregroundColor(.textPrimary)

                    Text("Member since Dec 2024")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)

                    // Stats row
                    HStack(spacing: 36) {
                        ProfileStat(value: "47", label: "Sessions")
                        ProfileStat(value: "12", label: "Day Streak")
                        ProfileStat(value: "6", label: "Badges")
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .overlay(
                        Rectangle()
                            .fill(Color.border)
                            .frame(height: 1),
                        alignment: .top
                    )
                }
                .padding(.top, 60)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
                .background(Color.bgCard)
                .overlay(
                    Rectangle()
                        .fill(Color.border)
                        .frame(height: 1),
                    alignment: .bottom
                )

                // Menu sections
                VStack(alignment: .leading, spacing: 0) {
                    // Account section
                    SectionHeader(title: "ACCOUNT")

                    ProfileMenuItem(icon: "person.fill", title: "Edit Profile")
                    ProfileMenuItem(icon: "bell.fill", title: "Notifications")
                    ProfileMenuItem(icon: "creditcard.fill", title: "Subscription")

                    // Support section
                    SectionHeader(title: "SUPPORT")

                    ProfileMenuItem(icon: "questionmark.circle.fill", title: "Help Center")
                    ProfileMenuItem(icon: "envelope.fill", title: "Contact Us")
                    ProfileMenuItem(icon: "doc.text.fill", title: "Terms & Privacy")

                    // Actions section
                    SectionHeader(title: "ACTIONS")

                    ProfileMenuItem(icon: "arrow.right.square.fill", title: "Log Out", isDestructive: true) {
                        appState.logout()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color.bgPrimary)
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Georgia", size: 24))
                .foregroundColor(.accent)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.textSecondary)
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.textMuted)
            .tracking(1.5)
            .padding(.top, 24)
            .padding(.bottom, 12)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isDestructive ? .flekksRed : .textSecondary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isDestructive ? .flekksRed : .textPrimary)

                Spacer()

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textMuted)
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 10)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
