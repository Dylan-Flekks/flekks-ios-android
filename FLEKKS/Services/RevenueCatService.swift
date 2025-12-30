import Foundation
import RevenueCat
import RevenueCatUI

// MARK: - RevenueCat Configuration
enum RevenueCatConfig {
    static let apiKey = "test_VLLJFeLMhxehITVqNVrLnQmlNDS"
    static let entitlementIdentifier = "Health and Wellness Pro"

    // Product identifiers
    enum Products {
        static let monthly = "monthly"
        static let yearly = "yearly"
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: Equatable {
    case unknown
    case notSubscribed
    case subscribed(expirationDate: Date?, productIdentifier: String?)
    case expired

    var isActive: Bool {
        if case .subscribed = self {
            return true
        }
        return false
    }
}

// MARK: - RevenueCat Error
enum RevenueCatError: LocalizedError {
    case purchaseFailed(Error)
    case restoreFailed(Error)
    case customerInfoUnavailable
    case offeringsUnavailable
    case cancelled

    var errorDescription: String? {
        switch self {
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .restoreFailed(let error):
            return "Restore failed: \(error.localizedDescription)"
        case .customerInfoUnavailable:
            return "Unable to retrieve subscription information"
        case .offeringsUnavailable:
            return "Unable to load subscription options"
        case .cancelled:
            return "Purchase was cancelled"
        }
    }
}

// MARK: - RevenueCat Service
@MainActor
final class RevenueCatService: ObservableObject {
    static let shared = RevenueCatService()

    // MARK: - Published Properties
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .unknown
    @Published private(set) var customerInfo: CustomerInfo?
    @Published private(set) var offerings: Offerings?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Computed Properties
    var isSubscribed: Bool {
        subscriptionStatus.isActive
    }

    var hasProEntitlement: Bool {
        guard let customerInfo = customerInfo else { return false }
        return customerInfo.entitlements[RevenueCatConfig.entitlementIdentifier]?.isActive == true
    }

    var currentOffering: Offering? {
        offerings?.current
    }

    var monthlyPackage: Package? {
        currentOffering?.package(identifier: RevenueCatConfig.Products.monthly) ??
        currentOffering?.monthly
    }

    var yearlyPackage: Package? {
        currentOffering?.package(identifier: RevenueCatConfig.Products.yearly) ??
        currentOffering?.annual
    }

    var expirationDate: Date? {
        guard let customerInfo = customerInfo else { return nil }
        guard let entitlement = customerInfo.entitlements[RevenueCatConfig.entitlementIdentifier] else { return nil }
        return entitlement.expirationDate
    }

    var activeProductIdentifier: String? {
        guard let customerInfo = customerInfo else { return nil }
        guard let entitlement = customerInfo.entitlements[RevenueCatConfig.entitlementIdentifier] else { return nil }
        return entitlement.productIdentifier
    }

    // MARK: - Init
    private init() {}

    // MARK: - Configuration
    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)

        // Set up delegate for real-time updates
        Purchases.shared.delegate = self

        // Fetch initial data
        Task {
            await refreshCustomerInfo()
            await fetchOfferings()
        }
    }

    // MARK: - User Identification
    func login(userId: String) async throws {
        let (customerInfo, _) = try await Purchases.shared.logIn(userId)
        self.customerInfo = customerInfo
        updateSubscriptionStatus(from: customerInfo)
    }

    func logout() async throws {
        let customerInfo = try await Purchases.shared.logOut()
        self.customerInfo = customerInfo
        updateSubscriptionStatus(from: customerInfo)
    }

    // MARK: - Customer Info
    func refreshCustomerInfo() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.customerInfo = customerInfo
            updateSubscriptionStatus(from: customerInfo)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load subscription info: \(error.localizedDescription)"
        }
    }

    // MARK: - Offerings
    func fetchOfferings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load offerings: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchases
    func purchase(package: Package) async throws -> CustomerInfo {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if result.userCancelled {
                throw RevenueCatError.cancelled
            }

            self.customerInfo = result.customerInfo
            updateSubscriptionStatus(from: result.customerInfo)
            errorMessage = nil

            return result.customerInfo
        } catch let error as RevenueCatError {
            throw error
        } catch {
            throw RevenueCatError.purchaseFailed(error)
        }
    }

    func purchaseMonthly() async throws -> CustomerInfo {
        guard let package = monthlyPackage else {
            throw RevenueCatError.offeringsUnavailable
        }
        return try await purchase(package: package)
    }

    func purchaseYearly() async throws -> CustomerInfo {
        guard let package = yearlyPackage else {
            throw RevenueCatError.offeringsUnavailable
        }
        return try await purchase(package: package)
    }

    // MARK: - Restore Purchases
    func restorePurchases() async throws -> CustomerInfo {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            self.customerInfo = customerInfo
            updateSubscriptionStatus(from: customerInfo)
            errorMessage = nil
            return customerInfo
        } catch {
            throw RevenueCatError.restoreFailed(error)
        }
    }

    // MARK: - Entitlement Checking
    func checkEntitlement(_ entitlementId: String = RevenueCatConfig.entitlementIdentifier) -> Bool {
        guard let customerInfo = customerInfo else { return false }
        return customerInfo.entitlements[entitlementId]?.isActive == true
    }

    // MARK: - Private Helpers
    private func updateSubscriptionStatus(from customerInfo: CustomerInfo) {
        guard let entitlement = customerInfo.entitlements[RevenueCatConfig.entitlementIdentifier] else {
            subscriptionStatus = .notSubscribed
            return
        }

        if entitlement.isActive {
            subscriptionStatus = .subscribed(
                expirationDate: entitlement.expirationDate,
                productIdentifier: entitlement.productIdentifier
            )
        } else if entitlement.expirationDate != nil {
            subscriptionStatus = .expired
        } else {
            subscriptionStatus = .notSubscribed
        }
    }
}

// MARK: - PurchasesDelegate
extension RevenueCatService: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.customerInfo = customerInfo
            self.updateSubscriptionStatus(from: customerInfo)
        }
    }
}

// MARK: - Convenience Extensions
extension Package {
    var localizedPricePerMonth: String {
        guard let product = storeProduct as? SK1StoreProduct else {
            return storeProduct.localizedPriceString
        }

        // For annual subscriptions, calculate monthly price
        if packageType == .annual {
            let monthlyPrice = storeProduct.price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.sk1Product.priceLocale
            return formatter.string(from: monthlyPrice as NSNumber) ?? storeProduct.localizedPriceString
        }

        return storeProduct.localizedPriceString
    }

    var savingsPercentage: Int? {
        // This would need to be calculated based on comparing with monthly price
        // Typically configured in RevenueCat dashboard
        if packageType == .annual {
            return 44 // Example savings percentage
        }
        return nil
    }
}

// MARK: - SwiftUI View Modifiers
extension View {
    /// Check if user has pro access, otherwise show paywall
    func requiresProAccess(
        isPresented: Binding<Bool>,
        onPurchaseCompleted: (() -> Void)? = nil
    ) -> some View {
        self.modifier(ProAccessModifier(
            isPresented: isPresented,
            onPurchaseCompleted: onPurchaseCompleted
        ))
    }
}

struct ProAccessModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onPurchaseCompleted: (() -> Void)?
    @StateObject private var revenueCat = RevenueCatService.shared

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                PaywallView()
                    .onPurchaseCompleted { _ in
                        isPresented = false
                        onPurchaseCompleted?()
                    }
            }
    }
}
