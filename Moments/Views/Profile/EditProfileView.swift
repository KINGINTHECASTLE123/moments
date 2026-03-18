import PhotosUI
import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @State private var fullName = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var selectedInterests: Set<String> = []
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?

    private let allInterests = AppConstants.allInterests

    private var currentProfile: UserProfile? {
        userViewModel.currentUser
    }

    private var isSaveDisabled: Bool {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        username.trimmingCharacters(in: .whitespacesAndNewlines)
            .wholeMatch(of: AppConstants.usernamePattern) == nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Avatar
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                ProfileAvatarView(
                                    imageURL: currentProfile?.profileImageURL,
                                    imageData: profileImageData,
                                    initials: currentProfile?.initials ?? "M",
                                    size: 100
                                )

                                Circle()
                                    .fill(MomentsStyle.primaryText)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "camera")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(MomentsStyle.background)
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
                                    Haptics.select()
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
                    guard case .signedIn(let uid) = authViewModel.authState else { return }
                    Task {
                        await userViewModel.updateProfile(
                            uid: uid,
                            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
                            interests: Array(selectedInterests).sorted(),
                            profileImageData: profileImageData
                        )
                        if userViewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                } label: {
                    Text("SAVE CHANGES")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MomentsStyle.primaryText)
                        .clipShape(Capsule())
                }
                .buttonStyle(MomentsPrimaryButtonStyle())
                .disabled(isSaveDisabled)
                .opacity(isSaveDisabled ? 0.6 : 1)
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
        .task {
            guard let profile = currentProfile else { return }
            fullName = profile.fullName
            username = profile.username
            bio = profile.bio
            selectedInterests = Set(profile.interests)
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environment(AuthViewModel())
            .environment(UserViewModel())
    }
}
