import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch appState.selectedTab {
                case .home:
                    HomeView()
                case .program:
                    ProgramView()
                case .team:
                    TeamChatView()
                case .progress:
                    UserProgressView()
                case .profile:
                    ProfileView()
                }
            }

            // Tab bar
            HStack {
                TabBarItem(icon: "house.fill", label: "Home", tab: .home)
                TabBarItem(icon: "calendar", label: "Program", tab: .program)
                TabBarItem(icon: "person.3.fill", label: "Team", tab: .team)
                TabBarItem(icon: "chart.bar.fill", label: "Progress", tab: .progress)
                TabBarItem(icon: "person.fill", label: "Profile", tab: .profile)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .background(
                Color.bgPrimary.opacity(0.92)
                    .background(.ultraThinMaterial)
            )
            .overlay(
                Rectangle()
                    .fill(Color.border)
                    .frame(height: 1),
                alignment: .top
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct TabBarItem: View {
    @EnvironmentObject var appState: AppState

    let icon: String
    let label: String
    let tab: Tab

    var isSelected: Bool {
        appState.selectedTab == tab
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                appState.selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accent : .textMuted)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .accent : .textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentGlow : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TabBarView()
        .environmentObject(AppState())
}
