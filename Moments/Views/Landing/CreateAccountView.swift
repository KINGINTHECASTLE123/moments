import PhotosUI
import SwiftUI

struct CreateAccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @State private var step = 0

    // Step 1: Account
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    // Step 2: Profile
    @State private var username = ""
    @State private var bio = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?

    // Step 3: Interests
    @State private var selectedInterests: Set<String> = []

    private let allInterests = AppConstants.allInterests

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(index <= step ? MomentsStyle.primaryText : MomentsStyle.border)
                        .frame(height: 2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch step {
                    case 0:
                        accountStep
                    case 1:
                        profileStep
                    case 2:
                        interestsStep
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 24)
            }

            // Bottom button
            VStack(spacing: 0) {
                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)

                Button {
                    if step == 0 {
                        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                              password.count >= 6 else {
                            authViewModel.errorMessage = password.count < 6 && !password.isEmpty
                                ? "Password must be at least 6 characters."
                                : "Please fill in all fields."
                            return
                        }
                        authViewModel.errorMessage = nil
                        withAnimation(.easeInOut(duration: 0.3)) { step += 1 }
                    } else if step == 1 {
                        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            authViewModel.errorMessage = "Please choose a username."
                            return
                        }
                        authViewModel.errorMessage = nil
                        withAnimation(.easeInOut(duration: 0.3)) { step += 1 }
                    } else {
                        Task {
                            if let uid = await authViewModel.createAccount(email: email, password: password) {
                                await userViewModel.createProfile(
                                    uid: uid,
                                    fullName: fullName,
                                    email: email,
                                    username: username,
                                    bio: bio,
                                    interests: Array(selectedInterests),
                                    profileImageData: profileImageData
                                )
                            }
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    } else {
                        Text(step < 2 ? "CONTINUE" : "GET STARTED")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                }
                .disabled(authViewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(MomentsStyle.background)
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
    }

    // MARK: - Step 1: Account Details

    private var accountStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create account")
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text("Let's get you started")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            VStack(spacing: 24) {
                AuthTextField(
                    label: "FULL NAME",
                    placeholder: "Your name",
                    text: $fullName
                )

                AuthTextField(
                    label: "EMAIL",
                    placeholder: "your@email.com",
                    text: $email,
                    keyboardType: .emailAddress
                )

                AuthSecureField(
                    label: "PASSWORD",
                    placeholder: "Choose a password",
                    text: $password
                )
            }
        }
    }

    // MARK: - Step 2: Profile Setup

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your profile")
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text("How others will see you")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            // Avatar placeholder
            HStack {
                Spacer()
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Group {
                        if let profileImageData, let uiImage = UIImage(data: profileImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Circle()
                                .fill(MomentsStyle.surfaceSecondary)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "camera")
                                            .font(.system(size: 22, weight: .light))
                                            .foregroundColor(MomentsStyle.inactive)

                                        Text("ADD PHOTO")
                                            .font(.system(size: 7, weight: .light))
                                            .tracking(2)
                                            .foregroundColor(MomentsStyle.secondaryText)
                                    }
                                )
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.bottom, 32)

            VStack(spacing: 24) {
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
        }
    }

    // MARK: - Step 3: Interests

    private var interestsStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your interests")
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text("Pick at least 3 to personalize your experience")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

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

            if !selectedInterests.isEmpty {
                Text("\(selectedInterests.count) selected")
                    .font(MomentsStyle.systemLight(13))
                    .foregroundColor(MomentsStyle.secondaryText)
                    .padding(.top, 20)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(MomentsStyle.systemLight(12))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.top, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
            .environment(AuthViewModel())
            .environment(UserViewModel())
    }
}
