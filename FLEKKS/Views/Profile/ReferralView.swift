import SwiftUI

// MARK: - Referral Model
struct Referral: Identifiable, Codable {
    let id: UUID
    let referrerId: UUID
    let referredUserId: UUID?
    let referredEmail: String?
    let status: ReferralStatus
    let createdAt: Date
    let completedAt: Date?
    let rewardClaimed: Bool

    enum ReferralStatus: String, Codable {
        case pending = "Pending"
        case signedUp = "Signed Up"
        case activated = "Activated"  // Completed first session
        case subscribed = "Subscribed"

        var color: Color {
            switch self {
            case .pending: return .textMuted
            case .signedUp: return .flekksOrange
            case .activated: return .accent
            case .subscribed: return .tealBright
            }
        }

        var icon: String {
            switch self {
            case .pending: return "clock"
            case .signedUp: return "person.badge.plus"
            case .activated: return "checkmark.circle"
            case .subscribed: return "star.circle.fill"
            }
        }
    }

    static let preview: [Referral] = [
        Referral(id: UUID(), referrerId: UUID(), referredUserId: UUID(), referredEmail: "sarah@example.com", status: .subscribed, createdAt: Date().addingTimeInterval(-86400 * 7), completedAt: Date().addingTimeInterval(-86400 * 3), rewardClaimed: true),
        Referral(id: UUID(), referrerId: UUID(), referredUserId: UUID(), referredEmail: "mike@example.com", status: .activated, createdAt: Date().addingTimeInterval(-86400 * 5), completedAt: Date().addingTimeInterval(-86400 * 2), rewardClaimed: true),
        Referral(id: UUID(), referrerId: UUID(), referredUserId: UUID(), referredEmail: "emma@example.com", status: .signedUp, createdAt: Date().addingTimeInterval(-86400 * 2), completedAt: nil, rewardClaimed: false),
        Referral(id: UUID(), referrerId: UUID(), referredUserId: nil, referredEmail: "john@example.com", status: .pending, createdAt: Date().addingTimeInterval(-86400), completedAt: nil, rewardClaimed: false),
    ]
}

// MARK: - Referral Reward Tier
struct ReferralRewardTier: Identifiable {
    let id = UUID()
    let referralsNeeded: Int
    let reward: String
    let rewardValue: String
    let icon: String

    static let tiers: [ReferralRewardTier] = [
        ReferralRewardTier(referralsNeeded: 1, reward: "1 Week Free", rewardValue: "$7.50", icon: "gift.fill"),
        ReferralRewardTier(referralsNeeded: 3, reward: "1 Month Free", rewardValue: "$29.99", icon: "calendar"),
        ReferralRewardTier(referralsNeeded: 5, reward: "3 Months Free", rewardValue: "$89.97", icon: "star.fill"),
        ReferralRewardTier(referralsNeeded: 10, reward: "1 Year Free", rewardValue: "$359.88", icon: "crown.fill"),
    ]
}

