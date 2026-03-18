import SwiftUI

struct SignInView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back")
                            .font(MomentsStyle.georgiaItalic(34))
                            .foregroundColor(MomentsStyle.primaryText)

                        Text("Sign in to your account")
                            .font(MomentsStyle.systemLight(14))
                            .foregroundColor(MomentsStyle.secondaryText)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)

                    // Form fields
                    VStack(spacing: 24) {
                        AuthTextField(
                            label: "EMAIL",
                            placeholder: "your@email.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        .focused($focusedField, equals: .email)

                        AuthSecureField(
                            label: "PASSWORD",
                            placeholder: "Enter your password",
                            text: $password
                        )
                        .focused($focusedField, equals: .password)
                    }

                    // Error message
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(MomentsStyle.systemLight(12))
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.top, 16)
                    }

                    // Forgot password
                    HStack {
                        Spacer()
                        NavigationLink {
                            ForgotPasswordView()
                        } label: {
                            Text("FORGOT PASSWORD?")
                                .font(.system(size: 9, weight: .light))
                                .tracking(2)
                                .foregroundColor(MomentsStyle.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
            }

            // Bottom button
            VStack(spacing: 0) {
                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)

                Button {
                    Task {
                        await authViewModel.signIn(email: email, password: password)
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
                        Text("SIGN IN")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                }
                .buttonStyle(MomentsPrimaryButtonStyle())
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
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
