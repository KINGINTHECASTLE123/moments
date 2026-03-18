import FirebaseAuth

enum AuthState: Equatable {
    case unknown
    case signedOut
    case signedIn(uid: String)
}

@Observable @MainActor
final class AuthViewModel {
    private let authService: AuthServiceProtocol
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    var authState: AuthState = .unknown
    var errorMessage: String?
    var isLoading = false

    init(authService: (any AuthServiceProtocol)? = nil) {
        let service = authService ?? AuthService()
        self.authService = service
        listenForAuthChanges()
    }

    // Note: AuthViewModel is @State in MomentsApp and lives for the app's
    // entire lifetime, so deinit is never called in practice.
    // If this ever changes, use Task { @MainActor in ... } for safe cleanup.

    private func listenForAuthChanges() {
        listenerHandle = authService.addStateDidChangeListener { [weak self] user in
            let newState: AuthState = user.map { .signedIn(uid: $0.uid) } ?? .signedOut
            Task { @MainActor [weak self] in
                self?.authState = newState
            }
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
        }
        isLoading = false
    }

    func createAccount(email: String, password: String) async -> String? {
        isLoading = true
        errorMessage = nil
        do {
            let uid = try await authService.createAccount(email: email, password: password)
            isLoading = false
            return uid
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
            isLoading = false
            return nil
        }
    }

    func sendPasswordReset(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.sendPasswordReset(email: email)
            isLoading = false
            return true
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
            isLoading = false
            return false
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
        }
    }

    func deleteAccount() async {
        isLoading = true
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
        }
        isLoading = false
    }

    func updateEmail(to newEmail: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.updateEmail(to: newEmail)
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
        }
        isLoading = false
    }

    func updatePassword(to newPassword: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.updatePassword(to: newPassword)
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
        }
        isLoading = false
    }

    func reauthenticate(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.reauthenticate(email: email, password: password)
            isLoading = false
            return true
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
            isLoading = false
            return false
        }
    }
}
