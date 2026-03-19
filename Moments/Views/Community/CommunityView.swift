import SwiftUI

struct CommunityView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    @Environment(AppLanguage.self) private var appLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var showCreatePost = false
    @State private var selectedPost: FirestorePost?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                HStack {
                    SectionHeader(Strings.communityTitle, subtitle: Strings.communitySubtitle)

                    Spacer()

                    Button { showCreatePost = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 34, height: 34)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.glass)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)

                if let errorMessage = communityViewModel.errorMessage, communityViewModel.posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(MomentsStyle.inactive)

                        Text(Strings.communityCouldntLoad)
                            .font(MomentsStyle.systemMedium(16))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(errorMessage)
                            .font(MomentsStyle.systemLight(13))
                            .foregroundColor(MomentsStyle.secondaryText)
                            .multilineTextAlignment(.center)

                        Button {
                            guard case .signedIn(let uid) = authViewModel.authState else { return }
                            Task { await communityViewModel.fetchPosts(currentUID: uid) }
                        } label: {
                            Text(Strings.communityTryAgain)
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundColor(MomentsStyle.primaryText)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .overlay(
                                    Capsule()
                                        .stroke(MomentsStyle.border, lineWidth: 0.5)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                if communityViewModel.posts.isEmpty && !communityViewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(MomentsStyle.inactive)

                        Text(Strings.communityEmptyTitle)
                            .font(MomentsStyle.georgiaItalic(22))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(Strings.communityEmptySubtitle)
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)
                            .multilineTextAlignment(.center)

                        Button { showCreatePost = true } label: {
                            Text(Strings.communityCreatePost)
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundColor(MomentsStyle.background)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(MomentsStyle.primaryText)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 14) {
                        ForEach(communityViewModel.posts) { post in
                            Button {
                                selectedPost = post
                            } label: {
                                PostCard(post: post)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 32)
            }
            }
            .background(MomentsStyle.background)
            .navigationDestination(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(Strings.tabHome)
                }
            }
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
                            Button(Strings.communityDeletePost, role: .destructive) {
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
        .alert(Strings.communityDeletePost, isPresented: $showDeleteConfirmation) {
            Button(Strings.communityCancel, role: .cancel) { }
            Button(Strings.communityDelete, role: .destructive) {
                guard let postID = post.id else { return }
                Haptics.warning()
                Task {
                    await communityViewModel.deletePost(postID: postID)
                }
            }
        } message: {
            Text(Strings.communityDeletePostConfirmation)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(post.authorUsername) posted: \(post.body). \(post.likes) likes, \(post.commentCount) comments")
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
            .environment(AppLanguage.shared)
    }
}
