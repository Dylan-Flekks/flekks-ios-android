import SwiftUI
import Combine

// MARK: - Music Provider
enum MusicProvider: String, CaseIterable, Codable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    case none = "None"

    var icon: String {
        switch self {
        case .appleMusic: return "applelogo"
        case .spotify: return "antenna.radiowaves.left.and.right"
        case .none: return "speaker.slash"
        }
    }

    var color: Color {
        switch self {
        case .appleMusic: return Color(red: 0.98, green: 0.34, blue: 0.40)
        case .spotify: return Color(red: 0.11, green: 0.73, blue: 0.33)
        case .none: return .textMuted
        }
    }

    var brandColor: LinearGradient {
        switch self {
        case .appleMusic:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.34, blue: 0.40), Color(red: 0.93, green: 0.29, blue: 0.36)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .spotify:
            return LinearGradient(
                colors: [Color(red: 0.11, green: 0.73, blue: 0.33), Color(red: 0.09, green: 0.62, blue: 0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .none:
            return LinearGradient(colors: [.textMuted], startPoint: .top, endPoint: .bottom)
        }
    }
}

// MARK: - Music Track
struct MusicTrack: Identifiable, Equatable {
    let id: String
    let title: String
    let artist: String
    let albumArt: String?  // URL or asset name
    let duration: TimeInterval
    let provider: MusicProvider

    static let preview = MusicTrack(
        id: "1",
        title: "Workout Mode",
        artist: "Various Artists",
        albumArt: nil,
        duration: 180,
        provider: .spotify
    )
}

// MARK: - Music Playlist
struct MusicPlaylist: Identifiable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let trackCount: Int
    let provider: MusicProvider
    let isWorkoutPlaylist: Bool

    static let previewPlaylists: [MusicPlaylist] = [
        MusicPlaylist(
            id: "1",
            name: "Stretch & Flow",
            description: "Chill beats for deep stretching",
            imageUrl: nil,
            trackCount: 45,
            provider: .spotify,
            isWorkoutPlaylist: true
        ),
        MusicPlaylist(
            id: "2",
            name: "Morning Mobility",
            description: "Energizing tracks to start your day",
            imageUrl: nil,
            trackCount: 32,
            provider: .appleMusic,
            isWorkoutPlaylist: true
        ),
        MusicPlaylist(
            id: "3",
            name: "Deep Focus",
            description: "Concentration and mindfulness",
            imageUrl: nil,
            trackCount: 67,
            provider: .spotify,
            isWorkoutPlaylist: false
        ),
        MusicPlaylist(
            id: "4",
            name: "Lo-Fi Beats",
            description: "Relaxing background music",
            imageUrl: nil,
            trackCount: 89,
            provider: .appleMusic,
            isWorkoutPlaylist: true
        ),
    ]
}

// MARK: - Music State
enum MusicPlaybackState {
    case stopped
    case playing
    case paused
    case loading
}

// MARK: - Music Service
@MainActor
class MusicService: ObservableObject {
    static let shared = MusicService()

    // Connection state
    @Published var connectedProvider: MusicProvider = .none
    @Published var isAppleMusicAuthorized = false
    @Published var isSpotifyConnected = false

    // Playback state
    @Published var playbackState: MusicPlaybackState = .stopped
    @Published var currentTrack: MusicTrack?
    @Published var currentPlaylist: MusicPlaylist?
    @Published var trackProgress: Double = 0  // 0-1
    @Published var volume: Float = 0.8

    // Coach ducking - lowers music when coach speaks
    @Published var isCoachSpeaking = false
    @Published var duckingLevel: Float = 0.3  // Volume during coach speech

    // Playlists
    @Published var workoutPlaylists: [MusicPlaylist] = MusicPlaylist.previewPlaylists
    @Published var recentPlaylists: [MusicPlaylist] = []

    // Settings
    @Published var autoPlayOnWorkoutStart = true
    @Published var shuffleEnabled = true
    @Published var repeatEnabled = false

    private var progressTimer: Timer?
    private var normalVolume: Float = 0.8

    init() {
        loadSettings()
    }

