import SwiftUI

struct PostDetailView: View {
    private enum Layout {
        static let tabBarClearance: CGFloat = 68
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    @Environment(AppLanguage.self) private var appLanguage
    let postID: String
    let post: FirestorePost
    @State private var commentText = ""
    @State private var showDeleteConfirmation = false
    @State private var showReportConfirmation = false
    @State private var reportSent = false
    @State private var isSubmittingComment = false
    @FocusState private var isCommentFocused: Bool

    private var latestPost: FirestorePost {
        communityViewModel.posts.first(where: { $0.id == postID }) ?? post
    }

    private var currentUID: String? {
        if case .signedIn(let uid) = authViewModel.authState { return uid }
        return nil
    }

    private var activePostID: String? {
        postID
    }

    private var canDelete: Bool {
        guard let uid = currentUID else { return false }
        return latestPost.authorUID == uid
    }

    private var canReport: Bool {
        guard let uid = currentUID else { return false }
        return latestPost.authorUID != uid
    }

    private var resolvedAuthorImageURL: String? {
        if let imageURL = latestPost.authorProfileImageURL, !imageURL.isEmpty {
            return imageURL
        }

        if case .signedIn(let uid) = authViewModel.authState, latestPost.authorUID == uid {
            return userViewModel.currentUser?.profileImageURL
        }

        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        UserAvatarView(
                            imageURL: resolvedAuthorImageURL,
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
                        AnimatedLikeButton(isLiked: latestPost.isLiked, count: latestPost.likes) {
                            guard case .signedIn(let uid) = authViewModel.authState, let postID = latestPost.id else { return }
                            Task {
                                await communityViewModel.toggleLike(postID: postID, uid: uid)
                            }
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 16, weight: .light))
                            Text("\(communityViewModel.liveComments.count)")
                                .font(MomentsStyle.systemRegular(13))
                        }
                        .foregroundColor(MomentsStyle.secondaryText)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)

                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                Text(Strings.postDetailComments)
                    .font(.system(size: 10, weight: .light))
                    .tracking(3)
                    .foregroundColor(MomentsStyle.secondaryText)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 14)

                VStack(spacing: 0) {
                    ForEach(communityViewModel.liveComments) { comment in
                        CommentRow(
                            comment: comment,
                            postID: latestPost.id ?? "",
                            currentUID: { if case .signedIn(let uid) = authViewModel.authState { return uid }; return nil }()
                        )

                        if comment.id != communityViewModel.liveComments.last?.id {
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(MomentsStyle.border)
                                .padding(.leading, 82)
                                .padding(.trailing, 24)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
        }
        .background(MomentsStyle.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            commentComposer
        }
        .scrollDismissesKeyboard(.interactively)
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
            if canReport {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showReportConfirmation = true
                    } label: {
                        Image(systemName: "flag")
                            .foregroundColor(MomentsStyle.primaryText)
                    }
                }
            }
        }
        .onAppear {
            guard let postID = activePostID else { return }
            communityViewModel.startCommentsListener(postID: postID)
            if case .signedIn(let uid) = authViewModel.authState,
               userViewModel.currentUser == nil,
               !userViewModel.isLoading {
                Task {
                    await userViewModel.fetchCurrentUser(uid: uid)
                }
            }
        }
        .onDisappear {
            communityViewModel.stopCommentsListener()
        }
        .alert(Strings.communityDeletePost, isPresented: $showDeleteConfirmation) {
            Button(Strings.communityCancel, role: .cancel) { }
            Button(Strings.communityDelete, role: .destructive) {
                guard let postID = latestPost.id else { return }
                Haptics.warning()
                Task {
                    await communityViewModel.deletePost(postID: postID)
                    if communityViewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            }
        } message: {
            Text(Strings.communityDeletePostConfirmation)
        }
        .confirmationDialog(Strings.communityReportPostTitle, isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button(Strings.communityReportSpam, role: .destructive) { sendReport(reason: Strings.communityReportSpam) }
            Button(Strings.communityReportHarassment, role: .destructive) { sendReport(reason: Strings.communityReportHarassment) }
            Button(Strings.communityReportInappropriate, role: .destructive) { sendReport(reason: Strings.communityReportInappropriate) }
            Button(Strings.communityReportOther, role: .destructive) { sendReport(reason: Strings.communityReportOther) }
            Button(Strings.communityCancel, role: .cancel) { }
        }
        .alert(Strings.communityReportPost, isPresented: $reportSent) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(Strings.communityReportPostConfirmation)
        }
    }

    private var trimmedCommentText: String {
        commentText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSendComment: Bool {
        !trimmedCommentText.isEmpty && !isSubmittingComment
    }

    private var commentComposer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(MomentsStyle.border)

            if let errorMessage = communityViewModel.errorMessage {
                Text(errorMessage)
                    .font(MomentsStyle.systemLight(12))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            }

            HStack(spacing: 12) {
                UserAvatarView(
                    imageURL: userViewModel.currentUser?.profileImageURL,
                    fallbackText: userViewModel.currentUser?.firstInitial ?? "M",
                    size: 34
                )

                HStack(spacing: 10) {
                    TextField(Strings.postDetailAddComment, text: $commentText)
                        .font(MomentsStyle.systemLight(14))
                        .focused($isCommentFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            Task {
                                await submitComment()
                            }
                        }

                    Button {
                        Task {
                            await submitComment()
                        }
                    } label: {
                        Group {
                            if isSubmittingComment {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 26))
                            }
                        }
                        .foregroundColor(canSendComment ? MomentsStyle.primaryText : MomentsStyle.inactive)
                    }
                    .disabled(!canSendComment)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(MomentsStyle.background)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(MomentsStyle.border, lineWidth: 0.5)
                )
                .contentShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, Layout.tabBarClearance)
            .background(MomentsStyle.cardBackground)
        }
    }

    private func sendReport(reason: String) {
        guard let postID = latestPost.id, let uid = currentUID else { return }
        Task {
            await communityViewModel.reportPost(postID: postID, reporterUID: uid, reason: reason)
            reportSent = true
        }
    }

    private func submitComment() async {
        guard !isSubmittingComment else { return }

        guard case .signedIn(let uid) = authViewModel.authState else {
            communityViewModel.errorMessage = "You need to be signed in to comment."
            return
        }

        guard let postID = activePostID else {
            communityViewModel.errorMessage = "This post is unavailable right now. Try reopening it."
            return
        }

        let body = trimmedCommentText
        guard !body.isEmpty else { return }

        isSubmittingComment = true
        defer { isSubmittingComment = false }

        if userViewModel.currentUser == nil {
            await userViewModel.fetchCurrentUser(uid: uid)
        }

        let username = resolvedCommentAuthorUsername(for: uid)

        await communityViewModel.addComment(
            postID: postID,
            authorUID: uid,
            authorUsername: username,
            authorProfileImageURL: userViewModel.currentUser?.profileImageURL,
            body: body
        )

        guard communityViewModel.errorMessage == nil else { return }
        Haptics.success()
        commentText = ""
        isCommentFocused = false
    }

    private func resolvedCommentAuthorUsername(for uid: String) -> String {
        if let username = userViewModel.currentUser?.username.trimmingCharacters(in: .whitespacesAndNewlines),
           !username.isEmpty {
            return String(username.prefix(30))
        }

        return "member-\(uid.prefix(6))"
    }
}

