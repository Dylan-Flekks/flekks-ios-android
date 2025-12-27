import Foundation
import Supabase

// MARK: - Authentication Service
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    private let supabase = SupabaseService.shared

    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Sign Up with Email
    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            // Create auth user
            let authResponse = try await supabase.client.auth.signUp(
                email: email,
                password: password
            )

            guard let userId = authResponse.user?.id else {
                throw AuthError.signUpFailed
            }

            // Create user profile in database
            let newUser = DBUser(
                id: userId,
                email: email,
                name: name,
                avatarUrl: nil,
                streakCount: 0,
                totalSessions: 0,
                totalMinutes: 0,
                currentTeamId: nil,
                createdAt: Date()
            )

            try await supabase.client.database
                .from("users")
                .insert(newUser)
                .execute()

        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign In with Email
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await supabase.client.auth.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = "Invalid email or password"
            throw error
        }
    }

    // MARK: - Sign In with Apple
    func signInWithApple(idToken: String, nonce: String) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await supabase.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign In with Google
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await supabase.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Out
    func signOut() async throws {
        do {
            try await supabase.client.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Reset Password
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await supabase.client.auth.resetPasswordForEmail(email)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Update Password
    func updatePassword(newPassword: String) async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await supabase.client.auth.update(user: .init(password: newPassword))
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Check if user exists
    func checkSession() async -> Bool {
        do {
            _ = try await supabase.client.auth.session
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case signUpFailed
    case signInFailed
    case noSession
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .signUpFailed:
            return "Failed to create account. Please try again."
        case .signInFailed:
            return "Failed to sign in. Please check your credentials."
        case .noSession:
            return "No active session found."
        case .invalidCredentials:
            return "Invalid email or password."
        }
    }
}
