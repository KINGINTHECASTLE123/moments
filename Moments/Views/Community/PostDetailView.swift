import SwiftUI

struct PostDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    let post: FirestorePost
    @State private var commentText = ""
    @State private var showDeleteConfirmation = false
    @FocusState private var isCommentFocused: Bool

    private var latestPost: FirestorePost {
        communityViewModel.posts.first(where: { $0.id == post.id }) ?? post
    }

    private var canDelete: Bool {
        if case .signedIn(let uid) = authViewModel.authState {
            return latestPost.authorUID == uid
        }
        return false
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            UserAvatarView(
                                imageURL: latestPost.authorProfileImageURL,
                                fallbackText: String(latestPost.authorUsername.prefix(1)).uppercased(),
                                size: 40
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(latestPost.authorUsername)
                                    .font(MomentsStyle.systemMedium(15))
                                    .foregroundColor(MomentsStyle.primaryText)

                                Text(latestPost.createdAt.relativeMomentsTimestamp)
                                    .font(MomentsStyle.systemLight(12))
                                    .foregroundColor(MomentsStyle.secondaryText)
                            }

                            Spacer()

                            if let tag = latestPost.tag {
                                PillTag(label: tag)
                            }
                        }

                        Text(latestPost.body)
                            .font(MomentsStyle.systemLight(15))
                            .foregroundColor(MomentsStyle.primaryText)
                            .lineSpacing(5)

                        if let imageURL = latestPost.imageURL {
                            RemotePostImageView(urlString: imageURL)
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        HStack(spacing: 24) {
                            Button {
                                guard case .signedIn(let uid) = authViewModel.authState, let postID = latestPost.id else { return }
                                Task {
                                    await communityViewModel.toggleLike(postID: postID, uid: uid)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: latestPost.isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 16, weight: .light))
                                    Text("\(latestPost.likes)")
                                        .font(MomentsStyle.systemRegular(13))
                                }
                                .foregroundColor(latestPost.isLiked ? MomentsStyle.primaryText : MomentsStyle.secondaryText)
                            }
                            .buttonStyle(.plain)

                            HStack(spacing: 6) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 16, weight: .light))
                                Text("\(communityViewModel.liveComments.count)")
                                    .font(MomentsStyle.systemRegular(13))
                            }
                            .foregroundColor(MomentsStyle.secondaryText)

                            Spacer()

                            Button {
                                isCommentFocused = true
                            } label: {
                                Text("REPLY")
                                    .font(.system(size: 9, weight: .light))
                                    .tracking(2)
                                    .foregroundColor(MomentsStyle.secondaryText)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(MomentsStyle.border)

                    Text("COMMENTS")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 14)

                    VStack(spacing: 0) {
                        ForEach(communityViewModel.liveComments) { comment in
                            CommentRow(comment: comment)

                            if comment.id != communityViewModel.liveComments.last?.id {
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundColor(MomentsStyle.border)
                                    .padding(.leading, 58)
                                    .padding(.trailing, 24)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
            }

            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                HStack(spacing: 12) {
                    UserAvatarView(
                        imageURL: userViewModel.currentUser?.profileImageURL,
                        fallbackText: userViewModel.currentUser?.firstInitial ?? "M",
                        size: 30
                    )

                    TextField("Add a comment...", text: $commentText)
                        .font(MomentsStyle.systemLight(14))
                        .focused($isCommentFocused)

                    if !commentText.isEmpty {
                        Button {
                            guard
                                case .signedIn(let uid) = authViewModel.authState,
                                let postID = latestPost.id,
                                let username = userViewModel.currentUser?.username
                            else { return }

                            Task {
                                await communityViewModel.addComment(
                                    postID: postID,
                                    authorUID: uid,
                                    authorUsername: username,
                                    body: commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                                commentText = ""
                                isCommentFocused = false
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(MomentsStyle.primaryText)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(MomentsStyle.cardBackground)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(latestPost.authorUsername)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
            if canDelete {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        if let postID = latestPost.id, communityViewModel.deletingPostIDs.contains(postID) {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "trash")
                                .foregroundColor(MomentsStyle.primaryText)
                        }
                    }
                }
            }
        }
        .onAppear {
            guard let postID = latestPost.id else { return }
            communityViewModel.startCommentsListener(postID: postID)
        }
        .onDisappear {
            communityViewModel.stopCommentsListener()
        }
        .alert("Delete Post", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                guard let postID = latestPost.id else { return }
                Task {
                    await communityViewModel.deletePost(postID: postID)
                    if communityViewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This post will be permanently deleted.")
        }
    }
}

struct CommentRow: View {
    let comment: FirestoreComment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatarView(
                imageURL: nil,
                fallbackText: String(comment.authorUsername.prefix(1)).uppercased(),
                size: 30
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.authorUsername)
                        .font(MomentsStyle.systemMedium(13))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(comment.createdAt.relativeMomentsTimestamp)
                        .font(MomentsStyle.systemLight(11))
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                Text(comment.body)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.primaryText)
                    .lineSpacing(3)

                HStack(spacing: 4) {
                    Image(systemName: "heart")
                        .font(.system(size: 10, weight: .light))
                    Text("\(comment.likes)")
                        .font(MomentsStyle.systemLight(10))
                }
                .foregroundColor(MomentsStyle.inactive)
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: FirestorePost(
                authorUID: "1",
                authorUsername: "moments",
                authorProfileImageURL: nil,
                body: "Preview post",
                imageURL: nil,
                tag: "Moment",
                likes: 0,
                likedByUIDs: [],
                commentCount: 0,
                createdAt: .now
            )
        )
        .environment(AuthViewModel())
        .environment(UserViewModel())
        .environment(CommunityViewModel())
    }
}
