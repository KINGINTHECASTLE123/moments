import SwiftUI

// MARK: - Models

struct Comment: Identifiable {
    let id = UUID()
    let username: String
    let body: String
    let timestamp: String
    var likes: Int
}

struct Post: Identifiable {
    let id = UUID()
    let username: String
    let timestamp: String
    let body: String
    var likes: Int
    let replies: Int
    let imageName: String?
    let tag: String?
    var comments: [Comment]
    var isLiked: Bool = false
}

@Observable
class CommunityStore {
    var posts: [Post] = CommunityStore.samplePosts()

    static func samplePosts() -> [Post] {
        [
            Post(
                username: "emilnordic",
                timestamp: "2h ago",
                body: "Hosted a wine & cheese night last Friday. The Late Night Cocktails playlist was perfect — everyone stayed until 2am.",
                likes: 14,
                replies: 5,
                imageName: "CommunityWine",
                tag: "Food",
                comments: [
                    Comment(username: "sofiekhv", body: "Sounds amazing! What cheeses did you go with?", timestamp: "1h ago", likes: 3),
                    Comment(username: "marcuskbh", body: "That playlist is unbeatable for late nights", timestamp: "1h ago", likes: 5),
                    Comment(username: "idanørrebro", body: "Next time I'm there 🙋", timestamp: "45m ago", likes: 1),
                    Comment(username: "linekbh", body: "We need the full menu breakdown", timestamp: "30m ago", likes: 2),
                    Comment(username: "jacobkbh", body: "Incredible night, thanks for hosting", timestamp: "20m ago", likes: 4),
                ]
            ),
            Post(
                username: "sofiekhv",
                timestamp: "5h ago",
                body: "Anyone up for a board game night in Vesterbro this weekend? Thinking 6-8 people, I'll handle snacks.",
                likes: 22,
                replies: 8,
                imageName: nil,
                tag: "Games",
                comments: [
                    Comment(username: "emilnordic", body: "I'm in. Saturday works best for me", timestamp: "4h ago", likes: 2),
                    Comment(username: "marcuskbh", body: "Count me in! I'll bring Catan", timestamp: "4h ago", likes: 6),
                    Comment(username: "linekbh", body: "Yes! Can we do Late Night Conversations too?", timestamp: "3h ago", likes: 3),
                    Comment(username: "idanørrebro", body: "Saturday or Sunday both work", timestamp: "3h ago", likes: 1),
                    Comment(username: "jacobkbh", body: "I'll bring drinks", timestamp: "2h ago", likes: 4),
                    Comment(username: "annakbh", body: "Can I bring a friend?", timestamp: "2h ago", likes: 1),
                    Comment(username: "sofiekhv", body: "Of course! The more the merrier", timestamp: "1h ago", likes: 3),
                    Comment(username: "emilnordic", body: "Let's lock in Saturday 7pm then", timestamp: "1h ago", likes: 5),
                ]
            ),
            Post(
                username: "marcuskbh",
                timestamp: "1d ago",
                body: "Tried the Burrata & Heirloom Tomato recipe from the app — paired it with a homemade Aperol Spritz. Absolutely worth it.",
                likes: 31,
                replies: 5,
                imageName: "CommunityBurrata",
                tag: "Food",
                comments: [
                    Comment(username: "sofiekhv", body: "That pairing is perfection", timestamp: "23h ago", likes: 4),
                    Comment(username: "emilnordic", body: "Did you use the buffalo mozzarella?", timestamp: "22h ago", likes: 2),
                    Comment(username: "marcuskbh", body: "Yes, fresh from Torvehallerne!", timestamp: "22h ago", likes: 6),
                    Comment(username: "linekbh", body: "Adding this to my weekend plans", timestamp: "20h ago", likes: 1),
                    Comment(username: "idanørrebro", body: "The Aperol Spritz ratio in the app is spot on", timestamp: "18h ago", likes: 3),
                ]
            ),
            Post(
                username: "idanørrebro",
                timestamp: "2d ago",
                body: "Late Night Conversations game hit different at 3am. We talked for hours. This app gets it.",
                likes: 47,
                replies: 12,
                imageName: nil,
                tag: "Games",
                comments: [
                    Comment(username: "emilnordic", body: "Those deep questions really open people up", timestamp: "2d ago", likes: 8),
                    Comment(username: "sofiekhv", body: "3am conversations are always the best ones", timestamp: "2d ago", likes: 6),
                    Comment(username: "marcuskbh", body: "Which question pack did you use?", timestamp: "2d ago", likes: 3),
                    Comment(username: "idanørrebro", body: "The 'Deep & Playful' set — highly recommend", timestamp: "2d ago", likes: 9),
                    Comment(username: "linekbh", body: "We need a round 2", timestamp: "1d ago", likes: 4),
                    Comment(username: "annakbh", body: "This is what makes moments special", timestamp: "1d ago", likes: 7),
                ]
            ),
            Post(
                username: "linekbh",
                timestamp: "3d ago",
                body: "Sunday brunch with Easy Sunday playlist on repeat. Fresh pastries, good coffee, even better company.",
                likes: 38,
                replies: 6,
                imageName: "CommunityBrunch",
                tag: "Music",
                comments: [
                    Comment(username: "sofiekhv", body: "Easy Sunday is my go-to playlist", timestamp: "3d ago", likes: 5),
                    Comment(username: "emilnordic", body: "Where are the pastries from?", timestamp: "3d ago", likes: 2),
                    Comment(username: "linekbh", body: "Hart Bageri — always worth the trip", timestamp: "3d ago", likes: 8),
                    Comment(username: "marcuskbh", body: "That place is incredible", timestamp: "2d ago", likes: 3),
                    Comment(username: "jacobkbh", body: "Need this energy every weekend", timestamp: "2d ago", likes: 4),
                    Comment(username: "idanørrebro", body: "Perfect Sunday vibes", timestamp: "2d ago", likes: 2),
                ]
            ),
        ]
    }

