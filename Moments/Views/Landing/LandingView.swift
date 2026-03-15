import SwiftUI

struct LandingView: View {
    @Environment(AppContentViewModel.self) private var appContentViewModel
    @State private var showContent = false
    var onCreateAccount: () -> Void = {}
    var onSignIn: () -> Void = {}

    var body: some View {
        ZStack {
            RemoteStorageImageView(urlString: appContentViewModel.landingHeroImageURL) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.85),
                                Color.black.opacity(0.45)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()

            if appContentViewModel.landingHeroImageURL == nil {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.85),
                                Color.black.opacity(0.45)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            }

            // Full-bleed background photo
            Color.clear
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
                    Button(action: onCreateAccount) {
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
                    Button(action: onSignIn) {
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
        .task {
            await appContentViewModel.fetchContentIfNeeded()
        }
        .onAppear { showContent = true }
    }
}

#Preview {
    LandingView()
}