// MARK: - Referral View
struct ReferralView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var referralCode = "FLEKKS-ABC123"
    @State private var referralLink = "https://flekks.app/r/ABC123"
    @State private var referrals: [Referral] = Referral.preview
    @State private var showShareSheet = false
    @State private var copiedToClipboard = false

    private var completedReferrals: Int {
        referrals.filter { $0.status == .activated || $0.status == .subscribed }.count
    }

    private var pendingReferrals: Int {
        referrals.filter { $0.status == .pending || $0.status == .signedUp }.count
    }

    private var currentTier: ReferralRewardTier? {
        ReferralRewardTier.tiers.last { $0.referralsNeeded <= completedReferrals }
    }

    private var nextTier: ReferralRewardTier? {
        ReferralRewardTier.tiers.first { $0.referralsNeeded > completedReferrals }
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection

                    // Share Section
                    shareSection

                    // Reward Tiers
                    rewardTiersSection

                    // Referral History
                    if !referrals.isEmpty {
                        referralHistorySection
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Invite Friends")
        .navigationBarTitleDisplayMode(.large)
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            // Gift icon with glow
            ZStack {
                Circle()
                    .fill(FLEKKSGradients.tealGlowIntense)
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)

                Circle()
                    .fill(FLEKKSGradients.buttonGradient)
                    .frame(width: 100, height: 100)

                Image(systemName: "gift.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.bgPrimary)
            }

            VStack(spacing: 8) {
                Text("Give a Week, Get a Week")
                    .font(FLEKKSFonts.heading(24))
                    .foregroundColor(.textPrimary)

                Text("Invite friends to FLĒKKS and you both get a free week when they complete their first session")
                    .font(FLEKKSFonts.body(15))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Stats
            HStack(spacing: 20) {
                StatPill(value: "\(completedReferrals)", label: "Completed", color: .accent)
                StatPill(value: "\(pendingReferrals)", label: "Pending", color: .flekksOrange)
            }
        }
        .padding(24)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(FLEKKSGradients.borderGradient, lineWidth: 1)
        )
    }

    private var shareSection: some View {
        VStack(spacing: 16) {
            // Referral Code
            VStack(spacing: 10) {
                Text("Your Referral Code")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
                    .tracking(1.5)

                HStack(spacing: 12) {
                    Text(referralCode)
                        .font(FLEKKSFonts.headingHeavy(24))
                        .foregroundColor(.textPrimary)
                        .tracking(2)

                    Button(action: copyCode) {
                        Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 18))
                            .foregroundColor(copiedToClipboard ? .accent : .textSecondary)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Share Buttons
            VStack(spacing: 12) {
                Button(action: { showShareSheet = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share Invite Link")
                    }
                    .font(FLEKKSFonts.bodySemibold(16))
                }
                .buttonStyle(TealGlowButtonStyle())

                HStack(spacing: 12) {
                    ShareOptionButton(icon: "message.fill", label: "Message", color: .accent) {
                        shareViaMessage()
                    }

                    ShareOptionButton(icon: "envelope.fill", label: "Email", color: .flekksOrange) {
                        shareViaEmail()
                    }

                    ShareOptionButton(icon: "link", label: "Copy", color: .tealBright) {
                        copyLink()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private var rewardTiersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reward Milestones")
                .font(FLEKKSFonts.titleSmall)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                ForEach(ReferralRewardTier.tiers) { tier in
                    RewardTierRow(
                        tier: tier,
                        currentCount: completedReferrals,
                        isAchieved: completedReferrals >= tier.referralsNeeded
                    )
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private var referralHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Referrals")
                    .font(FLEKKSFonts.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(referrals.count) total")
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textMuted)
            }

            VStack(spacing: 12) {
                ForEach(referrals) { referral in
                    ReferralHistoryRow(referral: referral)
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    // MARK: - Actions
    private func copyCode() {
        UIPasteboard.general.string = referralCode
        withAnimation {
            copiedToClipboard = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedToClipboard = false
            }
        }
    }

    private func copyLink() {
        UIPasteboard.general.string = referralLink
        withAnimation {
            copiedToClipboard = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedToClipboard = false
            }
        }
    }

    private func shareViaMessage() {
        // Would open messages with pre-filled text
        print("Share via message")
    }

    private func shareViaEmail() {
        // Would open email composer
        print("Share via email")
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FLEKKSFonts.headingHeavy(28))
                .foregroundColor(color)

            Text(label)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Share Option Button
struct ShareOptionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Text(label)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reward Tier Row
struct RewardTierRow: View {
    let tier: ReferralRewardTier
    let currentCount: Int
    let isAchieved: Bool

    private var progress: Double {
        min(Double(currentCount) / Double(tier.referralsNeeded), 1.0)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(isAchieved ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                    .frame(width: 50, height: 50)

                if isAchieved {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.bgPrimary)
                } else {
                    Image(systemName: tier.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(FLEKKSGradients.iconGradient)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(tier.reward)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(isAchieved ? .accent : .textPrimary)

                    if isAchieved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accent)
                    }
                }

                if !isAchieved {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.bgElevated)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(FLEKKSGradients.progressGradient)
                                .frame(width: geometry.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }

            Spacer()

            // Referrals needed
            VStack(alignment: .trailing, spacing: 2) {
                if isAchieved {
                    Text(tier.rewardValue)
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.accent)

                    Text("Earned")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                } else {
                    Text("\(currentCount)/\(tier.referralsNeeded)")
                        .font(FLEKKSFonts.bodySemibold(14))
                        .foregroundColor(.textPrimary)

                    Text("referrals")
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                }
            }
        }
        .padding(14)
        .background(isAchieved ? Color.accentGlow : Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isAchieved ? Color.accent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Referral History Row
struct ReferralHistoryRow: View {
    let referral: Referral

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: referral.createdAt)
    }

    private var displayName: String {
        if let email = referral.referredEmail {
            return email.components(separatedBy: "@").first ?? email
        }
        return "Friend"
    }

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(referral.status.color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Text(displayName.prefix(1).uppercased())
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(referral.status.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(FLEKKSFonts.bodySemibold(14))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 6) {
                    Image(systemName: referral.status.icon)
                        .font(.system(size: 11))

                    Text(referral.status.rawValue)
                        .font(FLEKKSFonts.labelSmall)
                }
                .foregroundColor(referral.status.color)
            }

            Spacer()

            // Date and reward
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDate)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)

                if referral.rewardClaimed {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 10))
                        Text("+7 days")
                            .font(FLEKKSFonts.labelSmall)
                    }
                    .foregroundColor(.accent)
                }
            }
        }
        .padding(12)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Referral Banner (for use in other views)
struct ReferralBanner: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(FLEKKSGradients.buttonGradient)
                        .frame(width: 50, height: 50)

                    Image(systemName: "gift.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.bgPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Invite Friends, Get Free Time")
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)

                    Text("Share FLĒKKS and earn rewards")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textMuted)
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(FLEKKSGradients.borderGradient, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        ReferralView()
            .environmentObject(AppState())
    }
}
