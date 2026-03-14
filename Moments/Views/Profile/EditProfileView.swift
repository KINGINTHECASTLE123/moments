import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = "Jacob Bisgaard"
    @State private var username = "jacobkbh"
    @State private var bio = "Hygge enthusiast. Copenhagen nights.\nGood food, better company."
    @State private var selectedInterests: Set<String> = ["Wine Tasting", "Board Games", "Jazz", "Italian Food", "Cocktails", "Art", "Vinyl", "Late Nights"]

    private let allInterests = [
        "Wine Tasting", "Board Games", "Jazz", "Italian Food",
        "Cocktails", "Art", "Vinyl", "Late Nights",
        "Cooking", "Travel", "Photography", "Fitness",
        "Film", "Coffee", "Reading", "Design"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Avatar
                    HStack {
                        Spacer()
                        Button { } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text("JB")
                                            .font(.system(size: 28, weight: .medium))
                                            .foregroundColor(MomentsStyle.secondaryText)
                                    )

                                Circle()
                                    .fill(MomentsStyle.primaryText)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "camera")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 36, y: 36)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)

                    // Form fields
                    VStack(spacing: 24) {
                        AuthTextField(
                            label: "FULL NAME",
                            placeholder: "Your name",
                            text: $fullName
                        )

                        AuthTextField(
                            label: "USERNAME",
                            placeholder: "@username",
                            text: $username
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text("BIO")
                                .font(.system(size: 9, weight: .light))
                                .tracking(2)
                                .foregroundColor(MomentsStyle.secondaryText)

                            TextField("Tell us about yourself...", text: $bio, axis: .vertical)
                                .font(MomentsStyle.systemLight(16))
                                .foregroundColor(MomentsStyle.primaryText)
                                .lineLimit(3...5)
                                .padding(.bottom, 10)
                                .overlay(
                                    Rectangle()
                                        .fill(MomentsStyle.border)
                                        .frame(height: 0.5),
                                    alignment: .bottom
                                )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Interests
                    VStack(alignment: .leading, spacing: 14) {
                        Rectangle()
                            .fill(MomentsStyle.border)
                            .frame(height: 0.5)
                            .padding(.top, 28)

                        Text("INTERESTS")
                            .font(.system(size: 9, weight: .light))
                            .tracking(2)
                            .foregroundColor(MomentsStyle.secondaryText)
                            .padding(.top, 8)

                        FlowLayout(spacing: 10) {
                            ForEach(allInterests, id: \.self) { interest in
                                Button {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                } label: {
                                    PillTag(
                                        label: interest,
                                        filled: selectedInterests.contains(interest)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }

            // Save button
            VStack(spacing: 0) {
                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)

                Button {
                    dismiss()
                } label: {
                    Text("SAVE CHANGES")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MomentsStyle.primaryText)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(MomentsStyle.background)
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Profile")
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Text("Cancel")
                        .font(MomentsStyle.systemLight(15))
                        .foregroundColor(MomentsStyle.secondaryText)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
}
