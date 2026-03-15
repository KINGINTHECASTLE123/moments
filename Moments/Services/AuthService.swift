import FirebaseAuth

enum AuthError: LocalizedError {
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "No user is currently signed in."
        }
    }
}

protocol AuthServiceProtocol: Sendable {
    var currentUser: FirebaseAuth.User? { get }
    func signIn(email: String, password: String) async throws
    func createAccount(email: String, password: String) async throws -> String
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func deleteAccount() async throws
    func updateEmail(to newEmail: String) async throws
    func updatePassword(to newPassword: String) async throws
    func reauthenticate(email: String, password: String) async throws
    func addStateDidChangeListener(_ callback: @escaping @Sendable (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle
    func removeStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle)
}

final class AuthService: AuthServiceProtocol {
    private let auth = Auth.auth()

    var currentUser: FirebaseAuth.User? { auth.currentUser }

    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }

    func createAccount(email: String, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else { throw AuthError.notSignedIn }
        try await user.delete()
    }

    func updateEmail(to newEmail: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.notSignedIn }
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }

    func updatePassword(to newPassword: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.notSignedIn }
        try await user.updatePassword(to: newPassword)
    }

    func reauthenticate(email: String, password: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.notSignedIn }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }

    func addStateDidChangeListener(_ callback: @escaping @Sendable (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        auth.addStateDidChangeListener { _, user in callback(user) }
    }

    func removeStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        auth.removeStateDidChangeListener(handle)
    }
}
