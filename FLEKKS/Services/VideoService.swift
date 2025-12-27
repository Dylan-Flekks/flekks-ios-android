import Foundation
import AVFoundation
import Supabase
#if canImport(UIKit)
import UIKit
#endif

// MARK: - File Size Limits
enum StorageLimits {
    static let maxVideoSize: Int64 = 500 * 1024 * 1024      // 500 MB
    static let maxThumbnailSize: Int64 = 1 * 1024 * 1024    // 1 MB
    static let maxAvatarSize: Int64 = 2 * 1024 * 1024       // 2 MB

    static let recommendedVideoSize: Int64 = 200 * 1024 * 1024  // 200 MB
    static let recommendedThumbnailSize: Int64 = 300 * 1024     // 300 KB
    static let recommendedAvatarSize: Int64 = 200 * 1024        // 200 KB

    static let allowedVideoTypes = ["mp4", "mov", "m4v"]
    static let allowedImageTypes = ["jpg", "jpeg", "png", "webp"]
}

// MARK: - Upload Errors
enum UploadError: LocalizedError {
    case fileTooLarge(maxSize: String, actualSize: String)
    case invalidFileType(allowed: [String])
    case fileNotFound
    case compressionFailed

    var errorDescription: String? {
        switch self {
        case .fileTooLarge(let maxSize, let actualSize):
            return "File is too large (\(actualSize)). Maximum size is \(maxSize)."
        case .invalidFileType(let allowed):
            return "Invalid file type. Allowed types: \(allowed.joined(separator: ", "))"
        case .fileNotFound:
            return "File not found."
        case .compressionFailed:
            return "Failed to compress image."
        }
    }
}

// MARK: - Video Service
// Handles video upload, streaming, and playback
@MainActor
class VideoService: ObservableObject {
    static let shared = VideoService()

    private let supabase = SupabaseService.shared

    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    @Published var errorMessage: String?

    // MARK: - Validate File Before Upload
    func validateVideo(at url: URL) throws {
        // Check file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw UploadError.fileNotFound
        }

        // Check file extension
        let ext = url.pathExtension.lowercased()
        guard StorageLimits.allowedVideoTypes.contains(ext) else {
            throw UploadError.invalidFileType(allowed: StorageLimits.allowedVideoTypes)
        }

        // Check file size
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0

        if fileSize > StorageLimits.maxVideoSize {
            throw UploadError.fileTooLarge(
                maxSize: formatBytes(StorageLimits.maxVideoSize),
                actualSize: formatBytes(fileSize)
            )
        }

        // Warn if larger than recommended (but still allow)
        if fileSize > StorageLimits.recommendedVideoSize {
            print("⚠️ Video is larger than recommended (\(formatBytes(fileSize))). Consider compressing.")
        }
    }

    func validateImage(data: Data, type: String = "image") throws {
        let maxSize: Int64 = type == "avatar" ? StorageLimits.maxAvatarSize : StorageLimits.maxThumbnailSize

        if Int64(data.count) > maxSize {
            throw UploadError.fileTooLarge(
                maxSize: formatBytes(maxSize),
                actualSize: formatBytes(Int64(data.count))
            )
        }
    }

    // MARK: - Upload Video (for coaches)
    /// Uploads a video file to Supabase Storage
    /// - Parameters:
    ///   - fileURL: Local file URL of the video
    ///   - sessionId: The session this video belongs to
    ///   - onProgress: Progress callback (0.0 - 1.0)
    /// - Returns: The signed URL of the uploaded video (private bucket)
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

        // Validate before upload
        try validateVideo(at: fileURL)

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

    // MARK: - Upload Avatar
    func uploadAvatar(
        imageData: Data,
        userId: UUID
    ) async throws -> String {
        // Validate before upload
        try validateImage(data: imageData, type: "avatar")

        do {
            let fileName = "\(userId.uuidString)/avatar.jpg"

            try await supabase.client.storage
                .from(SupabaseConfig.avatarBucket)
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )

            let publicURL = try supabase.client.storage
                .from(SupabaseConfig.avatarBucket)
                .getPublicURL(path: fileName)

            return publicURL.absoluteString

        } catch {
            throw error
        }
    }

    // MARK: - Compress Image
    func compressImage(_ imageData: Data, maxSize: Int64, quality: CGFloat = 0.8) -> Data? {
        #if canImport(UIKit)
        guard let image = UIImage(data: imageData) else { return nil }

        var compressionQuality = quality
        var compressedData = image.jpegData(compressionQuality: compressionQuality)

        // Iteratively reduce quality until under max size
        while let data = compressedData, Int64(data.count) > maxSize && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            compressedData = image.jpegData(compressionQuality: compressionQuality)
        }

        return compressedData
        #else
        return imageData
        #endif
    }
}

// MARK: - Helper Functions
func formatBytes(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
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
