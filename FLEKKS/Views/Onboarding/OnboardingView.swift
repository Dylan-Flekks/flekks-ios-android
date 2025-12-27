import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    let pages: [(icon: String, title: String, description: String)] = [
        ("🧘", "Coach-Led Programs", "Follow structured 6-week programs designed by licensed Physical Therapists"),
        ("👥", "Team Accountability", "Join a team, connect with others on the same journey, stay motivated together"),
        ("📈", "Track Progress", "See your flexibility improve week over week with measurable results"),
    ]

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        appState.completeOnboarding()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .padding()
                }

                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            // Icon with glow
                            ZStack {
                                Circle()
                                    .fill(FLEKKSGradients.tealGlow)
                                    .frame(width: 200, height: 200)
                                    .blur(radius: 60)

                                Text(pages[index].icon)
                                    .font(.system(size: 80))
                            }
                            .padding(.bottom, 20)

                            Text(pages[index].title)
                                .font(.custom("Georgia", size: 28))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)

                            Text(pages[index].description)
                                .font(.system(size: 16))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accent : Color.bgElevated)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 40)

                Spacer()

                // Continue button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        appState.completeOnboarding()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Let's Go")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
