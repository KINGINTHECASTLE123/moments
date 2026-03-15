import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !showConfirmation {
                        // Request form
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reset password")
                                .font(MomentsStyle.georgiaItalic(34))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text("Enter your email and we'll send you a link to reset your password.")
                                .font(MomentsStyle.systemLight(14))
                                .foregroundColor(MomentsStyle.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)

                        AuthTextField(
                            label: "EMAIL",
                            placeholder: "your@email.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                    } else {
                        // Confirmation
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 40)

                            Image(systemName: "envelope.open")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(MomentsStyle.inactive)

                            Text("Check your email")
                                .font(MomentsStyle.georgiaItalic(28))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text("We've sent a password reset link to\n\(email)")
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
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showConfirmation = true
                        }
                    } label: {
                        Text("SEND RESET LINK")
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
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("BACK TO SIGN IN")
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
