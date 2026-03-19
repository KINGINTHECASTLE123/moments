import FirebaseAuth

enum AuthErrorMapper {
    static func message(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else {
            return Strings.authErrorGeneric
        }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:
            return Strings.authErrorInvalidEmail
        case .wrongPassword, .invalidCredential:
            return Strings.authErrorWrongPassword
        case .userNotFound:
            return Strings.authErrorUserNotFound
        case .emailAlreadyInUse:
            return Strings.authErrorEmailInUse
        case .weakPassword:
            return Strings.authErrorWeakPassword
        case .networkError:
            return Strings.authErrorNetworkError
        case .tooManyRequests:
            return Strings.authErrorTooManyRequests
        case .userDisabled:
            return Strings.authErrorUserDisabled
        case .requiresRecentLogin:
            return Strings.authErrorRequiresRecentLogin
        default:
            return Strings.authErrorGeneric
        }
    }
}
