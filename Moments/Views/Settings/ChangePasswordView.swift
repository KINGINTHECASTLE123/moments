import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showSuccess = false

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    private var canSubmit: Bool {
        !currentPassword.isEmpty && passwordsMatch && newPassword.count >= 6
    }

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

                            Text("Change password")
                                .font(MomentsStyle.georgiaItalic(34))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text("Choose a strong password you haven't used before.")
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)

                        VStack(spacing: 24) {
                            AuthSecureField(
                                label: "CURRENT PASSWORD",
                                placeholder: "Enter current password",
                                text: $currentPassword
                            )

                            AuthSecureField(
                                label: "NEW PASSWORD",
                                placeholder: "At least 6 characters",
                                text: $newPassword
                            )

                            AuthSecureField(
                                label: "CONFIRM PASSWORD",
                                placeholder: "Re-enter new password",
                                text: $confirmPassword
                            )
                        }

                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords don't match.")
                                .font(MomentsStyle.systemLight(12))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.top, 16)
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

                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)

                            Text("Password updated")
                                .font(MomentsStyle.georgiaItalic(28))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text("Your password has been changed successfully.")
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .multilineTextAlignment(.center)
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
                            await authViewModel.updatePassword(to: newPassword)
                            if authViewModel.errorMessage == nil {
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
                        Text(showSuccess ? "DONE" : "UPDATE PASSWORD")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                }
                .disabled(authViewModel.isLoading || (!showSuccess && !canSubmit))
                .opacity((!showSuccess && !canSubmit) ? 0.6 : 1)
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
                Text("Password")
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
        ChangePasswordView()
            .environment(AuthViewModel())
            .environment(UserViewModel())
    }
}
