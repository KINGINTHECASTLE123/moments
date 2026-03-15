import Foundation

@Observable
final class CommunityViewModel {
    private let postService: PostServiceProtocol
    private let storageService: StorageServiceProtocol

    var posts: [FirestorePost] = []
    var liveComments: [FirestoreComment] = []
    var isLoading = false
    var isCreatingPost = false
    var deletingPostIDs: Set<String> = []
    var errorMessage: String?

    private var postsListenerTask: Task<Void, Never>?
    private var commentsListenerTask: Task<Void, Never>?
    private var currentUID: String?
    private var pendingLikeMutations: Set<String> = []
    private var pendingDeletions: Set<String> = []

    init(
        postService: PostServiceProtocol = PostService(),
        storageService: StorageServiceProtocol = StorageService()
    ) {
        self.postService = postService
        self.storageService = storageService
    }

    @MainActor
    func fetchPosts(currentUID: String) async {
        isLoading = true
        do {
            var fetched = try await postService.fetchPosts(limit: 20)
            for i in fetched.indices {
                fetched[i].isLiked = fetched[i].likedByUIDs.contains(currentUID)
            }
            posts = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func startListening(currentUID: String) {
        guard postsListenerTask == nil || self.currentUID != currentUID else { return }
        stopListening()
        self.currentUID = currentUID
        isLoading = posts.isEmpty

        postsListenerTask = Task {
            for await rawPosts in postService.postsStream(limit: 20) {
                guard !Task.isCancelled else { break }
                var enriched = rawPosts.filter { post in
                    guard let id = post.id else { return true }
                    return !pendingDeletions.contains(id)
                }
                for i in enriched.indices {
                    enriched[i].isLiked = enriched[i].likedByUIDs.contains(currentUID)
                    if let postID = enriched[i].id, pendingLikeMutations.contains(postID),
                       let existing = self.posts.first(where: { $0.id == postID }) {
                        enriched[i].isLiked = existing.isLiked
                        enriched[i].likes = existing.likes
                    }
                }
                self.posts = enriched
                self.isLoading = false
            }
        }
    }

    @MainActor
    func stopListening() {
        postsListenerTask?.cancel()
        postsListenerTask = nil
        currentUID = nil
    }

    @MainActor
    func startCommentsListener(postID: String) {
        stopCommentsListener()
        liveComments = []

        commentsListenerTask = Task {
            for await comments in postService.commentsStream(postID: postID) {
                guard !Task.isCancelled else { break }
                self.liveComments = comments
            }
        }
    }

    @MainActor
    func stopCommentsListener() {
        commentsListenerTask?.cancel()
        commentsListenerTask = nil
    }

    @MainActor
    func toggleLike(postID: String, uid: String) async {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        let isLiked = posts[index].isLiked

        // Optimistic update
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
        pendingLikeMutations.insert(postID)

        do {
            try await postService.toggleLike(postID: postID, uid: uid, isCurrentlyLiked: isLiked)
        } catch {
            // Revert on failure
            if let idx = posts.firstIndex(where: { $0.id == postID }) {
                posts[idx].isLiked.toggle()
                posts[idx].likes += posts[idx].isLiked ? 1 : -1
            }
        }
        pendingLikeMutations.remove(postID)
    }

    @MainActor
    func addPost(
        authorUID: String,
        authorUsername: String,
        authorProfileImageURL: String?,
        body: String,
        tag: String?,
        imageData: Data? = nil
    ) async {
        guard !isCreatingPost else { return }
        isCreatingPost = true
        errorMessage = nil

        let post = FirestorePost(
            authorUID: authorUID,
            authorUsername: authorUsername,
            authorProfileImageURL: authorProfileImageURL,
            body: body,
            imageURL: nil,
            tag: tag,
            likes: 0,
            likedByUIDs: [],
            commentCount: 0,
            createdAt: Date()
        )

        do {
            let postID = try await postService.createPost(post)
            if let imageData {
                let imageURL = try await storageService.uploadPostImage(postID: postID, imageData: imageData)
                try await postService.updatePost(postID: postID, data: ["imageURL": imageURL])
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isCreatingPost = false
    }

    func fetchComments(postID: String) async -> [FirestoreComment] {
        do {
            return try await postService.fetchComments(postID: postID)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }

    @MainActor
    func addComment(postID: String, authorUID: String, authorUsername: String, body: String) async {
        let comment = FirestoreComment(
            authorUID: authorUID,
            authorUsername: authorUsername,
            body: body,
            likes: 0,
            createdAt: Date()
        )
        do {
            try await postService.addComment(postID: postID, comment: comment)
            if let index = posts.firstIndex(where: { $0.id == postID }) {
                posts[index].commentCount += 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func deletePost(postID: String) async {
        guard !deletingPostIDs.contains(postID) else { return }
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }

        errorMessage = nil
        deletingPostIDs.insert(postID)
        pendingDeletions.insert(postID)
        let removedPost = posts.remove(at: index)

        do {
            try await postService.deletePost(postID: postID)
            if removedPost.imageURL != nil {
                try? await storageService.deletePostImage(postID: postID)
            }
        } catch {
            posts.insert(removedPost, at: index)
            pendingDeletions.remove(postID)
            errorMessage = error.localizedDescription
        }

        deletingPostIDs.remove(postID)
        pendingDeletions.remove(postID)
    }
}
