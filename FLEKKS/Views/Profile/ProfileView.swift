import SwiftUI
import RevenueCat
import RevenueCatUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var revenueCat: RevenueCatService

    @State private var showSavedSessions = false
    @State private var showScheduledSessions = false
    @State private var showDownloads = false
    @State private var showSubscription = false
    @State private var showCustomerCenter = false

    private var userName: String {
        appState.currentUser?.name ?? "Alex"
    }

    private var userInitials: String {
        appState.currentUser?.avatarInitials ?? "A"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 14) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(FLEKKSGradients.avatarGradient)
                                .frame(width: 88, height: 88)

                            Text(userInitials)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.bgPrimary)
                        }

                        Text(userName)
                            .font(.custom("Georgia", size: 28))
                            .foregroundColor(.textPrimary)

                        Text("Member since Dec 2024")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)

                        // Stats row
                        HStack(spacing: 36) {
                            ProfileStat(value: "\(appState.currentUser?.totalSessions ?? 47)", label: "Sessions")
                            ProfileStat(value: "\(appState.currentStreak)", label: "Day Streak")
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
                        // Library section - NEW
                        SectionHeader(title: "YOUR LIBRARY")

                        ProfileMenuItemWithBadge(
                            icon: "bookmark.fill",
                            title: "Saved Sessions",
                            badgeCount: appState.savedSessions.count,
                            badgeColor: .accent
                        ) {
                            showSavedSessions = true
                        }

                        ProfileMenuItemWithBadge(
                            icon: "calendar",
                            title: "Scheduled",
                            badgeCount: appState.scheduledSessions.count,
                            badgeColor: .flekksOrange
                        ) {
                            showScheduledSessions = true
                        }

                        ProfileMenuItemWithBadge(
                            icon: "arrow.down.circle.fill",
                            title: "Downloads",
                            badgeCount: appState.downloadedSessions.count,
                            badgeColor: .accent
                        ) {
                            showDownloads = true
                        }

                        // Subscription section
                        SectionHeader(title: "SUBSCRIPTION")

                        SubscriptionStatusBanner {
                            if revenueCat.isSubscribed {
                                showCustomerCenter = true
                            } else {
                                showSubscription = true
                            }
                        }
                        .padding(.bottom, 10)

                        // Account section
                        SectionHeader(title: "ACCOUNT")

                        ProfileMenuItem(icon: "person.fill", title: "Edit Profile")
                        ProfileMenuItem(icon: "bell.fill", title: "Notifications")
                        ProfileMenuItem(icon: "gearshape.fill", title: "Preferences")

                        // Support section
                        SectionHeader(title: "SUPPORT")

                        ProfileMenuItem(icon: "questionmark.circle.fill", title: "Help Center")
                        ProfileMenuItem(icon: "envelope.fill", title: "Contact Us")
                        ProfileMenuItem(icon: "star.fill", title: "Rate FLEKKS")
                        ProfileMenuItem(icon: "doc.text.fill", title: "Terms & Privacy")

                        // Actions section
                        SectionHeader(title: "ACTIONS")

                        ProfileMenuItem(icon: "arrow.right.square.fill", title: "Log Out", isDestructive: true) {
                            appState.logout()
                        }

                        // Version info
                        Text("FLEKKS v1.0.0")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
            .background(Color.bgPrimary)
            .ignoresSafeArea(.all, edges: .top)
            .navigationBarHidden(true)
            .sheet(isPresented: $showSavedSessions) {
                NavigationView {
                    SavedSessionsView()
                        .environmentObject(appState)
                }
            }
            .sheet(isPresented: $showScheduledSessions) {
                NavigationView {
                    ScheduledSessionsView()
                        .environmentObject(appState)
                }
            }
            .sheet(isPresented: $showDownloads) {
                NavigationView {
                    DownloadsView()
                        .environmentObject(appState)
                }
            }
            // Subscription paywall sheet
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
                    .environmentObject(appState)
                    .environmentObject(revenueCat)
            }
            // Customer Center sheet (for managing subscription)
            .sheet(isPresented: $showCustomerCenter) {
                CustomerCenterView()
            }
        }
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

// MARK: - Profile Menu Item with Badge
struct ProfileMenuItemWithBadge: View {
    let icon: String
    let title: String
    var badgeCount: Int = 0
    var badgeColor: Color = .accent
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(badgeColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(badgeColor)
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)

                Spacer()

                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(badgeColor.opacity(0.15))
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
            .padding(14)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 10)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
        .environmentObject(RevenueCatService.shared)
}
