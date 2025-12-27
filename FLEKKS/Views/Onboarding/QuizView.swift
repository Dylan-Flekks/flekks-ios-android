import SwiftUI

struct QuizView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var selectedOptions: [Int: String] = [:]

    private let questions = QuizQuestion.questions

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back and progress
                HStack(spacing: 12) {
                    Button(action: {
                        if currentStep > 0 {
                            withAnimation {
                                currentStep -= 1
                            }
                        } else {
                            appState.currentScreen = .onboarding
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(GhostButtonStyle())

                    // Progress bars
                    HStack(spacing: 6) {
                        ForEach(0..<questions.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(index <= currentStep ? Color.accent : Color.bgElevated)
                                .frame(height: 3)
                        }
                    }

                    Text("\(currentStep + 1)/\(questions.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textMuted)
                        .frame(width: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Question
                Text(questions[currentStep].question)
                    .font(.custom("Georgia", size: 32))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)

                // Options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(questions[currentStep].options) { option in
                            QuizOptionCard(
                                option: option,
                                isSelected: selectedOptions[currentStep] == option.id
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedOptions[currentStep] = option.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Continue button
                Button(action: {
                    if currentStep < questions.count - 1 {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        appState.completeQuiz()
                    }
                }) {
                    Text(currentStep < questions.count - 1 ? "Continue" : "Find My Team")
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: selectedOptions[currentStep] == nil))
                .disabled(selectedOptions[currentStep] == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct QuizOptionCard: View {
    let option: QuizOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color.accent : Color.bgElevated)
                        .frame(width: 48, height: 48)

                    Text(option.icon)
                        .font(.system(size: 22))
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    Text(option.description)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.accent : Color.borderLight, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.accent)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.bgPrimary)
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentGlow : Color.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accent : Color.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuizView()
        .environmentObject(AppState())
}
