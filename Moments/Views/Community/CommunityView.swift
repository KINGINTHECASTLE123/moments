import SwiftUI

struct CommunityView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    @State private var showCreatePost = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    SectionHeader("Community", subtitle: "What's happening around you")

                    Spacer()

                    Button { showCreatePost = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(MomentsStyle.border, lineWidth: 0.5)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

                if let errorMessage = communityViewModel.errorMessage, communityViewModel.posts.isEmpty {
                    Text(errorMessage)
                        .font(MomentsStyle.systemLight(13))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }

                VStack(spacing: 14) {
                    ForEach(communityViewModel.posts) { post in
                        NavigationLink {
                            PostDetailView(post: post)
                        } label: {
                            PostCard(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .refreshable {
            Haptics.cardSettle()
            guard case .signedIn(let uid) = authViewModel.authState else { return }
            await communityViewModel.fetchPosts(currentUID: uid)
        }
        .task {
            guard case .signedIn(let uid) = authViewModel.authState else { return }
            communityViewModel.startListening(currentUID: uid)
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
    }
}

struct PostCard: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel

    let post: FirestorePost
    @State private var showDeleteConfirmation = false

    private var canDelete: Bool {
        if case .signedIn(let uid) = authViewModel.authState {
            return post.authorUID == uid
        }
        return false
    }

    private var resolvedAuthorImageURL: String? {
        if let imageURL = post.authorProfileImageURL, !imageURL.isEmpty {
            return imageURL
        }

        if case .signedIn(let uid) = authViewModel.authState, post.authorUID == uid {
            return userViewModel.currentUser?.profileImageURL
        }

        return nil
    }

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    UserAvatarView(
                        imageURL: resolvedAuthorImageURL,
                        fallbackText: String(post.authorUsername.prefix(1)).uppercased(),
                        size: 34
                    )

                    VStack(alignment: .leading, spacing: 1) {
                        Text(post.authorUsername)
                            .font(MomentsStyle.systemMedium(14))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(post.createdAt.relativeMomentsTimestamp)
                            .font(MomentsStyle.systemLight(11))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }

                    Spacer()

                    if let tag = post.tag {
                        PillTag(label: tag)
                    }

                    if canDelete, let postID = post.id {
                        Menu {
                            Button("Delete Post", role: .destructive) {
                                showDeleteConfirmation = true
                            }
                        } label: {
                            if communityViewModel.deletingPostIDs.contains(postID) {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(MomentsStyle.secondaryText)
                                    .frame(width: 28, height: 28)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(post.body)
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.primaryText)
                    .lineSpacing(4)

                if let imageURL = post.imageURL {
                    RemotePostImageView(urlString: imageURL)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack(spacing: 20) {
                    AnimatedLikeButton(isLiked: post.isLiked, count: post.likes) {
                        guard case .signedIn(let uid) = authViewModel.authState, let postID = post.id else { return }
                        Task {
                            await communityViewModel.toggleLike(postID: postID, uid: uid)
                        }
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 13, weight: .light))
                        Text("\(post.commentCount)")
                            .font(MomentsStyle.systemLight(12))
                    }
                    .foregroundColor(MomentsStyle.secondaryText)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(MomentsStyle.inactive)
                }
            }
        }
        .alert("Delete Post", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                guard let postID = post.id else { return }
                Haptics.warning()
                Task {
                    await communityViewModel.deletePost(postID: postID)
                }
            }
        } message: {
            Text("This post will be permanently deleted.")
        }
    }
}

struct RemotePostImageView: View {
    let urlString: String

    var body: some View {
        RemoteStorageImageView(urlString: urlString) {
            ZStack {
                MomentsStyle.surfaceSecondary
                Image(systemName: "photo")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(MomentsStyle.inactive)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

extension Date {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var relativeMomentsTimestamp: String {
        Date.relativeFormatter.localizedString(for: self, relativeTo: .now)
    }
}

#Preview {
    NavigationStack {
        CommunityView()
            .environment(AuthViewModel())
            .environment(UserViewModel())
            .environment(CommunityViewModel())
    }
}
