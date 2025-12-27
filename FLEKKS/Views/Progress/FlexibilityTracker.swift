import SwiftUI

// MARK: - Flexibility Progress Model
struct FlexibilityProgress: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let bodyArea: BodyArea
    let measurementType: MeasurementType
    let value: Double
    let unit: String
    let photoUrl: String?
    let notes: String?
    let recordedAt: Date

    enum BodyArea: String, Codable, CaseIterable {
        case hips = "Hips"
        case hamstrings = "Hamstrings"
        case shoulders = "Shoulders"
        case spine = "Spine"
        case ankles = "Ankles"
        case wrists = "Wrists"

        var icon: String {
            switch self {
            case .hips: return "🦵"
            case .hamstrings: return "🏃"
            case .shoulders: return "🙆"
            case .spine: return "🧘"
            case .ankles: return "🦶"
            case .wrists: return "🤲"
            }
        }

        var color: Color {
            switch self {
            case .hips: return .flekksOrange
            case .hamstrings: return .accent
            case .shoulders: return .tealBright
            case .spine: return .accentLight
            case .ankles: return .flekksRed
            case .wrists: return .textSecondary
            }
        }
    }

    enum MeasurementType: String, Codable, CaseIterable {
        case holdTime = "Hold Time"
        case rangeOfMotion = "Range of Motion"
        case touchDistance = "Touch Distance"
        case splitDistance = "Split Distance"

        var unit: String {
            switch self {
            case .holdTime: return "sec"
            case .rangeOfMotion: return "°"
            case .touchDistance: return "in"
            case .splitDistance: return "in"
            }
        }

        var icon: String {
            switch self {
            case .holdTime: return "timer"
            case .rangeOfMotion: return "angle"
            case .touchDistance: return "ruler"
            case .splitDistance: return "arrow.left.and.right"
            }
        }
    }

    static let preview: [FlexibilityProgress] = [
        FlexibilityProgress(
            id: UUID(),
            userId: UUID(),
            bodyArea: .hips,
            measurementType: .rangeOfMotion,
            value: 45,
            unit: "°",
            photoUrl: nil,
            notes: "Feeling looser after consistent practice",
            recordedAt: Date().addingTimeInterval(-86400 * 7)
        ),
        FlexibilityProgress(
            id: UUID(),
            userId: UUID(),
            bodyArea: .hips,
            measurementType: .rangeOfMotion,
            value: 52,
            unit: "°",
            photoUrl: nil,
            notes: nil,
            recordedAt: Date().addingTimeInterval(-86400 * 3)
        ),
        FlexibilityProgress(
            id: UUID(),
            userId: UUID(),
            bodyArea: .hips,
            measurementType: .rangeOfMotion,
            value: 58,
            unit: "°",
            photoUrl: nil,
            notes: "New personal best!",
            recordedAt: Date()
        ),
        FlexibilityProgress(
            id: UUID(),
            userId: UUID(),
            bodyArea: .hamstrings,
            measurementType: .touchDistance,
            value: 4,
            unit: "in",
            photoUrl: nil,
            notes: "Past toes now",
            recordedAt: Date().addingTimeInterval(-86400 * 5)
        ),
        FlexibilityProgress(
            id: UUID(),
            userId: UUID(),
            bodyArea: .hamstrings,
            measurementType: .touchDistance,
            value: 6,
            unit: "in",
            photoUrl: nil,
            notes: nil,
            recordedAt: Date()
        ),
    ]
}

// MARK: - Body Area Summary
struct BodyAreaSummary: Identifiable {
    let id = UUID()
    let area: FlexibilityProgress.BodyArea
    let latestValue: Double
    let previousValue: Double?
    let unit: String
    let measurementType: FlexibilityProgress.MeasurementType
    let progressHistory: [FlexibilityProgress]

    var improvement: Double? {
        guard let previous = previousValue else { return nil }
        return latestValue - previous
    }

    var improvementPercentage: Double? {
        guard let previous = previousValue, previous > 0 else { return nil }
        return ((latestValue - previous) / previous) * 100
    }
}

