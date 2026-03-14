import SwiftUI

struct LandingView: View {
    @State private var showContent = false
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack {
            // Full-bleed background photo
            Image("LandingPhoto")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Dark overlay for legibility
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Wordmark
                Text("moments")
                    .font(MomentsStyle.georgiaItalic(62))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 16)
                    .animation(.easeOut(duration: 1.2).delay(0.3), value: showContent)

                Spacer()

                // Buttons
                VStack(spacing: 14) {
                    // Create profile
                    Button(action: onContinue) {
                        Text("CREATE PROFILE")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 12)
                    .animation(.easeOut(duration: 0.9).delay(0.8), value: showContent)

                    // Sign in
                    Button(action: onContinue) {
                        Text("SIGN IN")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                            )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 12)
                    .animation(.easeOut(duration: 0.9).delay(1.0), value: showContent)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .onAppear { showContent = true }
    }
}

#Preview {
    LandingView()
}
