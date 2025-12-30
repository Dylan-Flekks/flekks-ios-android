import SwiftUI
import RevenueCat
import RevenueCatUI

// MARK: - Subscription View (Custom Paywall)
struct SubscriptionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var revenueCat: RevenueCatService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPackage: Package?
    @State private var isProcessing = false
    @State private var showTerms = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if revenueCat.isLoading && revenueCat.offerings == nil {
                loadingView
            } else if let offering = revenueCat.currentOffering {
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section
                        heroSection

                        // Plan Selection
                        planSelectionSection(offering: offering)

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
            } else {
                errorView
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
        .onAppear {
            // Select yearly package by default
            if selectedPackage == nil {
                selectedPackage = revenueCat.yearlyPackage ?? revenueCat.monthlyPackage
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accent)

            Text("Loading subscription options...")
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.flekksOrange)

            Text("Unable to load subscriptions")
                .font(FLEKKSFonts.heading(20))
                .foregroundColor(.textPrimary)

            Text("Please check your connection and try again")
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                Task {
                    await revenueCat.fetchOfferings()
                }
            }) {
                Text("Retry")
                    .font(FLEKKSFonts.bodySemibold(16))
            }
            .buttonStyle(TealGlowButtonStyle())
        }
        .padding(40)
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Logo
            Text("FLEKKS")
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

    // MARK: - Plan Selection Section
    private func planSelectionSection(offering: Offering) -> some View {
        VStack(spacing: 14) {
            // Yearly package (most popular)
            if let yearlyPackage = offering.annual ?? offering.package(identifier: "yearly") {
                RevenueCatPlanCard(
                    package: yearlyPackage,
                    isSelected: selectedPackage?.identifier == yearlyPackage.identifier,
                    isPopular: true,
                    onSelect: { selectedPackage = yearlyPackage }
                )
            }

            // Monthly package
            if let monthlyPackage = offering.monthly ?? offering.package(identifier: "monthly") {
                RevenueCatPlanCard(
                    package: monthlyPackage,
                    isSelected: selectedPackage?.identifier == monthlyPackage.identifier,
                    isPopular: false,
                    onSelect: { selectedPackage = monthlyPackage }
                )
            }
        }
    }

    // MARK: - Features Section
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

    // MARK: - Social Proof Section
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
                Text("\"FLEKKS changed my life. I went from barely touching my toes to doing full splits in 6 months!\"")
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

    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        VStack(spacing: 12) {
            Button(action: subscribe) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .bgPrimary))
                    } else {
                        Text(selectedPackage?.storeProduct.subscriptionPeriod?.hasFreeTrial == true
                             ? "Start Free Trial"
                             : "Subscribe Now")
                            .font(FLEKKSFonts.bodySemibold(16))
                    }
                }
            }
            .buttonStyle(TealGlowButtonStyle())
            .disabled(isProcessing || selectedPackage == nil)

            if let package = selectedPackage {
                Text(subscriptionDescription(for: package))
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
        }
    }

    // MARK: - Terms Section
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

                Button("Restore") {
                    restorePurchases()
                }
                .font(FLEKKSFonts.labelSmall)
                .foregroundColor(.accent)
            }
        }
    }

    // MARK: - Helper Methods
    private func subscriptionDescription(for package: Package) -> String {
        let price = package.storeProduct.localizedPriceString

        if package.packageType == .annual {
            return "Then \(package.localizedPricePerMonth)/month billed annually (\(price)/year) - Cancel anytime"
        } else {
            return "Then \(price)/month - Cancel anytime"
        }
    }

    private func subscribe() {
        guard let package = selectedPackage else { return }

        isProcessing = true

        Task {
            do {
                _ = try await revenueCat.purchase(package: package)
                await MainActor.run {
                    isProcessing = false
                    dismiss()
                }
            } catch RevenueCatError.cancelled {
                await MainActor.run {
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func restorePurchases() {
        isProcessing = true

        Task {
            do {
                let customerInfo = try await revenueCat.restorePurchases()
                await MainActor.run {
                    isProcessing = false
                    if customerInfo.entitlements[RevenueCatConfig.entitlementIdentifier]?.isActive == true {
                        dismiss()
                    } else {
                        errorMessage = "No active subscription found"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - RevenueCat Plan Card
struct RevenueCatPlanCard: View {
    let package: Package
    let isSelected: Bool
    let isPopular: Bool
    let onSelect: () -> Void

    private var isYearly: Bool {
        package.packageType == .annual
    }

    private var savingsText: String? {
        // Calculate savings compared to monthly
        if isYearly {
            return "Save 44%"
        }
        return nil
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Popular badge
                if isPopular {
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
                            Text(package.storeProduct.localizedTitle)
                                .font(FLEKKSFonts.bodySemibold(16))
                                .foregroundColor(.textPrimary)

                            if let savings = savingsText {
                                Text(savings)
                                    .font(FLEKKSFonts.labelSmall)
                                    .foregroundColor(.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentGlow)
                                    .clipShape(Capsule())
                            }
                        }

                        if isYearly {
                            Text("\(package.localizedPricePerMonth)/month, billed annually")
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
                        Text(package.storeProduct.localizedPriceString)
                            .font(FLEKKSFonts.headingHeavy(22))
                            .foregroundColor(.textPrimary)

                        Text("/\(isYearly ? "year" : "month")")
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

// MARK: - Paywall Feature Gate View
struct PaywallFeatureGateView: View {
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

                Text("\(feature) requires a FLEKKS subscription")
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
    @EnvironmentObject var revenueCat: RevenueCatService
    var onManage: () -> Void

    private var daysRemaining: Int {
        guard let expiry = revenueCat.expirationDate else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0)
    }

    var body: some View {
        Button(action: onManage) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(revenueCat.isSubscribed ? FLEKKSGradients.buttonGradient : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                        .frame(width: 44, height: 44)

                    Image(systemName: revenueCat.isSubscribed ? "checkmark.seal.fill" : "crown")
                        .font(.system(size: 20))
                        .foregroundColor(revenueCat.isSubscribed ? .bgPrimary : .flekksOrange)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    if revenueCat.isSubscribed {
                        Text("FLEKKS Premium")
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

                if !revenueCat.isSubscribed {
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
                    .stroke(revenueCat.isSubscribed ? FLEKKSGradients.borderGradient : FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - RevenueCat Native Paywall Wrapper
/// Use this to show RevenueCat's built-in paywall UI
struct RevenueCatPaywallSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView()
            .onPurchaseCompleted { _ in
                dismiss()
            }
            .onRestoreCompleted { _ in
                dismiss()
            }
    }
}

// MARK: - Customer Center Wrapper
/// Shows RevenueCat's Customer Center for subscription management
struct RevenueCatCustomerCenterSheet: View {
    var body: some View {
        CustomerCenterView()
    }
}

// MARK: - Premium Content Modifier
/// Use this modifier to gate premium content and automatically show paywall
struct PremiumContentModifier: ViewModifier {
    @EnvironmentObject var revenueCat: RevenueCatService
    @State private var showPaywall = false

    let featureName: String

    func body(content: Content) -> some View {
        Group {
            if revenueCat.isSubscribed {
                content
            } else {
                PaywallFeatureGateView(
                    feature: featureName,
                    onSubscribe: { showPaywall = true },
                    onDismiss: { }
                )
            }
        }
        .sheet(isPresented: $showPaywall) {
            RevenueCatPaywallSheet()
        }
    }
}

extension View {
    func requiresPremium(feature: String) -> some View {
        modifier(PremiumContentModifier(featureName: feature))
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AppState())
        .environmentObject(RevenueCatService.shared)
}
