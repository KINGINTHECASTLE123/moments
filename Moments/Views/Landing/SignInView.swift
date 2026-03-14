import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    var onSignIn: () -> Void = {}

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

                Button(action: onSignIn) {
                    Text("SIGN IN")
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
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
