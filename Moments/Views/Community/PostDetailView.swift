import SwiftUI

struct PostDetailView: View {
    var store: CommunityStore
    let postID: UUID
    @State private var commentText = ""
    @FocusState private var isCommentFocused: Bool

    private var post: Post? {
        store.posts.first(where: { $0.id == postID })
    }

    var body: some View {
        if let post {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Post content
                        VStack(alignment: .leading, spacing: 14) {
                            // User row
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(post.username.prefix(1)).uppercased())
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(MomentsStyle.secondaryText)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(post.username)
                                        .font(MomentsStyle.systemMedium(15))
                                        .foregroundColor(MomentsStyle.primaryText)

                                    Text(post.timestamp)
                                        .font(MomentsStyle.systemLight(12))
                                        .foregroundColor(MomentsStyle.secondaryText)
                                }

                                Spacer()

                                if let tag = post.tag {
                                    PillTag(label: tag)
                                }
                            }

                            // Body
                            Text(post.body)
                                .font(MomentsStyle.systemLight(15))
                                .foregroundColor(MomentsStyle.primaryText)
                                .lineSpacing(5)

                            // Photo
                            if let imageName = post.imageName {
                                PostImageView(name: imageName)
                                    .frame(height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            // Like and comment counts
                            HStack(spacing: 24) {
                                Button {
                                    store.toggleLike(for: postID)
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                            .font(.system(size: 16, weight: .light))
                                        Text("\(post.likes)")
                                            .font(MomentsStyle.systemRegular(13))
                                    }
                                    .foregroundColor(post.isLiked ? MomentsStyle.primaryText : MomentsStyle.secondaryText)
                                }
                                .buttonStyle(.plain)

                                HStack(spacing: 6) {
                                    Image(systemName: "bubble.right")
                                        .font(.system(size: 16, weight: .light))
                                    Text("\(post.comments.count)")
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

                        // Divider
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(MomentsStyle.border)

                        // Comments header
                        Text("COMMENTS")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.secondaryText)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 14)

                        // Comments list
                        VStack(spacing: 0) {
                            ForEach(post.comments) { comment in
                                CommentRow(comment: comment)

                                if comment.id != post.comments.last?.id {
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

                // Comment input bar
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(MomentsStyle.border)

                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("J")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(MomentsStyle.secondaryText)
                            )

                        TextField("Add a comment...", text: $commentText)
                            .font(MomentsStyle.systemLight(14))
                            .focused($isCommentFocused)

                        if !commentText.isEmpty {
                            Button {
                                store.addComment(to: postID, username: "jacobkbh", body: commentText)
                                commentText = ""
                                isCommentFocused = false
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(MomentsStyle.primaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                }
            }
            .background(MomentsStyle.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(post.username)
                        .font(MomentsStyle.georgiaItalic(18))
                        .foregroundColor(MomentsStyle.primaryText)
                }
            }
        }
    }
}

// MARK: - Comment Row

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                .frame(width: 30, height: 30)
                .overlay(
                    Text(String(comment.username.prefix(1)).uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(MomentsStyle.secondaryText)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.username)
                        .font(MomentsStyle.systemMedium(13))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(comment.timestamp)
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

private struct PostDetailPreview: View {
    @State private var store = CommunityStore()

    var body: some View {
        NavigationStack {
            PostDetailView(store: store, postID: store.posts.first!.id)
        }
    }
}

#Preview {
    PostDetailPreview()
}
