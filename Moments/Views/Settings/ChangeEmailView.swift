import SwiftUI

struct ChangeEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @State private var newEmail = ""
    @State private var currentPassword = ""
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !showSuccess {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ACCOUNT")
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundColor(MomentsStyle.secondaryText)

                            Text("Change email")
                                .font(MomentsStyle.georgiaItalic(34))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text("A verification link will be sent to your new email address.")
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)

                        VStack(spacing: 24) {
                            AuthTextField(
                                label: "NEW EMAIL",
                                placeholder: "your@email.com",
                                text: $newEmail,
                                keyboardType: .emailAddress
                            )

                            AuthSecureField(
                                label: "CURRENT PASSWORD",
                                placeholder: "Confirm your password",
                                text: $currentPassword
                            )
                        }

                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .font(MomentsStyle.systemLight(12))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.top, 16)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 40)

                            Image(systemName: "envelope.open")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)

                            Text("Check your email")
                                .font(MomentsStyle.georgiaItalic(28))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text("We've sent a verification link to\n\(newEmail)")
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Bottom button
            VStack(spacing: 0) {
                Rectangle().fill(MomentsStyle.border).frame(height: 0.5)

                Button {
                    if showSuccess {
                        dismiss()
                    } else {
                        Task {
                            let reauthed = await authViewModel.reauthenticate(
                                email: userViewModel.currentUser?.email ?? "",
                                password: currentPassword
                            )
                            guard reauthed else { return }
                            await authViewModel.updateEmail(to: newEmail)
                            if authViewModel.errorMessage == nil {
                                if case .signedIn(let uid) = authViewModel.authState {
                                    await userViewModel.updateEmail(uid: uid, newEmail: newEmail)
                                }
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSuccess = true
                                }
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
                        Text(showSuccess ? "DONE" : "UPDATE EMAIL")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                }
                .disabled(authViewModel.isLoading || (!showSuccess && (newEmail.isEmpty || currentPassword.isEmpty)))
                .opacity((!showSuccess && (newEmail.isEmpty || currentPassword.isEmpty)) ? 0.6 : 1)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(MomentsStyle.background)
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Email")
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .onAppear {
            authViewModel.errorMessage = nil
        }
    }
}

#Preview {
    NavigationStack {
        ChangeEmailView()
            .environment(AuthViewModel())
            .environment(UserViewModel())
    }
}
