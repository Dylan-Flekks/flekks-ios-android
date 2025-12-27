import SwiftUI

struct ScheduleSessionSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let session: Session

    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var enableReminder = true
    @State private var reminderMinutes = 15

    private let reminderOptions = [5, 10, 15, 30, 60]

    private var isAlreadyScheduled: Bool {
        appState.scheduledSessions[session.id] != nil
    }

    private var combinedDateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute

        return calendar.date(from: combined) ?? Date()
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Session Preview Card
                        sessionPreviewCard

                        // Date Selection
                        dateSelectionSection

                        // Time Selection
                        timeSelectionSection

                        // Reminder Toggle
                        reminderSection

                        // Quick Schedule Options
                        quickScheduleSection

                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }

                // Bottom Button
                VStack {
                    Spacer()
                    scheduleButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Schedule Session")
                        .font(FLEKKSFonts.bodySemibold(17))
                        .foregroundColor(.textPrimary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isAlreadyScheduled {
                        Button("Remove") {
                            appState.unscheduleSession(session.id)
                            dismiss()
                        }
                        .foregroundColor(.flekksRed)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let existingDate = appState.scheduledSessions[session.id] {
                selectedDate = existingDate
                selectedTime = existingDate
            } else {
                // Default to tomorrow at 7am
                let calendar = Calendar.current
                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
                    selectedDate = tomorrow
                }
                selectedTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
            }
        }
    }

    // MARK: - Session Preview Card
    private var sessionPreviewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(FLEKKSGradients.avatarGradient)
                    .frame(width: 50, height: 50)

                Text(iconForFocusArea(session.focusArea))
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 8) {
                    Text("Day \(session.dayNumber)")
                    Text("•")
                    Text("\(session.durationMinutes) min")
                }
                .font(FLEKKSFonts.body(13))
                .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    // MARK: - Date Selection Section
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Date")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            DatePicker(
                "",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(.accent)
            .colorScheme(.dark)
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Time Selection Section
    private var timeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Time")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            HStack {
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .accentColor(.accent)
                .colorScheme(.dark)
                .frame(height: 120)
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Reminder Section
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $enableReminder) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(FLEKKSGradients.iconGradient)

                    Text("Remind Me")
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)
                }
            }
            .tint(.accent)
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if enableReminder {
                HStack(spacing: 8) {
                    ForEach(reminderOptions, id: \.self) { minutes in
                        Button(action: { reminderMinutes = minutes }) {
                            Text(minutes < 60 ? "\(minutes)m" : "1h")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(reminderMinutes == minutes ? .bgPrimary : .textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    reminderMinutes == minutes
                                        ? FLEKKSGradients.buttonGradient
                                        : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quick Schedule Section
    private var quickScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Schedule")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            HStack(spacing: 10) {
                QuickScheduleButton(title: "Tomorrow", subtitle: "7:00 AM") {
                    setQuickDate(daysFromNow: 1, hour: 7)
                }

                QuickScheduleButton(title: "This Weekend", subtitle: "9:00 AM") {
                    setToNextWeekend()
                }

                QuickScheduleButton(title: "Next Week", subtitle: "6:00 AM") {
                    setQuickDate(daysFromNow: 7, hour: 6)
                }
            }
        }
    }

    // MARK: - Schedule Button
    private var scheduleButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.bgPrimary.opacity(0), Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)

            VStack(spacing: 8) {
                Button(action: scheduleSession) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16, weight: .bold))
                        Text(isAlreadyScheduled ? "Update Schedule" : "Schedule Session")
                            .font(FLEKKSFonts.bodySemibold(17))
                    }
                }
                .buttonStyle(TealGlowButtonStyle())

                Text(formattedScheduleDate)
                    .font(FLEKKSFonts.body(13))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .background(Color.bgPrimary)
        }
    }

    // MARK: - Helpers
    private var formattedScheduleDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
        return formatter.string(from: combinedDateTime)
    }

    private func scheduleSession() {
        appState.scheduleSession(session.id, for: combinedDateTime)
        // TODO: Schedule local notification if reminder enabled
        dismiss()
    }

    private func setQuickDate(daysFromNow: Int, hour: Int) {
        let calendar = Calendar.current
        if let futureDate = calendar.date(byAdding: .day, value: daysFromNow, to: Date()) {
            selectedDate = futureDate
        }
        selectedTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private func setToNextWeekend() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Saturday = 7, Sunday = 1
        let daysToSaturday = (7 - weekday + 7) % 7
        let nextSaturday = calendar.date(byAdding: .day, value: daysToSaturday == 0 ? 7 : daysToSaturday, to: today)!
        selectedDate = nextSaturday
        selectedTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private func iconForFocusArea(_ area: String) -> String {
        switch area.lowercased() {
        case let a where a.contains("hip"): return "🦵"
        case let a where a.contains("back") || a.contains("spine"): return "🧘"
        case let a where a.contains("core"): return "💪"
        case let a where a.contains("shoulder"): return "🙆"
        case let a where a.contains("hamstring"): return "🏃"
        case let a where a.contains("pike"): return "🤸"
        default: return "✨"
        }
    }
}

// MARK: - Quick Schedule Button
struct QuickScheduleButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(FLEKKSFonts.bodySemibold(13))
                    .foregroundColor(.textPrimary)
                Text(subtitle)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScheduleSessionSheet(session: Session.lowBackSessions[0])
        .environmentObject(AppState())
}
