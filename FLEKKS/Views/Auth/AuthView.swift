import SwiftUI
import AuthenticationServices

// MARK: - Auth View (Login/Signup)
struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authService = AuthService.shared

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var showError = false
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            // Background glow
            Circle()
                .fill(FLEKKSGradients.tealGlowSoft)
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -200)
                .scaleEffect(isGlowing ? 1.1 : 1.0)
                .opacity(isGlowing ? 0.7 : 0.4)

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("FLĒKKS")
                            .font(FLEKKSFonts.headingHeavy(36))
                            .foregroundStyle(FLEKKSGradients.accentGradientVibrant)

                        Text(isSignUp ? "Create your account" : "Welcome back")
                            .font(FLEKKSFonts.heading(24))
                            .foregroundColor(.textPrimary)

                        Text(isSignUp ? "Start your flexibility journey" : "Continue your flexibility journey")
                            .font(FLEKKSFonts.body(14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, 60)

                    // Form
                    VStack(spacing: 16) {
                        if isSignUp {
                            AuthTextField(
                                icon: "person.fill",
                                placeholder: "Full Name",
                                text: $name
                            )
                        }

                        AuthTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        AuthTextField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true
                        )

                        if !isSignUp {
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    // Handle forgot password
                                }
                                .font(FLEKKSFonts.bodySemibold(13))
                                .foregroundStyle(FLEKKSGradients.accentGradient)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Submit Button
                    Button(action: handleSubmit) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .bgPrimary))
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: !isFormValid))
                    .disabled(!isFormValid || authService.isLoading)
                    .padding(.horizontal, 24)

                    // Divider
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(Color.border)
                            .frame(height: 1)
                        Text("or")
                            .font(FLEKKSFonts.bodyMedium(13))
                            .foregroundColor(.textMuted)
                        Rectangle()
                            .fill(Color.border)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Social Login
                    VStack(spacing: 12) {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(14)

                        Button(action: handleGoogleSignIn) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                Text("Continue with Google")
                                    .font(FLEKKSFonts.bodySemibold(15))
                            }
                            .foregroundColor(.textPrimary)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    // Toggle
                    Button(action: { withAnimation { isSignUp.toggle() } }) {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.textSecondary)
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .foregroundStyle(FLEKKSGradients.accentGradient)
                                .fontWeight(.bold)
                        }
                        .font(FLEKKSFonts.body(14))
                    }
                    .padding(.top, 16)

                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "An error occurred")
        }
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && password.count >= 6
        }
        return !email.isEmpty && !password.isEmpty
    }

    // MARK: - Actions
    private func handleSubmit() {
        Task {
            do {
                if isSignUp {
                    try await appState.signUp(email: email, password: password, name: name)
                } else {
                    try await appState.signIn(email: email, password: password)
                }
            } catch {
                showError = true
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential,
               let tokenData = credential.identityToken,
               let token = String(data: tokenData, encoding: .utf8) {
                Task {
                    do {
                        // Note: nonce handling required for production
                        try await authService.signInWithApple(idToken: token, nonce: "")
                        appState.isLoggedIn = true
                        appState.currentScreen = .quiz
                    } catch {
                        showError = true
                    }
                }
            }
        case .failure:
            showError = true
        }
    }

    private func handleGoogleSignIn() {
        // Google Sign-In implementation
        // Requires GoogleSignIn SDK
    }
}

// MARK: - Auth Text Field
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isEditing ? .accent : .textMuted)
                .frame(width: 24)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(FLEKKSFonts.body(15))
                    .foregroundColor(.textPrimary)
            } else {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = editing
                    }
                })
                .font(FLEKKSFonts.body(15))
                .foregroundColor(.textPrimary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isEditing ? FLEKKSGradients.borderGradient : LinearGradient(colors: [Color.border], startPoint: .top, endPoint: .bottom),
                    lineWidth: isEditing ? 1.5 : 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
