import Foundation

@Observable @MainActor
final class UserViewModel {
    private let userService: UserServiceProtocol
    private let storageService: StorageServiceProtocol

    var currentUser: UserProfile?
    var isLoading = false
    var errorMessage: String?

    init(
        userService: (any UserServiceProtocol)? = nil,
        storageService: (any StorageServiceProtocol)? = nil
    ) {
        self.userService = userService ?? UserService()
        self.storageService = storageService ?? StorageService()
    }

    func fetchCurrentUser(uid: String) async {
        isLoading = true
        do {
            currentUser = try await userService.fetchUser(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createProfile(
        uid: String,
        fullName: String,
        email: String,
        username: String,
        bio: String,
        interests: [String],
        profileImageData: Data? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        var profile = UserProfile(
            fullName: fullName,
            username: username,
            email: email,
            bio: bio,
            interests: interests,
            profileImageURL: nil,
            momentsCount: 0,
            friendsCount: 0,
            likesCount: 0,
            createdAt: Date()
        )
        do {
            if let profileImageData {
                let compressed = ImageCompressor.compress(data: profileImageData, maxDimension: 600) ?? profileImageData
                let profileImageURL = try await storageService.uploadProfileImage(uid: uid, imageData: compressed)
                profile.profileImageURL = profileImageURL
            }
            try await userService.createUser(profile, uid: uid)
            currentUser = profile
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateProfile(
        uid: String,
        fullName: String,
        username: String,
        bio: String,
        interests: [String],
        profileImageData: Data? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            var data: [String: Any] = [
                "fullName": fullName,
                "username": username,
                "bio": bio,
                "interests": interests,
            ]
            if let profileImageData {
                let compressed = ImageCompressor.compress(data: profileImageData, maxDimension: 600) ?? profileImageData
                let profileImageURL = try await storageService.uploadProfileImage(uid: uid, imageData: compressed)
                data["profileImageURL"] = profileImageURL
                currentUser?.profileImageURL = profileImageURL
            }
            try await userService.updateUser(uid: uid, data: data)
            currentUser?.fullName = fullName
            currentUser?.username = username
            currentUser?.bio = bio
            currentUser?.interests = interests
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteUserData(uid: String) async {
        do {
            try await userService.deleteUserData(uid: uid)
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateEmail(uid: String, newEmail: String) async {
        do {
            try await userService.updateUser(uid: uid, data: ["email": newEmail])
            currentUser?.email = newEmail
        } catch {
            // Non-critical: auth email is updated, Firestore will sync on next profile update
        }
    }

    func clear() {
        currentUser = nil
    }
}