// MARK: - Flexibility Tracker View
struct FlexibilityTrackerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedArea: FlexibilityProgress.BodyArea?
    @State private var showAddMeasurement = false
    @State private var progressData: [FlexibilityProgress] = FlexibilityProgress.preview

    private var bodySummaries: [BodyAreaSummary] {
        var summaries: [BodyAreaSummary] = []

        for area in FlexibilityProgress.BodyArea.allCases {
            let areaProgress = progressData.filter { $0.bodyArea == area }.sorted { $0.recordedAt > $1.recordedAt }

            if let latest = areaProgress.first {
                let previous = areaProgress.dropFirst().first
                summaries.append(BodyAreaSummary(
                    area: area,
                    latestValue: latest.value,
                    previousValue: previous?.value,
                    unit: latest.unit,
                    measurementType: latest.measurementType,
                    progressHistory: areaProgress
                ))
            }
        }

        return summaries
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flexibility Progress")
                        .font(FLEKKSFonts.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text("Track your range of motion over time")
                        .font(FLEKKSFonts.labelMedium)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                Button(action: { showAddMeasurement = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(FLEKKSGradients.iconGradient)
                }
            }

            // Body Map Overview
            BodyMapView(summaries: bodySummaries, selectedArea: $selectedArea)

            // Area Progress Cards
            VStack(spacing: 14) {
                ForEach(bodySummaries) { summary in
                    BodyAreaProgressCard(
                        summary: summary,
                        isSelected: selectedArea == summary.area,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedArea = selectedArea == summary.area ? nil : summary.area
                            }
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showAddMeasurement) {
            AddMeasurementSheet(progressData: $progressData)
        }
        .sheet(item: $selectedArea) { area in
            AreaDetailSheet(
                area: area,
                progressHistory: progressData.filter { $0.bodyArea == area }.sorted { $0.recordedAt > $1.recordedAt }
            )
        }
    }
}

// MARK: - Body Map View
struct BodyMapView: View {
    let summaries: [BodyAreaSummary]
    @Binding var selectedArea: FlexibilityProgress.BodyArea?

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(FLEKKSGradients.tealGlow)
                .frame(width: 200, height: 200)
                .blur(radius: 60)

            // Body silhouette placeholder
            VStack(spacing: 0) {
                // Head
                Circle()
                    .fill(Color.bgElevated)
                    .frame(width: 40, height: 40)

                // Shoulders
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.bgElevated)
                    .frame(width: 80, height: 20)
                    .offset(y: -5)

                // Torso
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgElevated)
                    .frame(width: 50, height: 60)
                    .offset(y: -10)

                // Hips
                Ellipse()
                    .fill(Color.bgElevated)
                    .frame(width: 60, height: 25)
                    .offset(y: -15)

                // Legs
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.bgElevated)
                        .frame(width: 18, height: 70)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.bgElevated)
                        .frame(width: 18, height: 70)
                }
                .offset(y: -20)
            }

            // Hotspot indicators
            ForEach(summaries) { summary in
                BodyHotspot(
                    summary: summary,
                    isSelected: selectedArea == summary.area
                )
                .position(positionForArea(summary.area))
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedArea = selectedArea == summary.area ? nil : summary.area
                    }
                }
            }
        }
        .frame(height: 220)
        .padding(20)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    private func positionForArea(_ area: FlexibilityProgress.BodyArea) -> CGPoint {
        let centerX: CGFloat = 187
        let centerY: CGFloat = 110

        switch area {
        case .shoulders: return CGPoint(x: centerX, y: centerY - 55)
        case .spine: return CGPoint(x: centerX, y: centerY)
        case .hips: return CGPoint(x: centerX, y: centerY + 35)
        case .hamstrings: return CGPoint(x: centerX - 25, y: centerY + 75)
        case .ankles: return CGPoint(x: centerX + 25, y: centerY + 100)
        case .wrists: return CGPoint(x: centerX + 55, y: centerY - 30)
        }
    }
}

// MARK: - Body Hotspot
struct BodyHotspot: View {
    let summary: BodyAreaSummary
    let isSelected: Bool

