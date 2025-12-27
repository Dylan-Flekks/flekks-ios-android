import SwiftUI

struct ShareSessionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let session: Session
    let coach: Coach?

    @State private var showCopiedToast = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Share Preview Card
                    sharePreviewCard

                    // Share Options
                    shareOptionsSection

                    // Social Sharing
                    socialSharingSection

                    Spacer()
                }
                .padding(20)

                // Copied Toast
                if showCopiedToast {
                    VStack {
                        Spacer()
                        copiedToast
                            .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Share Session")
                        .font(FLEKKSFonts.bodySemibold(17))
                        .foregroundColor(.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textMuted)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Share Preview Card
    private var sharePreviewCard: some View {
        VStack(spacing: 0) {
            // Hero gradient
            ZStack {
                FLEKKSGradients.heroTealVibrant
                    .frame(height: 100)

                Circle()
                    .fill(FLEKKSGradients.tealGlow)
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)

                Text(iconForFocusArea(session.focusArea))
                    .font(.system(size: 50))
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("FLEKKS")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundStyle(FLEKKSGradients.accentGradient)
                    .tracking(2)

                Text(session.title)
                    .font(FLEKKSFonts.heading(20))
                    .foregroundColor(.textPrimary)

                if let coach = coach {
                    Text("with \(coach.name)")
                        .font(FLEKKSFonts.body(14))
                        .foregroundColor(.textSecondary)
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text("\(session.durationMinutes) min")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "flame")
                            .font(.system(size: 11))
                        Text(session.focusArea)
                    }
                }
                .font(FLEKKSFonts.body(12))
                .foregroundColor(.textMuted)
                .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }

    // MARK: - Share Options Section
    private var shareOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share via")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            HStack(spacing: 12) {
                ShareOptionButton(
                    icon: "message.fill",
                    label: "Message",
                    color: .green
                ) {
                    shareViaMessages()
                }

                ShareOptionButton(
                    icon: "envelope.fill",
                    label: "Email",
                    color: .blue
                ) {
                    shareViaEmail()
                }

                ShareOptionButton(
                    icon: "link",
                    label: "Copy Link",
                    color: .accent
                ) {
                    copyLink()
                }

                ShareOptionButton(
                    icon: "ellipsis",
                    label: "More",
                    color: .textSecondary
                ) {
                    shareViaSystemSheet()
                }
            }
        }
    }

    // MARK: - Social Sharing Section
    private var socialSharingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share to Social")
                .font(FLEKKSFonts.bodySemibold(16))
                .foregroundColor(.textPrimary)

            VStack(spacing: 10) {
                SocialShareRow(
                    icon: "camera.fill",
                    iconColor: Color(hex: "E1306C"),
                    label: "Instagram Stories",
                    description: "Share to your story"
                ) {
                    shareToInstagram()
                }

                SocialShareRow(
                    icon: "play.rectangle.fill",
                    iconColor: Color(hex: "FF0000"),
                    label: "Share Progress",
                    description: "Post your workout journey"
                ) {
                    shareProgress()
                }
            }
        }
    }

    // MARK: - Copied Toast
    private var copiedToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accent)
            Text("Link copied to clipboard")
                .font(FLEKKSFonts.bodyMedium(14))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.bgCard)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }

    // MARK: - Actions
    private func shareViaMessages() {
        // Would open Messages with pre-filled text
        let text = shareText
        // In production, use UIActivityViewController or URL scheme
        print("Share via Messages: \(text)")
    }

    private func shareViaEmail() {
        // Would open Mail with pre-filled content
        print("Share via Email")
    }

    private func copyLink() {
        UIPasteboard.general.string = shareLink
        withAnimation(.spring()) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }

    private func shareViaSystemSheet() {
        // Would present UIActivityViewController
        print("Open system share sheet")
    }

    private func shareToInstagram() {
        // Would open Instagram Stories with content
        print("Share to Instagram")
    }

    private func shareProgress() {
        // Would open share flow for progress
        print("Share progress")
    }

    // MARK: - Helpers
    private var shareText: String {
        var text = "Check out this \(session.focusArea) session on FLEKKS! 💪\n\n"
        text += "\(session.title)\n"
        if let coach = coach {
            text += "with \(coach.name)\n"
        }
        text += "\n\(session.durationMinutes) min • \(session.focusArea)\n\n"
        text += shareLink
        return text
    }

    private var shareLink: String {
        "https://flekks.app/session/\(session.id.uuidString)"
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

// MARK: - Share Option Button
struct ShareOptionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Social Share Row
struct SocialShareRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)
                    Text(description)
                        .font(FLEKKSFonts.body(12))
                        .foregroundColor(.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
            .padding(14)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShareSessionSheet(session: Session.lowBackSessions[0], coach: Coach.dylanPeters)
}
