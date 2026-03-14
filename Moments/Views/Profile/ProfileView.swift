import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header area
                VStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text("JB")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(MomentsStyle.secondaryText)
                        )

                    VStack(spacing: 4) {
                        Text("Jacob Bisgaard")
                            .font(MomentsStyle.georgiaItalic(26))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text("@jacobkbh")
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }

                    Text("Hygge enthusiast. Copenhagen nights.\nGood food, better company.")
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)

                    // Edit profile button
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        Text("EDIT PROFILE")
                            .font(.system(size: 9, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.primaryText)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .overlay(
                                Capsule()
                                    .stroke(MomentsStyle.border, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 28)

                // Stats row
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                HStack(spacing: 0) {
                    ProfileStat(value: "12", label: "Moments")
                    ProfileStat(value: "48", label: "Friends")
                    ProfileStat(value: "156", label: "Likes")
                }
                .padding(.vertical, 20)

                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                // Interests section
                VStack(alignment: .leading, spacing: 14) {
                    Text("INTERESTS")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)

                    FlowLayout(spacing: 8) {
                        ForEach(["Wine Tasting", "Board Games", "Jazz", "Italian Food", "Cocktails", "Art", "Vinyl", "Late Nights"], id: \.self) { interest in
                            PillTag(label: interest)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                // Favorites section
                VStack(alignment: .leading, spacing: 14) {
                    Text("FAVORITES")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)

                    VStack(spacing: 12) {
                        ProfileFavoriteRow(icon: "fork.knife", title: "Negroni & Burrata", subtitle: "Most made pairing")
                        ProfileFavoriteRow(icon: "dice", title: "Late Night Conversations", subtitle: "Most played game")
                        ProfileFavoriteRow(icon: "music.note", title: "Dinner Party Grooves", subtitle: "Top playlist")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(MomentsStyle.border)

                // Recent moments
                VStack(alignment: .leading, spacing: 14) {
                    Text("RECENT MOMENTS")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)

                    VStack(spacing: 12) {
                        MomentCard(
                            title: "Wine & Game Night",
                            date: "Last Friday",
                            attendees: 6,
                            description: "Negronis, charades, and Late Night Conversations until 3am."
                        )

                        MomentCard(
                            title: "Sunday Brunch",
                            date: "2 weeks ago",
                            attendees: 4,
                            description: "Homemade pastries with Easy Sunday playlist on vinyl."
                        )

                        MomentCard(
                            title: "Cocktail Masterclass",
                            date: "Last month",
                            attendees: 8,
                            description: "Learned to make the perfect Espresso Martini with friends."
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // Member since
                VStack(spacing: 6) {
                    Rectangle()
                        .frame(width: 28, height: 0.5)
                        .foregroundColor(MomentsStyle.border)

                    Text("Member since 2025")
                        .font(MomentsStyle.georgiaItalic(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .padding(.top, 8)

                    Text("Copenhagen")
                        .font(.system(size: 10, weight: .light))
                        .tracking(2)
                        .foregroundColor(MomentsStyle.inactive)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                Spacer(minLength: 40)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }
}

// MARK: - Profile Stat

struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(MomentsStyle.georgiaItalic(22))
                .foregroundColor(MomentsStyle.primaryText)

            Text(label.uppercased())
                .font(.system(size: 9, weight: .light))
                .tracking(2)
                .foregroundColor(MomentsStyle.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Favorite Row

struct ProfileFavoriteRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HairlineCard {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(MomentsStyle.primaryText)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(MomentsStyle.systemMedium(14))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(subtitle)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Moment Card

struct MomentCard: View {
    let title: String
    let date: String
    let attendees: Int
    let description: String

    var body: some View {
        HairlineCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(MomentsStyle.georgiaItalic(16))
                        .foregroundColor(MomentsStyle.primaryText)

                    Spacer()

                    Text(date)
                        .font(MomentsStyle.systemLight(11))
                        .foregroundColor(MomentsStyle.secondaryText)
                }

                Text(description)
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .lineSpacing(3)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.system(size: 11, weight: .light))
                        Text("\(attendees) people")
                            .font(MomentsStyle.systemLight(11))
                    }
                    .foregroundColor(MomentsStyle.secondaryText)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Flow Layout for tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return (positions, CGSize(width: maxX, height: currentY + lineHeight))
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
