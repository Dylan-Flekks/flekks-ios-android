import SwiftUI

// MARK: - Subscription Plan
struct SubscriptionPlan: Identifiable {
    let id = UUID()
    let name: String
    let monthlyPrice: Double
    let billingPeriod: BillingPeriod
    let features: [String]
    let isPopular: Bool
    let savingsPercentage: Int?

    enum BillingPeriod: String {
        case monthly = "month"
        case yearly = "year"

        var displayName: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Annual"
            }
        }
    }

    var pricePerMonth: Double {
        switch billingPeriod {
        case .monthly: return monthlyPrice
        case .yearly: return monthlyPrice / 12
        }
    }

    var totalPrice: Double {
        monthlyPrice
    }

    static let plans: [SubscriptionPlan] = [
        SubscriptionPlan(
            name: "Monthly",
            monthlyPrice: 29.99,
            billingPeriod: .monthly,
            features: [
                "Unlimited access to all sessions",
                "Join any coach's team",
                "Track your progress",
                "Weekly challenges & badges",
                "Team chat & community"
            ],
            isPopular: false,
            savingsPercentage: nil
        ),
        SubscriptionPlan(
            name: "Annual",
            monthlyPrice: 199.99,
            billingPeriod: .yearly,
            features: [
                "Everything in Monthly, plus:",
                "Save 44% vs monthly",
                "Priority coach support",
                "Exclusive content drops",
                "Streak protection (2x/month)"
            ],
            isPopular: true,
            savingsPercentage: 44
        )
    ]
}

// MARK: - Subscription View
struct SubscriptionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: SubscriptionPlan = SubscriptionPlan.plans[1]
    @State private var isProcessing = false
    @State private var showTerms = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection

                    // Plan Selection
                    planSelectionSection

                    // Features List
                    featuresSection

                    // Social Proof
                    socialProofSection

                    // CTA Button
                    subscribeButton

                    // Terms
                    termsSection

                    Spacer(minLength: 40)
                }
                .padding(20)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Color.bgElevated)
                            .clipShape(Circle())
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Logo
            Text("FLĒKKS")
                .font(FLEKKSFonts.headingHeavy(32))
                .foregroundStyle(FLEKKSGradients.accentGradientVibrant)

            Text("Unlock Your Full Flexibility")
                .font(FLEKKSFonts.heading(24))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            Text("Train with world-class coaches and transform your mobility")
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 40)
    }

    private var planSelectionSection: some View {
        VStack(spacing: 14) {
            ForEach(SubscriptionPlan.plans) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan.id == plan.id,
                    onSelect: { selectedPlan = plan }
                )
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What You Get")
                .font(FLEKKSFonts.titleSmall)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                FeatureRow(icon: "play.rectangle.fill", title: "500+ Sessions", subtitle: "New content added weekly")
                FeatureRow(icon: "person.2.fill", title: "Expert Coaches", subtitle: "Learn from certified professionals")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", subtitle: "See your flexibility improve")
                FeatureRow(icon: "trophy.fill", title: "Challenges & Badges", subtitle: "Stay motivated with rewards")
                FeatureRow(icon: "bubble.left.and.bubble.right.fill", title: "Team Community", subtitle: "Train together, grow together")
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

    private var socialProofSection: some View {
        VStack(spacing: 16) {
            // Stats
            HStack(spacing: 20) {
                SocialProofStat(value: "50K+", label: "Members")
                SocialProofStat(value: "4.9", label: "App Rating", icon: "star.fill")
                SocialProofStat(value: "1M+", label: "Sessions")
            }

            // Testimonial
            VStack(spacing: 12) {
                Text("\"FLĒKKS changed my life. I went from barely touching my toes to doing full splits in 6 months!\"")
                    .font(FLEKKSFonts.body(14))
                    .foregroundColor(.textSecondary)
                    .italic()
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    Circle()
                        .fill(FLEKKSGradients.avatarGradient)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("S")
                                .font(FLEKKSFonts.bodySemibold(14))
                                .foregroundColor(.bgPrimary)
                        )

                    Text("Sarah M.")
                        .font(FLEKKSFonts.bodySemibold(13))
                        .foregroundColor(.textPrimary)

                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.flekksOrange)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private var subscribeButton: some View {
        VStack(spacing: 12) {
            Button(action: subscribe) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .bgPrimary))
                    } else {
                        Text("Start 7-Day Free Trial")
                            .font(FLEKKSFonts.bodySemibold(16))
                    }
                }
            }
            .buttonStyle(TealGlowButtonStyle())
            .disabled(isProcessing)

            Text("Then \(selectedPlan.billingPeriod == .yearly ? "$16.67/month" : "$29.99/month") • Cancel anytime")
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)
        }
    }

    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("By subscribing, you agree to our")
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)

            HStack(spacing: 16) {
                Button("Terms of Service") {
                    showTerms = true
                }
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.accent)

                Button("Privacy Policy") {
                    showTerms = true
                }
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.accent)

                Button("Restore Purchases") {
                    restorePurchases()
                }
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.accent)
            }
        }
    }

    private func subscribe() {
        isProcessing = true
        // Would integrate with StoreKit here
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            dismiss()
        }
    }

    private func restorePurchases() {
        // Would restore purchases via StoreKit
        print("Restoring purchases")
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Popular badge
                if plan.isPopular {
                    HStack {
                        Spacer()
                        Text("MOST POPULAR")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.bgPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(FLEKKSGradients.buttonGradient)
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.top, -12)
                }

                HStack(spacing: 16) {
                    // Radio button
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.accent : Color.textMuted, lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Circle()
                                .fill(Color.accent)
                                .frame(width: 14, height: 14)
                        }
                    }

                    // Plan info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(plan.name)
                                .font(FLEKKSFonts.bodySemibold(16))
                                .foregroundColor(.textPrimary)

                            if let savings = plan.savingsPercentage {
                                Text("Save \(savings)%")
                                    .font(FLEKKSFonts.labelSmall)
                                    .foregroundColor(.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentGlow)
                                    .clipShape(Capsule())
                            }
                        }

                        if plan.billingPeriod == .yearly {
                            Text("$16.67/month, billed annually")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)
                        } else {
                            Text("Billed monthly")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)
                        }
                    }

                    Spacer()

                    // Price
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(String(format: "%.2f", plan.totalPrice))")
                            .font(FLEKKSFonts.headingHeavy(22))
                            .foregroundColor(.textPrimary)

                        Text("/\(plan.billingPeriod.rawValue)")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                    }
                }
                .padding(20)
            }
            .background(isSelected ? Color.accentGlow : Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(FLEKKSGradients.iconGradient)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FLEKKSFonts.bodySemibold(14))
                    .foregroundColor(.textPrimary)

                Text(subtitle)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.accent)
        }
        .padding(12)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Social Proof Stat
