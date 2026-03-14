import SwiftUI

struct CreateAccountView: View {
    @State private var step = 0
    var onComplete: () -> Void = {}

    // Step 1: Account
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    // Step 2: Profile
    @State private var username = ""
    @State private var bio = ""

    // Step 3: Interests
    @State private var selectedInterests: Set<String> = []

    private let allInterests = [
        "Wine Tasting", "Board Games", "Jazz", "Italian Food",
        "Cocktails", "Art", "Vinyl", "Late Nights",
        "Cooking", "Travel", "Photography", "Fitness",
        "Film", "Coffee", "Reading", "Design"
    ]

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
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if step < 2 {
                            step += 1
                        } else {
                            onComplete()
                        }
                    }
                } label: {
                    Text(step < 2 ? "CONTINUE" : "GET STARTED")
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
                Button { } label: {
                    Circle()
                        .fill(Color(red: 0.96, green: 0.955, blue: 0.945))
                        .frame(width: 100, height: 100)
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
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
