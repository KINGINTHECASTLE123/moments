import Foundation

@Observable
final class UserViewModel {
    private let userService: UserServiceProtocol
    private let storageService: StorageServiceProtocol

    var currentUser: UserProfile?
    var isLoading = false
    var errorMessage: String?

    init(
        userService: UserServiceProtocol = UserService(),
        storageService: StorageServiceProtocol = StorageService()
    ) {
        self.userService = userService
        self.storageService = storageService
    }

    @MainActor
    func fetchCurrentUser(uid: String) async {
        isLoading = true
        do {
            currentUser = try await userService.fetchUser(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
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
                let profileImageURL = try await storageService.uploadProfileImage(uid: uid, imageData: profileImageData)
                profile.profileImageURL = profileImageURL
            }
            try await userService.createUser(profile, uid: uid)
            currentUser = profile
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
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
                let profileImageURL = try await storageService.uploadProfileImage(uid: uid, imageData: profileImageData)
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

    @MainActor
    func deleteUserData(uid: String) async {
        do {
            try await userService.deleteUserData(uid: uid)
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clear() {
        currentUser = nil
    }
}
