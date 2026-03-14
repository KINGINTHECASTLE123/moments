import SwiftUI
import PhotosUI

struct CreatePostView: View {
    var store: CommunityStore
    @Environment(\.dismiss) private var dismiss
    @State private var bodyText = ""
    @State private var selectedTag: String? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @FocusState private var isBodyFocused: Bool

    private let tags = ["Games", "Food", "Music", "Moment"]

    private var canPost: Bool {
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // User row
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("J")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(MomentsStyle.secondaryText)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("jacobkbh")
                                    .font(MomentsStyle.systemMedium(15))
                                    .foregroundColor(MomentsStyle.primaryText)

                                Text("Posting to Community")
                                    .font(MomentsStyle.systemLight(12))
                                    .foregroundColor(MomentsStyle.secondaryText)
                            }
                        }

                        // Text input
                        TextField("Share a moment...", text: $bodyText, axis: .vertical)
                            .font(MomentsStyle.systemLight(16))
                            .foregroundColor(MomentsStyle.primaryText)
                            .lineLimit(3...12)
                            .focused($isBodyFocused)

                        // Photo preview
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

                        // Tags
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TAG")
                                .font(.system(size: 9, weight: .light))
                                .tracking(2)
                                .foregroundColor(MomentsStyle.secondaryText)

                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Button {
                                        if selectedTag == tag {
                                            selectedTag = nil
                                        } else {
                                            selectedTag = tag
                                        }
                                    } label: {
                                        PillTag(label: tag, filled: selectedTag == tag)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }

                // Bottom toolbar
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(MomentsStyle.border)

                    HStack(spacing: 16) {
                        // Photo picker
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Image(systemName: "photo")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)
                        }

                        Button { } label: {
                            Image(systemName: "camera")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(MomentsStyle.primaryText)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
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
                }

                ToolbarItem(placement: .principal) {
                    Text("New Post")
                        .font(MomentsStyle.georgiaItalic(18))
                        .foregroundColor(MomentsStyle.primaryText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        store.addPost(
                            username: "jacobkbh",
                            body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
                            imageName: photoData != nil ? "user_photo" : nil,
                            tag: selectedTag
                        )
                        dismiss()
                    } label: {
                        Text("POST")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(2)
                            .foregroundColor(canPost ? MomentsStyle.primaryText : MomentsStyle.inactive)
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
    CreatePostView(store: CommunityStore())
}
