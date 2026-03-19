import Foundation

@Observable @MainActor
final class CommunityViewModel {
    private let postService: PostServiceProtocol
    private let storageService: StorageServiceProtocol

    var posts: [FirestorePost] = []
    var liveComments: [FirestoreComment] = []
    var isLoading = false
    var isCreatingPost = false
    var deletingPostIDs: Set<String> = []
    var deletingCommentIDs: Set<String> = []
    var errorMessage: String?

    private var postsListenerTask: Task<Void, Never>?
    private var commentsListenerTask: Task<Void, Never>?
    private var currentUID: String?
    private var pendingLikeMutations: Set<String> = []
    private var pendingDeletions: Set<String> = []

    init(
        postService: (any PostServiceProtocol)? = nil,
        storageService: (any StorageServiceProtocol)? = nil
    ) {
        self.postService = postService ?? PostService()
        self.storageService = storageService ?? StorageService()
    }

    private func setError(_ message: String) {
        errorMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            if self.errorMessage == message {
                self.errorMessage = nil
            }
        }
    }

    func fetchPosts(currentUID: String) async {
        isLoading = true
        do {
            var fetched = try await postService.fetchPosts(limit: 20)
            for i in fetched.indices {
                fetched[i].isLiked = fetched[i].likedByUIDs.contains(currentUID)
            }
            posts = fetched
        } catch {
            setError(error.localizedDescription)
        }
        isLoading = false
    }

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

    func stopListening() {
        postsListenerTask?.cancel()
        postsListenerTask = nil
        currentUID = nil
    }

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

    func stopCommentsListener() {
        commentsListenerTask?.cancel()
        commentsListenerTask = nil
    }

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
                let compressed = ImageCompressor.compress(data: imageData, maxDimension: 1200) ?? imageData
                let imageURL = try await storageService.uploadPostImage(uid: authorUID, postID: postID, imageData: compressed)
                try await postService.setPostImageURL(postID: postID, imageURL: imageURL)
            }
        } catch {
            setError(error.localizedDescription)
        }
        isCreatingPost = false
    }

    func fetchComments(postID: String) async -> [FirestoreComment] {
        do {
            return try await postService.fetchComments(postID: postID)
        } catch {
            setError(error.localizedDescription)
            return []
        }
    }

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
            setError(error.localizedDescription)
        }
    }

    func deleteComment(postID: String, commentID: String) async {
        guard !deletingCommentIDs.contains(commentID) else { return }
        deletingCommentIDs.insert(commentID)

        // Optimistic removal from live list
        let removed = liveComments.first(where: { $0.id == commentID })
        liveComments.removeAll(where: { $0.id == commentID })

        do {
            try await postService.deleteComment(postID: postID, commentID: commentID)
            if let index = posts.firstIndex(where: { $0.id == postID }) {
                posts[index].commentCount = max(0, posts[index].commentCount - 1)
            }
        } catch {
            // Revert optimistic removal
            if let removed {
                liveComments.append(removed)
                liveComments.sort { $0.createdAt < $1.createdAt }
            }
            setError(error.localizedDescription)
        }
        deletingCommentIDs.remove(commentID)
    }

    func reportComment(postID: String, commentID: String, reporterUID: String, reason: String) async {
        do {
            try await postService.reportComment(postID: postID, commentID: commentID, reporterUID: reporterUID, reason: reason)
        } catch {
            setError(error.localizedDescription)
        }
    }

    func reportPost(postID: String, reporterUID: String, reason: String) async {
        do {
            try await postService.reportPost(postID: postID, reporterUID: reporterUID, reason: reason)
        } catch {
            setError(error.localizedDescription)
        }
    }

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
                try? await storageService.deletePostImage(uid: removedPost.authorUID, postID: postID)
            }
        } catch {
            let safeIndex = min(index, posts.count)
            posts.insert(removedPost, at: safeIndex)
            pendingDeletions.remove(postID)
            setError(error.localizedDescription)
        }

        deletingPostIDs.remove(postID)
        pendingDeletions.remove(postID)
    }
}