    // MARK: - Apple Music Integration

    func requestAppleMusicAuthorization() async -> Bool {
        // In a real app, this would use MusicAuthorization.request()
        // For now, simulate authorization
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isAppleMusicAuthorized = true
        connectedProvider = .appleMusic
        saveSettings()
        return true
    }

    func disconnectAppleMusic() {
        isAppleMusicAuthorized = false
        if connectedProvider == .appleMusic {
            connectedProvider = .none
        }
        saveSettings()
    }

    // MARK: - Spotify Integration

    func connectSpotify() async -> Bool {
        // In a real app, this would use SpotifyiOS SDK
        // SPTAppRemote.connectionParameters.clientID
        // Open Spotify auth URL, handle callback
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isSpotifyConnected = true
        connectedProvider = .spotify
        saveSettings()
        return true
    }

    func disconnectSpotify() {
        isSpotifyConnected = false
        if connectedProvider == .spotify {
            connectedProvider = .none
        }
        saveSettings()
    }

    // MARK: - Playback Control

    func play(playlist: MusicPlaylist? = nil) {
        if let playlist = playlist {
            currentPlaylist = playlist
            // In real app: Start playing the playlist via SDK
        }

        playbackState = .playing
        startProgressTimer()

        // Simulate current track
        if currentTrack == nil {
            currentTrack = MusicTrack(
                id: UUID().uuidString,
                title: "Flow State",
                artist: "Mobility Mix",
                albumArt: nil,
                duration: 240,
                provider: connectedProvider
            )
        }
    }

    func pause() {
        playbackState = .paused
        progressTimer?.invalidate()
    }

    func resume() {
        playbackState = .playing
        startProgressTimer()
    }

    func stop() {
        playbackState = .stopped
        progressTimer?.invalidate()
        currentTrack = nil
        trackProgress = 0
    }

    func skipNext() {
        // In real app: Skip to next track via SDK
        trackProgress = 0
        currentTrack = MusicTrack(
            id: UUID().uuidString,
            title: "Next Track",
            artist: "Various Artists",
            albumArt: nil,
            duration: 200,
            provider: connectedProvider
        )
    }

    func skipPrevious() {
        // In real app: Skip to previous track via SDK
        trackProgress = 0
    }

    func setVolume(_ newVolume: Float) {
        volume = newVolume
        normalVolume = newVolume
        // In real app: Set system volume or SDK volume
    }

    // MARK: - Coach Ducking

    func startCoachSpeaking() {
        guard !isCoachSpeaking else { return }
        isCoachSpeaking = true

        // Lower volume for coach audio
        withAnimation(.easeInOut(duration: 0.3)) {
            volume = normalVolume * duckingLevel
        }
        // In real app: Apply volume change via SDK
    }

    func stopCoachSpeaking() {
        guard isCoachSpeaking else { return }
        isCoachSpeaking = false

        // Restore volume
        withAnimation(.easeInOut(duration: 0.5)) {
            volume = normalVolume
        }
        // In real app: Apply volume change via SDK
    }

    // MARK: - Private Methods

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.trackProgress < 1.0 {
                    self.trackProgress += 0.002
                } else {
                    self.skipNext()
                }
            }
        }
    }

    private func loadSettings() {
        if let providerRaw = UserDefaults.standard.string(forKey: "music_provider"),
           let provider = MusicProvider(rawValue: providerRaw) {
            connectedProvider = provider
        }
        autoPlayOnWorkoutStart = UserDefaults.standard.bool(forKey: "music_autoplay")
        shuffleEnabled = UserDefaults.standard.bool(forKey: "music_shuffle")
    }

    private func saveSettings() {
        UserDefaults.standard.set(connectedProvider.rawValue, forKey: "music_provider")
        UserDefaults.standard.set(autoPlayOnWorkoutStart, forKey: "music_autoplay")
        UserDefaults.standard.set(shuffleEnabled, forKey: "music_shuffle")
    }
}

