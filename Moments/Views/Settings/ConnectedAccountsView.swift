import SwiftUI

struct ConnectedAccountsView: View {
    @Environment(MusicViewModel.self) private var musicViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACCOUNT")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)

                    Text("Connected Accounts")
                        .font(MomentsStyle.georgiaItalic(34))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text("Manage linked services.")
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // Spotify card
                HairlineCard {
                    HStack(spacing: 14) {
                        Image(systemName: "music.note")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Spotify")
                                .font(MomentsStyle.systemMedium(15))
                                .foregroundColor(MomentsStyle.primaryText)

                            Text(musicViewModel.isConnected ? "Connected" : "Not connected")
                                .font(MomentsStyle.systemLight(12))
                                .foregroundColor(MomentsStyle.secondaryText)
                        }

                        Spacer()

                        Button {
                            if musicViewModel.isConnected {
                                musicViewModel.disconnectAndForgetSession()
                            } else {
                                musicViewModel.authorize()
                            }
                        } label: {
                            Text(musicViewModel.isConnected ? "DISCONNECT" : "CONNECT")
                                .font(.system(size: 9, weight: .light))
                                .tracking(2)
                                .foregroundColor(musicViewModel.isConnected ? .red.opacity(0.6) : MomentsStyle.primaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .overlay(
                                    Capsule()
                                        .stroke(MomentsStyle.border, lineWidth: 0.5)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Connected Accounts")
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConnectedAccountsView()
            .environment(MusicViewModel())
    }
}
