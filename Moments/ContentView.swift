import SwiftUI

enum AppScreen {
    case landing
    case signIn
    case createAccount
    case home
}

struct ContentView: View {
    @State private var screen: AppScreen = .landing

    var body: some View {
        switch screen {
        case .landing:
            LandingView(
                onCreateAccount: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        screen = .createAccount
                    }
                },
                onSignIn: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        screen = .signIn
                    }
                }
            )

        case .signIn:
            NavigationStack {
                SignInView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        screen = .home
                    }
                }
            }

        case .createAccount:
            NavigationStack {
                CreateAccountView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        screen = .home
                    }
                }
            }

        case .home:
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
