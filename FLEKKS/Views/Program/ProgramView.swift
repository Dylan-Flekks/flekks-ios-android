import SwiftUI

struct ProgramView: View {
    @EnvironmentObject var appState: AppState

    private let program = Program.deskReset
    private let sessions = Session.previewSessions

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero header
                ZStack(alignment: .bottomLeading) {
                    FLEKKSGradients.heroGreen
                        .frame(height: 200)

                    // Teal glow
                    Circle()
                        .fill(FLEKKSGradients.tealGlow)
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: 100, y: -50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT PROGRAM")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.accent)
                            .tracking(1.5)

                        Text(program.name)
                            .font(.custom("Georgia", size: 32))
                            .foregroundColor(.textPrimary)

                        Text("with \(program.coach.name)")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(24)
                }

                VStack(spacing: 24) {
                    // Progress card
                    VStack(spacing: 14) {
                        HStack {
                            Text("Your Progress")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("\(Int(program.progressPercentage * 100))%")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.accent)
                        }

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.bgElevated)
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.accent)
                                    .frame(width: geometry.size.width * program.progressPercentage, height: 6)
                            }
                        }
                        .frame(height: 6)

                        HStack(spacing: 20) {
                            Text("Week \(program.currentWeek) of \(program.weekCount)")
                            Text("\(program.completedSessions) sessions done")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    }
                    .padding(20)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.border, lineWidth: 1)
                    )

                    // Week section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Week \(program.currentWeek)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("IN PROGRESS")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.accentGlow)
                                .clipShape(Capsule())
                        }

                        // Session list
                        VStack(spacing: 10) {
                            ForEach(sessions) { session in
                                SessionRow(session: session)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
        .background(Color.bgPrimary)
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct SessionRow: View {
    let session: Session

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(session.isCompleted ? Color.accent : Color.borderLight, lineWidth: 2)
                        .frame(width: 26, height: 26)

                    if session.isCompleted {
                        Circle()
                            .fill(Color.accent)
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.bgPrimary)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(session.isCompleted ? .textMuted : .textPrimary)

                    Text(session.focusArea)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Duration
                Text("\(session.duration) min")
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.border, lineWidth: 1)
            )
            .opacity(session.isCompleted ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProgramView()
        .environmentObject(AppState())
}