    func toggleLike(for postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
    }

    func addComment(to postID: UUID, username: String, body: String) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        let comment = Comment(username: username, body: body, timestamp: "Just now", likes: 0)
        posts[index].comments.append(comment)
        posts[index].likes = posts[index].likes // triggers update
    }

    func addPost(username: String, body: String, imageName: String?, tag: String?) {
        let post = Post(
            username: username,
            timestamp: "Just now",
            body: body,
            likes: 0,
            replies: 0,
            imageName: imageName,
            tag: tag,
            comments: []
        )
        posts.insert(post, at: 0)
    }
}

// MARK: - Community Feed

struct CommunityView: View {
    @State private var store = CommunityStore()
    @State private var showCreatePost = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
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

                // Post feed
                VStack(spacing: 14) {
                    ForEach(store.posts) { post in
                        NavigationLink(value: post.id) {
                            PostCard(post: post, onLike: {
                                store.toggleLike(for: post.id)
                            })
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationDestination(for: UUID.self) { postID in
            if let post = store.posts.first(where: { $0.id == postID }) {
                PostDetailView(store: store, postID: post.id)
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView(store: store)
        }
    }
}

// MARK: - Post Card (Feed)

struct PostCard: View {
    let post: Post
    var onLike: () -> Void = {}

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 12) {
                // User row
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                        .frame(width: 34, height: 34)
                        .overlay(
                            Text(String(post.username.prefix(1)).uppercased())
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MomentsStyle.secondaryText)
                        )

                    VStack(alignment: .leading, spacing: 1) {
                        Text(post.username)
                            .font(MomentsStyle.systemMedium(14))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text(post.timestamp)
                            .font(MomentsStyle.systemLight(11))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }

                    Spacer()

                    if let tag = post.tag {
                        PillTag(label: tag)
                    }
                }

                // Body
                Text(post.body)
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.primaryText)
                    .lineSpacing(4)

                // Photo
                if let imageName = post.imageName {
                    PostImageView(name: imageName)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Engagement row
                HStack(spacing: 20) {
                    Button(action: onLike) {
                        HStack(spacing: 5) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 13, weight: .light))
                            Text("\(post.likes)")
                                .font(MomentsStyle.systemLight(12))
                        }
                        .foregroundColor(post.isLiked ? MomentsStyle.primaryText : MomentsStyle.secondaryText)
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 5) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 13, weight: .light))
                        Text("\(post.comments.count)")
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
    }
}

// MARK: - Post Image View (generic placeholder images)

struct PostImageView: View {
    let name: String

    private var placeholderConfig: (icon: String, bgColor: Color) {
        switch name {
        case "community_1":
            return ("wineglass.fill", Color(red: 0.28, green: 0.22, blue: 0.18))
        case "community_2":
            return ("leaf.fill", Color(red: 0.22, green: 0.28, blue: 0.22))
        default:
            return ("photo", Color(red: 0.96, green: 0.955, blue: 0.945))
        }
    }

    private var isAssetImage: Bool {
        UIImage(named: name) != nil
    }

    var body: some View {
        if isAssetImage {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipped()
        } else {
            ZStack {
                placeholderConfig.bgColor

                Image(systemName: placeholderConfig.icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    NavigationStack {
        CommunityView()
    }
}
