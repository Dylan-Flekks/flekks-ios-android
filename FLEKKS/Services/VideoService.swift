import Foundation
import AVFoundation
import Supabase

// MARK: - Video Service
// Handles video upload, streaming, and playback
@MainActor
class VideoService: ObservableObject {
    static let shared = VideoService()

    private let supabase = SupabaseService.shared

    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    @Published var errorMessage: String?

    // MARK: - Upload Video (for coaches)
    /// Uploads a video file to Supabase Storage
    /// - Parameters:
    ///   - fileURL: Local file URL of the video
    ///   - sessionId: The session this video belongs to
    ///   - onProgress: Progress callback (0.0 - 1.0)
    /// - Returns: The public URL of the uploaded video
    func uploadVideo(
        fileURL: URL,
        sessionId: UUID,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> String {
        isUploading = true
        uploadProgress = 0
        errorMessage = nil

        defer {
            isUploading = false
        }

        do {
            let fileName = "\(sessionId.uuidString)/video.mp4"
            let fileData = try Data(contentsOf: fileURL)

            // Upload to Supabase Storage
            try await supabase.client.storage
                .from(SupabaseConfig.videoBucket)
                .upload(
                    path: fileName,
                    file: fileData,
                    options: FileOptions(
                        contentType: "video/mp4",
                        upsert: true
                    )
                )

            // Get public URL
            let publicURL = try supabase.client.storage
                .from(SupabaseConfig.videoBucket)
                .getPublicURL(path: fileName)

            uploadProgress = 1.0
            return publicURL.absoluteString

        } catch {
            errorMessage = "Failed to upload video: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Upload Thumbnail
    func uploadThumbnail(
        image: Data,
        sessionId: UUID
    ) async throws -> String {
        do {
            let fileName = "\(sessionId.uuidString)/thumbnail.jpg"

            try await supabase.client.storage
                .from(SupabaseConfig.thumbnailBucket)
                .upload(
                    path: fileName,
                    file: image,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )

            let publicURL = try supabase.client.storage
                .from(SupabaseConfig.thumbnailBucket)
                .getPublicURL(path: fileName)

            return publicURL.absoluteString

        } catch {
            throw error
        }
    }

    // MARK: - Generate Thumbnail from Video
    func generateThumbnail(from videoURL: URL) async -> Data? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)

        do {
            let cgImage = try await imageGenerator.image(at: time).image
            #if canImport(UIKit)
            import UIKit
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage.jpegData(compressionQuality: 0.8)
            #else
            return nil
            #endif
        } catch {
            print("Failed to generate thumbnail: \(error)")
            return nil
        }
    }

    // MARK: - Get Signed URL for Private Video
    func getSignedVideoURL(path: String, expiresIn: Int = 3600) async throws -> URL {
        let signedURL = try await supabase.client.storage
            .from(SupabaseConfig.videoBucket)
            .createSignedURL(path: path, expiresIn: expiresIn)

        return signedURL
    }

    // MARK: - Delete Video
    func deleteVideo(sessionId: UUID) async throws {
        let paths = [
            "\(sessionId.uuidString)/video.mp4"
        ]

        try await supabase.client.storage
            .from(SupabaseConfig.videoBucket)
            .remove(paths: paths)
    }

    // MARK: - Get Video Metadata
    func getVideoMetadata(url: URL) async -> VideoMetadata? {
        let asset = AVAsset(url: url)

        do {
            let duration = try await asset.load(.duration)
            let tracks = try await asset.load(.tracks)

            var resolution: CGSize = .zero
            if let videoTrack = tracks.first(where: { $0.mediaType == .video }) {
                resolution = try await videoTrack.load(.naturalSize)
            }

            return VideoMetadata(
                duration: duration.seconds,
                resolution: resolution
            )
        } catch {
            print("Failed to get video metadata: \(error)")
            return nil
        }
    }
}

// MARK: - Video Metadata
struct VideoMetadata {
    let duration: Double
    let resolution: CGSize

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Video Upload Request (for coach dashboard)
struct VideoUploadRequest {
    let sessionId: UUID
    let title: String
    let description: String
    let focusArea: String
    let videoFile: URL
    let thumbnailImage: Data?
}

// MARK: - Video Player State
@MainActor
class VideoPlayerState: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isBuffering = false
    @Published var playbackRate: Float = 1.0

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    func seek(to time: Double) {
        currentTime = min(max(0, time), duration)
    }

    func skipForward(_ seconds: Double = 15) {
        seek(to: currentTime + seconds)
    }

    func skipBackward(_ seconds: Double = 15) {
        seek(to: currentTime - seconds)
    }

    func togglePlayback() {
        isPlaying.toggle()
    }
}
