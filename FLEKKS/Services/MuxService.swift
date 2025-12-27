import Foundation
import AVKit

// MARK: - Mux Service
// Handles Mux video streaming for session playback
// Mux provides HLS streaming URLs and automatic thumbnails

class MuxService: ObservableObject {
    static let shared = MuxService()

    // MARK: - Configuration
    struct Config {
        // Mux domain for streaming
        static let streamDomain = "stream.mux.com"
        static let imageDomain = "image.mux.com"

        // Default thumbnail settings
        static let thumbnailWidth = 640
        static let thumbnailHeight = 360
    }

    // MARK: - Stream URL
    /// Generate HLS stream URL from Mux playback ID
    func streamURL(playbackId: String) -> URL? {
        return URL(string: "https://\(Config.streamDomain)/\(playbackId).m3u8")
    }

    // MARK: - Thumbnail URLs
    /// Generate thumbnail URL with default settings
    func thumbnailURL(playbackId: String) -> URL? {
        return URL(string: "https://\(Config.imageDomain)/\(playbackId)/thumbnail.jpg?width=\(Config.thumbnailWidth)&height=\(Config.thumbnailHeight)")
    }

    /// Generate thumbnail at specific time
    func thumbnailURL(playbackId: String, atTime seconds: Int) -> URL? {
        return URL(string: "https://\(Config.imageDomain)/\(playbackId)/thumbnail.jpg?time=\(seconds)&width=\(Config.thumbnailWidth)")
    }

    /// Generate animated GIF preview
    func gifPreviewURL(playbackId: String, start: Int = 0, duration: Int = 5) -> URL? {
        return URL(string: "https://\(Config.imageDomain)/\(playbackId)/animated.gif?start=\(start)&end=\(start + duration)&width=320")
    }

    // MARK: - AVPlayer Setup
    /// Create configured AVPlayer for Mux stream
    func createPlayer(playbackId: String) -> AVPlayer? {
        guard let url = streamURL(playbackId: playbackId) else { return nil }

        let player = AVPlayer(url: url)
        player.automaticallyWaitsToMinimizeStalling = true

        return player
    }

    /// Create AVPlayerItem with Mux optimizations
    func createPlayerItem(playbackId: String) -> AVPlayerItem? {
        guard let url = streamURL(playbackId: playbackId) else { return nil }

        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        // Prefer HLS for adaptive streaming
        item.preferredForwardBufferDuration = 10

        return item
    }
}

// MARK: - Mux Upload Service (for coaches uploading videos)
extension MuxService {

    struct UploadCredentials: Codable {
        let uploadUrl: String
        let assetId: String

        enum CodingKeys: String, CodingKey {
            case uploadUrl = "upload_url"
            case assetId = "asset_id"
        }
    }

    /// Request upload URL from your backend
    /// Your backend should call Mux API to create a direct upload
    func requestUploadURL() async throws -> UploadCredentials {
        // This would call your Supabase Edge Function or backend
        // which then calls Mux API with your secret key
        //
        // Example Edge Function would:
        // 1. Call POST https://api.mux.com/video/v1/uploads
        // 2. Return the upload URL and asset ID

        // For now, throw an error since we need backend setup
        throw MuxError.backendNotConfigured
    }

    /// Upload video to Mux using direct upload URL
    func uploadVideo(fileURL: URL, uploadURL: String, progress: @escaping (Double) -> Void) async throws {
        guard let url = URL(string: uploadURL) else {
            throw MuxError.invalidUploadURL
        }

        let fileData = try Data(contentsOf: fileURL)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("video/mp4", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.upload(for: request, from: fileData)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MuxError.uploadFailed
        }
    }

    enum MuxError: LocalizedError {
        case backendNotConfigured
        case invalidUploadURL
        case uploadFailed
        case playbackNotReady

        var errorDescription: String? {
            switch self {
            case .backendNotConfigured:
                return "Backend not configured for Mux uploads. Set up Supabase Edge Function."
            case .invalidUploadURL:
                return "Invalid upload URL received from backend."
            case .uploadFailed:
                return "Failed to upload video to Mux."
            case .playbackNotReady:
                return "Video is still processing. Please wait."
            }
        }
    }
}

// MARK: - Mux Player View (SwiftUI wrapper for AVPlayer)
import SwiftUI

struct MuxPlayerView: UIViewControllerRepresentable {
    let playbackId: String
    @Binding var isPlaying: Bool
    var onTimeUpdate: ((Double) -> Void)?
    var onComplete: (() -> Void)?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = true

        if let player = MuxService.shared.createPlayer(playbackId: playbackId) {
            controller.player = player
            context.coordinator.player = player
            context.coordinator.setupObservers()
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if isPlaying {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: MuxPlayerView
        var player: AVPlayer?
        var timeObserver: Any?

        init(_ parent: MuxPlayerView) {
            self.parent = parent
        }

        func setupObservers() {
            guard let player = player else { return }

            // Time observer for progress updates
            let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.parent.onTimeUpdate?(time.seconds)
            }

            // Completion observer
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinish),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        }

        @objc func playerDidFinish() {
            parent.onComplete?()
        }

        deinit {
            if let observer = timeObserver {
                player?.removeTimeObserver(observer)
            }
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - Thumbnail Image View
struct MuxThumbnailView: View {
    let playbackId: String
    var time: Int? = nil

    private var url: URL? {
        if let time = time {
            return MuxService.shared.thumbnailURL(playbackId: playbackId, atTime: time)
        }
        return MuxService.shared.thumbnailURL(playbackId: playbackId)
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "play.rectangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