// MARK: - Music Mini Player
struct MusicMiniPlayer: View {
    @ObservedObject var musicService: MusicService
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Mini player bar
            HStack(spacing: 14) {
                // Album art / provider icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(musicService.connectedProvider.brandColor)
                        .frame(width: 44, height: 44)

                    if musicService.currentTrack != nil {
                        Image(systemName: "music.note")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: musicService.connectedProvider.icon)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    if let track = musicService.currentTrack {
                        Text(track.title)
                            .font(FLEKKSFonts.bodySemibold(14))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        Text(track.artist)
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                            .lineLimit(1)
                    } else {
                        Text("No music playing")
                            .font(FLEKKSFonts.bodyMedium(14))
                            .foregroundColor(.textSecondary)

                        Text("Tap to select a playlist")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: 16) {
                    Button(action: {
                        if musicService.playbackState == .playing {
                            musicService.pause()
                        } else {
                            musicService.play()
                        }
                    }) {
                        Image(systemName: musicService.playbackState == .playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.textPrimary)
                    }

                    Button(action: { musicService.skipNext() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                    }

                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textMuted)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Progress bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(musicService.connectedProvider.color)
                    .frame(width: geometry.size.width * musicService.trackProgress, height: 3)
            }
            .frame(height: 3)
            .background(Color.bgElevated)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        .sheet(isPresented: $isExpanded) {
            MusicPlayerSheet(musicService: musicService)
        }
    }
}

