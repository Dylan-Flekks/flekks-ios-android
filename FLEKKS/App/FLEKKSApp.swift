import SwiftUI
import RevenueCat
import RevenueCatUI

@main
struct FLEKKSApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var revenueCat = RevenueCatService.shared

    init() {
        // Configure RevenueCat SDK
        RevenueCatService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(revenueCat)
                .preferredColorScheme(.dark)
                // Global paywall sheet
                .sheet(isPresented: $appState.showPaywall) {
                    PaywallView()
                        .onPurchaseCompleted { _ in
                            appState.dismissPaywall()
                        }
                        .onRestoreCompleted { _ in
                            appState.dismissPaywall()
                        }
                }
                // Global customer center sheet
                .sheet(isPresented: $appState.showCustomerCenter) {
                    CustomerCenterView()
                }
        }
    }
}
