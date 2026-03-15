import SwiftUI

enum LandingChoice {
    case signIn, createAccount
}

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(CommunityViewModel.self) private var communityViewModel
    @State private var landingChoice: LandingChoice?

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .unknown:
                // Splash while Firebase checks auth state
                VStack {
                    Spacer()
                    Text("moments")
                        .font(MomentsStyle.georgiaItalic(28))
                        .foregroundColor(MomentsStyle.primaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(MomentsStyle.background)

            case .signedOut:
                if let choice = landingChoice {
                    NavigationStack {
                        switch choice {
                        case .signIn:
                            SignInView()
                        case .createAccount:
                            CreateAccountView()
                        }
                    }
                } else {
                    LandingView(
                        onCreateAccount: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                landingChoice = .createAccount
                            }
                        },
                        onSignIn: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                landingChoice = .signIn
                            }
                        }
                    )
                }

            case .signedIn(let uid):
                HomeView()
                    .task(id: uid) {
                        await userViewModel.fetchCurrentUser(uid: uid)
                    }
            }
        }
        .onChange(of: authViewModel.authState) { _, newValue in
            if case .signedOut = newValue {
                landingChoice = nil
                userViewModel.clear()
                communityViewModel.stopListening()
                communityViewModel.stopCommentsListener()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
        .environment(UserViewModel())
        .environment(CommunityViewModel())
        .environment(FoodViewModel())
        .environment(AppContentViewModel())
}