// MARK: - Music Player Sheet
struct MusicPlayerSheet: View {
    @ObservedObject var musicService: MusicService
    @Environment(\.dismiss) private var dismiss
    @State private var showPlaylistPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 32) {
                    // Album Art
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(musicService.connectedProvider.brandColor)
                            .frame(width: 280, height: 280)
                            .shadow(color: musicService.connectedProvider.color.opacity(0.4), radius: 30, y: 20)

                        Image(systemName: "music.note")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 20)

                    // Track Info
                    VStack(spacing: 8) {
                        if let track = musicService.currentTrack {
                            Text(track.title)
                                .font(FLEKKSFonts.heading(24))
                                .foregroundColor(.textPrimary)

                            Text(track.artist)
                                .font(FLEKKSFonts.bodyMedium(16))
                                .foregroundColor(.textSecondary)
                        } else {
                            Text("Select a Playlist")
                                .font(FLEKKSFonts.heading(24))
                                .foregroundColor(.textPrimary)
                        }
                    }

                    // Progress slider
                    VStack(spacing: 8) {
                        Slider(value: $musicService.trackProgress)
                            .tint(musicService.connectedProvider.color)

                        HStack {
                            Text(formatTime(musicService.trackProgress * (musicService.currentTrack?.duration ?? 240)))
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)

                            Spacer()

                            Text(formatTime(musicService.currentTrack?.duration ?? 240))
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Playback Controls
                    HStack(spacing: 40) {
                        Button(action: { musicService.shuffleEnabled.toggle() }) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 20))
                                .foregroundColor(musicService.shuffleEnabled ? musicService.connectedProvider.color : .textMuted)
                        }

                        Button(action: { musicService.skipPrevious() }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.textPrimary)
                        }

                        Button(action: {
                            if musicService.playbackState == .playing {
                                musicService.pause()
                            } else {
                                musicService.play()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(musicService.connectedProvider.brandColor)
                                    .frame(width: 70, height: 70)

                                Image(systemName: musicService.playbackState == .playing ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }

                        Button(action: { musicService.skipNext() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.textPrimary)
                        }

                        Button(action: { musicService.repeatEnabled.toggle() }) {
                            Image(systemName: "repeat")
                                .font(.system(size: 20))
                                .foregroundColor(musicService.repeatEnabled ? musicService.connectedProvider.color : .textMuted)
                        }
                    }

                    // Volume Control
                    HStack(spacing: 14) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)

                        Slider(value: $musicService.volume, in: 0...1)
                            .tint(musicService.connectedProvider.color)

                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }
                    .padding(.horizontal, 20)

                    // Coach Ducking Indicator
                    if musicService.isCoachSpeaking {
                        HStack(spacing: 8) {
                            Image(systemName: "waveform")
                                .font(.system(size: 14))
                            Text("Volume lowered for coaching")
                                .font(FLEKKSFonts.labelMedium)
                        }
                        .foregroundColor(.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.accentGlow)
                        .clipShape(Capsule())
                    }

                    // Playlist Button
                    Button(action: { showPlaylistPicker = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "list.bullet")
                            Text(musicService.currentPlaylist?.name ?? "Choose Playlist")
                        }
                        .font(FLEKKSFonts.bodyMedium(15))
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.bgElevated)
                        .clipShape(Capsule())
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("NOW PLAYING")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                            .tracking(1.5)

                        HStack(spacing: 6) {
                            Image(systemName: musicService.connectedProvider.icon)
                                .font(.system(size: 12))
                            Text(musicService.connectedProvider.rawValue)
                                .font(FLEKKSFonts.labelMedium)
                        }
                        .foregroundColor(musicService.connectedProvider.color)
                    }
                }
            }
            .sheet(isPresented: $showPlaylistPicker) {
                PlaylistPickerSheet(musicService: musicService)
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Playlist Picker Sheet
struct PlaylistPickerSheet: View {
    @ObservedObject var musicService: MusicService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Workout Playlists
                        VStack(alignment: .leading, spacing: 14) {
                            Text("WORKOUT PLAYLISTS")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            VStack(spacing: 10) {
                                ForEach(musicService.workoutPlaylists.filter { $0.isWorkoutPlaylist }) { playlist in
                                    PlaylistRow(
                                        playlist: playlist,
                                        isSelected: musicService.currentPlaylist?.id == playlist.id,
                                        onSelect: {
                                            musicService.play(playlist: playlist)
                                            dismiss()
                                        }
                                    )
                                }
                            }
                        }

                        // Other Playlists
                        VStack(alignment: .leading, spacing: 14) {
                            Text("YOUR PLAYLISTS")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            VStack(spacing: 10) {
                                ForEach(musicService.workoutPlaylists.filter { !$0.isWorkoutPlaylist }) { playlist in
                                    PlaylistRow(
                                        playlist: playlist,
                                        isSelected: musicService.currentPlaylist?.id == playlist.id,
                                        onSelect: {
                                            musicService.play(playlist: playlist)
                                            dismiss()
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Choose Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.accent)
                }
            }
        }
    }
}

// MARK: - Playlist Row
struct PlaylistRow: View {
    let playlist: MusicPlaylist
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Playlist image
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(playlist.provider.brandColor)
                        .frame(width: 56, height: 56)

                    Image(systemName: playlist.isWorkoutPlaylist ? "figure.run" : "music.note.list")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.name)
                        .font(FLEKKSFonts.bodySemibold(15))
                        .foregroundColor(.textPrimary)

                    HStack(spacing: 8) {
                        Image(systemName: playlist.provider.icon)
                            .font(.system(size: 10))
                            .foregroundColor(playlist.provider.color)

                        Text("\(playlist.trackCount) songs")
                            .font(FLEKKSFonts.labelSmall)
                            .foregroundColor(.textMuted)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.accent)
                } else {
                    Image(systemName: "play.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.textMuted)
                }
            }
            .padding(14)
            .background(isSelected ? Color.accentGlow : Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accent.opacity(0.3) : FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Music Settings View
struct MusicSettingsView: View {
    @ObservedObject var musicService: MusicService
    @Environment(\.dismiss) private var dismiss
    @State private var isConnecting = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Connected Status
                        if musicService.connectedProvider != .none {
                            connectedProviderCard
                        }

                        // Connect Options
                        VStack(alignment: .leading, spacing: 14) {
                            Text("MUSIC SERVICES")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            // Apple Music
                            MusicProviderCard(
                                provider: .appleMusic,
                                isConnected: musicService.isAppleMusicAuthorized,
                                isConnecting: isConnecting && musicService.connectedProvider != .appleMusic,
                                onConnect: connectAppleMusic,
                                onDisconnect: { musicService.disconnectAppleMusic() }
                            )

                            // Spotify
                            MusicProviderCard(
                                provider: .spotify,
                                isConnected: musicService.isSpotifyConnected,
                                isConnecting: isConnecting && musicService.connectedProvider != .spotify,
                                onConnect: connectSpotify,
                                onDisconnect: { musicService.disconnectSpotify() }
                            )
                        }

                        // Playback Settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PLAYBACK SETTINGS")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            VStack(spacing: 0) {
                                SettingsToggleRow(
                                    icon: "play.circle",
                                    title: "Auto-play on workout start",
                                    isOn: $musicService.autoPlayOnWorkoutStart
                                )

                                Divider().background(Color.border)

                                SettingsToggleRow(
                                    icon: "shuffle",
                                    title: "Shuffle by default",
                                    isOn: $musicService.shuffleEnabled
                                )
                            }
                            .background(Color.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Coach Ducking Settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("COACH AUDIO")
                                .font(FLEKKSFonts.labelSmall)
                                .foregroundColor(.textMuted)
                                .tracking(1.5)

                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Volume during coaching")
                                            .font(FLEKKSFonts.bodyMedium(15))
                                            .foregroundColor(.textPrimary)

                                        Text("Music lowers when coach speaks")
                                            .font(FLEKKSFonts.labelSmall)
                                            .foregroundColor(.textMuted)
                                    }

                                    Spacer()

                                    Text("\(Int(musicService.duckingLevel * 100))%")
                                        .font(FLEKKSFonts.bodySemibold(14))
                                        .foregroundColor(.accent)
                                }

                                Slider(value: $musicService.duckingLevel, in: 0.1...0.5)
                                    .tint(.accent)
                            }
                            .padding(16)
                            .background(Color.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Info
                        VStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.textMuted)

                            Text("Connect your music service to play your favorite playlists during workouts. Music volume automatically adjusts when your coach is speaking.")
                                .font(FLEKKSFonts.body(13))
                                .foregroundColor(.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.accent)
                }
            }
        }
    }

    private var connectedProviderCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(musicService.connectedProvider.brandColor)
                    .frame(width: 50, height: 50)

                Image(systemName: musicService.connectedProvider.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Connected to")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(.textMuted)

                Text(musicService.connectedProvider.rawValue)
                    .font(FLEKKSFonts.bodySemibold(16))
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.accent)
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(FLEKKSGradients.borderGradient, lineWidth: 1.5)
        )
    }

    private func connectAppleMusic() {
        isConnecting = true
        Task {
            _ = await musicService.requestAppleMusicAuthorization()
            isConnecting = false
        }
    }

    private func connectSpotify() {
        isConnecting = true
        Task {
            _ = await musicService.connectSpotify()
            isConnecting = false
        }
    }
}

