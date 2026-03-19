import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AppLanguage.self) private var appLanguage
    @State private var email = ""
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !showConfirmation {
                        // Request form
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Strings.forgotPasswordTitle)
                                .font(MomentsStyle.georgiaItalic(34))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text(Strings.forgotPasswordSubtitle)
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)

                        AuthTextField(
                            label: Strings.forgotPasswordEmailLabel,
                            placeholder: Strings.forgotPasswordEmailPlaceholder,
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .font(MomentsStyle.systemLight(12))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.top, 16)
                        }
                    } else {
                        // Confirmation
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 40)

                            Image(systemName: "envelope.open")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)

                            Text(Strings.forgotPasswordCheckEmail)
                                .font(MomentsStyle.georgiaItalic(28))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text(Strings.verificationSentTo(email))
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
                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)

                if !showConfirmation {
                    Button {
                        Task {
                            let success = await authViewModel.sendPasswordReset(email: email)
                            if success {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showConfirmation = true
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
                            Text(Strings.forgotPasswordSendButton)
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundColor(MomentsStyle.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(MomentsStyle.primaryText)
                                .clipShape(Capsule())
                        }
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text(Strings.forgotPasswordBackToSignIn)
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .background(MomentsStyle.background)
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
