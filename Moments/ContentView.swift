import SwiftUI

struct ContentView: View {
    @State private var showMain = false

    var body: some View {
        if showMain {
            HomeView()
        } else {
            LandingView {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showMain = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