// MARK: - Music Provider Card
struct MusicProviderCard: View {
    let provider: MusicProvider
    let isConnected: Bool
    let isConnecting: Bool
    let onConnect: () -> Void
    let onDisconnect: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isConnected ? provider.brandColor : LinearGradient(colors: [Color.bgElevated], startPoint: .top, endPoint: .bottom))
                    .frame(width: 50, height: 50)

                Image(systemName: provider.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isConnected ? .white : .textMuted)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(provider.rawValue)
                    .font(FLEKKSFonts.bodySemibold(15))
                    .foregroundColor(.textPrimary)

                Text(isConnected ? "Connected" : "Tap to connect")
                    .font(FLEKKSFonts.labelSmall)
                    .foregroundColor(isConnected ? .accent : .textMuted)
            }

            Spacer()

            if isConnecting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: provider.color))
            } else if isConnected {
                Button("Disconnect") {
                    onDisconnect()
                }
                .font(FLEKKSFonts.labelMedium)
                .foregroundColor(.flekksRed)
            } else {
                Button("Connect") {
                    onConnect()
                }
                .font(FLEKKSFonts.bodySemibold(14))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(provider.brandColor)
                .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isConnected ? provider.color.opacity(0.3) : FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.accent)
                    .frame(width: 24)

                Text(title)
                    .font(FLEKKSFonts.bodyMedium(15))
                    .foregroundColor(.textPrimary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .accent))
        .padding(16)
    }
}

#Preview {
    MusicSettingsView(musicService: MusicService.shared)
}
