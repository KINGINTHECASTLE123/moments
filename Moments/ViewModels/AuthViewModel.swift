import FirebaseAuth

enum AuthState: Equatable {
    case unknown
    case signedOut
    case signedIn(uid: String)
}

@Observable
final class AuthViewModel {
    private let authService: AuthServiceProtocol
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    var authState: AuthState = .unknown
    var errorMessage: String?
    var isLoading = false

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        listenForAuthChanges()
    }

    deinit {
        if let handle = listenerHandle {
            authService.removeStateDidChangeListener(handle)
        }
    }

    private func listenForAuthChanges() {
        listenerHandle = authService.addStateDidChangeListener { [weak self] user in
            Task { @MainActor in
                if let user {
                    self?.authState = .signedIn(uid: user.uid)
                } else {
                    self?.authState = .signedOut
                }
            }
        }
    }

    @MainActor
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func createAccount(email: String, password: String) async -> String? {
        isLoading = true
        errorMessage = nil
        do {
            let uid = try await authService.createAccount(email: email, password: password)
            isLoading = false
            return uid
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    @MainActor
    func sendPasswordReset(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.sendPasswordReset(email: email)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func deleteAccount() async {
        isLoading = true
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