struct CommentRow: View {
    @Environment(CommunityViewModel.self) private var communityViewModel
    @Environment(UserViewModel.self) private var userViewModel
    let comment: FirestoreComment
    let postID: String
    let currentUID: String?
    @State private var reportSent = false

    private var canDelete: Bool {
        guard let uid = currentUID, let commentID = comment.id else { return false }
        return comment.authorUID == uid && !communityViewModel.deletingCommentIDs.contains(commentID)
    }

    private var canReport: Bool {
        guard let uid = currentUID else { return false }
        return comment.authorUID != uid
    }

    private var resolvedAuthorImageURL: String? {
        if let imageURL = comment.authorProfileImageURL, !imageURL.isEmpty {
            return imageURL
        }

        if let uid = currentUID, uid == comment.authorUID {
            return userViewModel.currentUser?.profileImageURL
        }

        return nil
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatarView(
                imageURL: resolvedAuthorImageURL,
                fallbackText: String(comment.authorUsername.prefix(1)).uppercased(),
                size: 30
            )

            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 6) {
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
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(MomentsStyle.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MomentsStyle.border, lineWidth: 0.5)
                )

                Button {
                    guard let uid = currentUID, let commentID = comment.id else { return }
                    Task {
                        await communityViewModel.toggleCommentLike(postID: postID, commentID: commentID, uid: uid)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 10, weight: .light))
                        Text("\(comment.likes)")
                            .font(MomentsStyle.systemLight(10))
                    }
                    .foregroundColor(comment.isLiked ? .red.opacity(0.8) : MomentsStyle.inactive)
                    .padding(.leading, 10)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            if let commentID = comment.id, communityViewModel.deletingCommentIDs.contains(commentID) {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .contextMenu {
            if canDelete {
                Button(role: .destructive) {
                    guard let commentID = comment.id else { return }
                    Haptics.warning()
                    Task {
                        await communityViewModel.deleteComment(postID: postID, commentID: commentID)
                    }
                } label: {
                    Label(Strings.postDetailDeleteComment, systemImage: "trash")
                }
            }
            if canReport, let commentID = comment.id {
                Button {
                    guard let uid = currentUID else { return }
                    Task {
                        await communityViewModel.reportComment(
                            postID: postID,
                            commentID: commentID,
                            reporterUID: uid,
                            reason: Strings.communityReportOther
                        )
                        Haptics.success()
                        reportSent = true
                    }
                } label: {
                    Label(Strings.communityReportComment, systemImage: "flag")
                }
            }
        }
        .alert(Strings.communityReportComment, isPresented: $reportSent) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(Strings.communityReportCommentConfirmation)
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            postID: "preview-post",
            post: FirestorePost(
                id: "preview-post",
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
        .environment(AppLanguage.shared)
    }
}
