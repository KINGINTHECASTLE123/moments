import FirebaseAuth

enum AuthErrorMapper {
    static func message(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else {
            return "Something went wrong. Please try again."
        }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:
            return "That email address doesn't look right."
        case .wrongPassword, .invalidCredential:
            return "Incorrect email or password."
        case .userNotFound:
            return "No account found with that email."
        case .emailAlreadyInUse:
            return "An account with that email already exists."
        case .weakPassword:
            return "Password is too short — use at least 6 characters."
        case .networkError:
            return "No internet connection. Check your network and try again."
        case .tooManyRequests:
            return "Too many attempts. Wait a moment and try again."
        case .userDisabled:
            return "This account has been disabled."
        case .requiresRecentLogin:
            return "For security, please sign in again before making this change."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