    var body: some View {
        ZStack {
            // Pulse animation for areas with improvement
            if summary.improvement != nil && summary.improvement! > 0 {
                Circle()
                    .fill(summary.area.color.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .scaleEffect(isSelected ? 1.3 : 1.0)
            }

            Circle()
                .fill(summary.area.color)
                .frame(width: 28, height: 28)
                .scaleEffect(isSelected ? 1.2 : 1.0)

            if let improvement = summary.improvement, improvement > 0 {
                Image(systemName: "arrow.up")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text(summary.area.icon)
                    .font(.system(size: 14))
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Body Area Progress Card
struct BodyAreaProgressCard: View {
    let summary: BodyAreaSummary
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(summary.area.color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Text(summary.area.icon)
                        .font(.system(size: 24))
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.area.rawValue)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)

                    Text(summary.measurementType.rawValue)
                        .font(FLEKKSFonts.labelSmall)
                        .foregroundColor(.textMuted)
                }

                Spacer()

                // Value and trend
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(String(format: "%.0f", summary.latestValue))
                            .font(FLEKKSFonts.headingHeavy(22))
                            .foregroundColor(.textPrimary)

                        Text(summary.unit)
                            .font(FLEKKSFonts.labelMedium)
                            .foregroundColor(.textMuted)
                    }

                    if let improvement = summary.improvement {
                        HStack(spacing: 4) {
                            Image(systemName: improvement >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 10, weight: .bold))

                            Text(String(format: "%+.0f%@", improvement, summary.unit))
                                .font(FLEKKSFonts.labelSmall)
                        }
                        .foregroundColor(improvement >= 0 ? .accent : .flekksRed)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textMuted)
            }
            .padding(16)
            .background(isSelected ? summary.area.color.opacity(0.1) : Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? summary.area.color.opacity(0.5) : FLEKKSGradients.borderGradientSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Area Detail Sheet
struct AreaDetailSheet: View {
    let area: FlexibilityProgress.BodyArea
    let progressHistory: [FlexibilityProgress]
    @Environment(\.dismiss) private var dismiss

    private var improvementFromStart: Double? {
        guard let first = progressHistory.last, let latest = progressHistory.first else { return nil }
        return latest.value - first.value
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(area.color.opacity(0.2))
                                    .frame(width: 100, height: 100)

                                Text(area.icon)
                                    .font(.system(size: 50))
                            }

                            Text(area.rawValue)
                                .font(FLEKKSFonts.heading(28))
                                .foregroundColor(.textPrimary)

                            if let improvement = improvementFromStart {
                                HStack(spacing: 8) {
                                    Image(systemName: improvement >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .font(.system(size: 20))

                                    Text(String(format: "%+.0f%@ total improvement", improvement, progressHistory.first?.unit ?? ""))
                                        .font(FLEKKSFonts.bodyMedium(16))
                                }
                                .foregroundColor(improvement >= 0 ? .accent : .flekksRed)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // Progress Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress Over Time")
                                .font(FLEKKSFonts.bodySemibold(16))
                                .foregroundColor(.textPrimary)

                            ProgressChartView(progressHistory: progressHistory, color: area.color)
                        }
                        .padding(20)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // History List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Measurement History")
                                .font(FLEKKSFonts.bodySemibold(16))
                                .foregroundColor(.textPrimary)

                            VStack(spacing: 12) {
                                ForEach(progressHistory) { progress in
                                    ProgressHistoryRow(progress: progress, areaColor: area.color)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accent)
                }
            }
        }
    }
}

// MARK: - Progress Chart View
struct ProgressChartView: View {
    let progressHistory: [FlexibilityProgress]
    let color: Color

    private var sortedHistory: [FlexibilityProgress] {
        progressHistory.sorted { $0.recordedAt < $1.recordedAt }
    }

    private var maxValue: Double {
        (progressHistory.map { $0.value }.max() ?? 100) * 1.1
    }

    private var minValue: Double {
        max(0, (progressHistory.map { $0.value }.min() ?? 0) * 0.9)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height: CGFloat = 150
            let stepX = width / CGFloat(max(sortedHistory.count - 1, 1))

            ZStack(alignment: .bottomLeading) {
                // Grid lines
                VStack(spacing: height / 4) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.bgElevated)
                            .frame(height: 1)
                    }
                }
                .frame(height: height)

                // Line path
                Path { path in
                    for (index, progress) in sortedHistory.enumerated() {
                        let x = stepX * CGFloat(index)
                        let normalizedValue = (progress.value - minValue) / (maxValue - minValue)
                        let y = height - (CGFloat(normalizedValue) * height)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )

                // Data points
                ForEach(Array(sortedHistory.enumerated()), id: \.element.id) { index, progress in
                    let x = stepX * CGFloat(index)
                    let normalizedValue = (progress.value - minValue) / (maxValue - minValue)
                    let y = height - (CGFloat(normalizedValue) * height)

                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)
                        .position(x: x, y: y)

                    // Value label on last point
                    if index == sortedHistory.count - 1 {
                        Text(String(format: "%.0f", progress.value))
                            .font(FLEKKSFonts.bodySemibold(12))
                            .foregroundColor(color)
                            .position(x: x, y: y - 18)
                    }
                }
            }
            .frame(height: height)
        }
        .frame(height: 150)
    }
}

