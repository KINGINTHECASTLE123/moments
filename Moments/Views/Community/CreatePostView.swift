import PhotosUI
import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    @State private var bodyText = ""
    @State private var selectedTag: String?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @FocusState private var isBodyFocused: Bool

    private let tags = ["Games", "Food", "Music", "Moment"]

    private var canPost: Bool {
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !communityViewModel.isCreatingPost
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            UserAvatarView(
                                imageURL: userViewModel.currentUser?.profileImageURL,
                                fallbackText: userViewModel.currentUser?.firstInitial ?? "M",
                                size: 40
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(userViewModel.currentUser?.username ?? "moments")
                                    .font(MomentsStyle.systemMedium(15))
                                    .foregroundColor(MomentsStyle.primaryText)

                                Text("Posting to Community")
                                    .font(MomentsStyle.systemLight(12))
                                    .foregroundColor(MomentsStyle.secondaryText)
                            }
                        }

                        TextField("Share a moment...", text: $bodyText, axis: .vertical)
                            .font(MomentsStyle.systemLight(16))
                            .foregroundColor(MomentsStyle.primaryText)
                            .lineLimit(3...12)
                            .focused($isBodyFocused)

                        if let photoData, let uiImage = UIImage(data: photoData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                Button {
                                    self.photoData = nil
                                    self.selectedPhoto = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                }
                                .padding(8)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("TAG")
                                .font(.system(size: 9, weight: .light))
                                .tracking(2)
                                .foregroundColor(MomentsStyle.secondaryText)

                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Button {
                                        selectedTag = selectedTag == tag ? nil : tag
                                    } label: {
                                        PillTag(label: tag, filled: selectedTag == tag)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if let errorMessage = communityViewModel.errorMessage {
                            Text(errorMessage)
                                .font(MomentsStyle.systemLight(12))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }

                VStack(spacing: 0) {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(MomentsStyle.border)

                    HStack(spacing: 16) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Image(systemName: "photo")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(MomentsStyle.cardBackground)
                }
            }
            .background(MomentsStyle.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(MomentsStyle.systemLight(15))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .disabled(communityViewModel.isCreatingPost)
                }

                ToolbarItem(placement: .principal) {
                    Text("New Post")
                        .font(MomentsStyle.georgiaItalic(18))
                        .foregroundColor(MomentsStyle.primaryText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard
                            case .signedIn(let uid) = authViewModel.authState,
                            let currentUser = userViewModel.currentUser
                        else { return }

                        Task {
                            await communityViewModel.addPost(
                                authorUID: uid,
                                authorUsername: currentUser.username,
                                authorProfileImageURL: currentUser.profileImageURL,
                                body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
                                tag: selectedTag,
                                imageData: photoData
                            )
                            if communityViewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        if communityViewModel.isCreatingPost {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("POST")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(2)
                                .foregroundColor(canPost ? MomentsStyle.primaryText : MomentsStyle.inactive)
                        }
                    }
                    .disabled(!canPost)
                }
            }
            .onAppear { isBodyFocused = true }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
        .environment(AuthViewModel())
        .environment(UserViewModel())
        .environment(CommunityViewModel())
}
