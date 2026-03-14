import SwiftUI

struct AuthTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 9, weight: .light))
                .tracking(2)
                .foregroundColor(MomentsStyle.secondaryText)

            TextField(placeholder, text: $text)
                .font(MomentsStyle.systemLight(16))
                .foregroundColor(MomentsStyle.primaryText)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
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

struct AuthSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @State private var showPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 9, weight: .light))
                .tracking(2)
                .foregroundColor(MomentsStyle.secondaryText)

            HStack {
                if showPassword {
                    TextField(placeholder, text: $text)
                        .font(MomentsStyle.systemLight(16))
                        .foregroundColor(MomentsStyle.primaryText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    SecureField(placeholder, text: $text)
                        .font(MomentsStyle.systemLight(16))
                        .foregroundColor(MomentsStyle.primaryText)
                        .textInputAutocapitalization(.never)
                }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(MomentsStyle.inactive)
                }
            }
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

#Preview {
    VStack(spacing: 24) {
        AuthTextField(label: "EMAIL", placeholder: "your@email.com", text: .constant(""))
        AuthSecureField(label: "PASSWORD", placeholder: "Enter password", text: .constant(""))
    }
    .padding(24)
}