// MARK: - Progress History Row
struct ProgressHistoryRow: View {
    let progress: FlexibilityProgress
    let areaColor: Color

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: progress.recordedAt)
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(areaColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(FLEKKSFonts.bodySemibold(14))
                    .foregroundColor(.textPrimary)

                if let notes = progress.notes {
                    Text(notes)
                        .font(FLEKKSFonts.body(13))
                        .foregroundColor(.textMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Text(String(format: "%.0f", progress.value))
                    .font(FLEKKSFonts.headingHeavy(18))
                    .foregroundColor(.textPrimary)

                Text(progress.unit)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)
            }
        }
        .padding(12)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add Measurement Sheet
struct AddMeasurementSheet: View {
    @Binding var progressData: [FlexibilityProgress]
    @Environment(\.dismiss) private var dismiss

    @State private var selectedArea: FlexibilityProgress.BodyArea = .hips
    @State private var selectedType: FlexibilityProgress.MeasurementType = .rangeOfMotion
    @State private var value: String = ""
    @State private var notes: String = ""
    @State private var showCamera = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Area Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Body Area")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(FlexibilityProgress.BodyArea.allCases, id: \.self) { area in
                                    AreaSelectionButton(
                                        area: area,
                                        isSelected: selectedArea == area,
                                        onTap: { selectedArea = area }
                                    )
                                }
                            }
                        }

                        // Measurement Type
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Measurement Type")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)

                            VStack(spacing: 10) {
                                ForEach(FlexibilityProgress.MeasurementType.allCases, id: \.self) { type in
                                    MeasurementTypeButton(
                                        type: type,
                                        isSelected: selectedType == type,
                                        onTap: { selectedType = type }
                                    )
                                }
                            }
                        }

                        // Value Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Value")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)

                            HStack(spacing: 12) {
                                TextField("0", text: $value)
                                    .font(FLEKKSFonts.headingHeavy(36))
                                    .foregroundColor(.textPrimary)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120)
                                    .padding(16)
                                    .background(Color.bgElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                Text(selectedType.unit)
                                    .font(FLEKKSFonts.heading(24))
                                    .foregroundColor(.textMuted)
                            }
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes (optional)")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)

                            TextField("How did it feel?", text: $notes)
                                .font(FLEKKSFonts.body(15))
                                .foregroundColor(.textPrimary)
                                .padding(16)
                                .background(Color.bgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Photo Button
                        Button(action: { showCamera = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                Text("Add Progress Photo")
                                    .font(FLEKKSFonts.bodyMedium(15))
                            }
                            .foregroundColor(.accent)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentGlow)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Log Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeasurement()
                    }
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(.accent)
                    .disabled(value.isEmpty)
                }
            }
        }
    }

    private func saveMeasurement() {
        guard let numValue = Double(value) else { return }

        let newProgress = FlexibilityProgress(
            id: UUID(),
            userId: UUID(),
            bodyArea: selectedArea,
            measurementType: selectedType,
            value: numValue,
            unit: selectedType.unit,
            photoUrl: nil,
            notes: notes.isEmpty ? nil : notes,
            recordedAt: Date()
        )

        progressData.append(newProgress)
        dismiss()
    }
}

// MARK: - Area Selection Button
struct AreaSelectionButton: View {
    let area: FlexibilityProgress.BodyArea
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(area.icon)
                    .font(.system(size: 24))

                Text(area.rawValue)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(isSelected ? .textPrimary : .textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? area.color.opacity(0.2) : Color.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? area.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Measurement Type Button
struct MeasurementTypeButton: View {
    let type: FlexibilityProgress.MeasurementType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .accent : .textMuted)
                    .frame(width: 24)

                Text(type.rawValue)
                    .font(FLEKKSFonts.bodyMedium(15))
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)

                Spacer()

                Text(type.unit)
                    .font(FLEKKSFonts.labelMedium)
                    .foregroundColor(.textMuted)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accent)
                }
            }
            .padding(16)
            .background(isSelected ? Color.accentGlow : Color.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accent.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// Make BodyArea Identifiable for sheet
extension FlexibilityProgress.BodyArea: Identifiable {
    var id: String { rawValue }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()

        ScrollView {
            FlexibilityTrackerView()
                .padding(20)
                .environmentObject(AppState())
        }
    }
}