struct SocialProofStat: View {
    let value: String
    let label: String
    var icon: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.flekksOrange)
                }

                Text(value)
                    .font(FLEKKSFonts.headingHeavy(22))
                    .foregroundColor(.textPrimary)
            }

            Text(label)
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Paywall View (for feature-gating)
struct PaywallView: View {
    let feature: String
    var onSubscribe: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Lock icon
            ZStack {
                Circle()
                    .fill(FLEKKSGradients.tealGlow)
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)

                Circle()
                    .fill(Color.bgCard)
                    .frame(width: 100, height: 100)

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(FLEKKSGradients.iconGradient)
            }

            VStack(spacing: 8) {
                Text("Premium Feature")
                    .font(FLEKKSFonts.heading(24))
                    .foregroundColor(.textPrimary)

                Text("\(feature) requires a FLĒKKS subscription")
                    .font(FLEKKSFonts.body(15))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onSubscribe) {
                    Text("Unlock with Premium")
                        .font(FLEKKSFonts.bodySemibold(16))
                }
                .buttonStyle(TealGlowButtonStyle())

                Button(action: onDismiss) {
                    Text("Maybe Later")
                        .font(FLEKKSFonts.bodyMedium(14))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.bgPrimary)
    }
}

// MARK: - Subscription Status Banner
struct SubscriptionStatusBanner: View {
    let isSubscribed: Bool
    let expiryDate: Date?
    var onManage: () -> Void

    private var daysRemaining: Int {
        guard let expiry = expiryDate else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0)
    }

    var body: some View {
        Button(action: onManage) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSubscribed ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                        .frame(width: 44, height: 44)

                    Image(systemName: isSubscribed ? "checkmark.seal.fill" : "crown")
                        .font(.system(size: 20))
                        .foregroundColor(isSubscribed ? .bgPrimary : .flekksOrange)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    if isSubscribed {
                        Text("FLĒKKS Premium")
                            .font(FLEKKSFonts.bodySemibold(15))
                            .foregroundColor(.textPrimary)

                        if daysRemaining > 0 {
                            Text("Renews in \(daysRemaining) days")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                        }
                    } else {
                        Text("Upgrade to Premium")
                            .font(FLEKKSFonts.bodySemibold(15))
                            .foregroundColor(.textPrimary)

                        Text("Unlock all features")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                    }
                }

                Spacer()

                if !isSubscribed {
                    Text("7 days free")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentGlow)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textMuted)
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSubscribed ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AppState())
}
