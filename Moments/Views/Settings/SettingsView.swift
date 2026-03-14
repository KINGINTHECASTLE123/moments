import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var momentReminders = true
    @State private var friendActivity = false
    @State private var darkMode = false
    @State private var haptics = true
    @State private var showSignOutConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Account section
                SettingsSection(title: "Account") {
                    SettingsRow(icon: "person.crop.circle", title: "Edit Profile", subtitle: "Name, bio, photo")
                    SettingsDivider()
                    SettingsRow(icon: "envelope", title: "Email", subtitle: "jacob@moments.app")
                    SettingsDivider()
                    SettingsRow(icon: "lock", title: "Password", subtitle: "Last changed 3 months ago")
                    SettingsDivider()
                    SettingsRow(icon: "link", title: "Connected Accounts", subtitle: "Spotify, Instagram")
                }

                // Notifications section
                SettingsSection(title: "Notifications") {
                    SettingsToggleRow(icon: "bell", title: "Push Notifications", isOn: $notificationsEnabled)
                    SettingsDivider()
                    SettingsToggleRow(icon: "clock", title: "Moment Reminders", isOn: $momentReminders)
                    SettingsDivider()
                    SettingsToggleRow(icon: "person.2", title: "Friend Activity", isOn: $friendActivity)
                }

                // Appearance section
                SettingsSection(title: "Appearance") {
                    SettingsToggleRow(icon: "moon", title: "Dark Mode", isOn: $darkMode)
                    SettingsDivider()
                    SettingsToggleRow(icon: "hand.tap", title: "Haptic Feedback", isOn: $haptics)
                }

                // Privacy section
                SettingsSection(title: "Privacy") {
                    SettingsRow(icon: "eye.slash", title: "Profile Visibility", subtitle: "Friends only")
                    SettingsDivider()
                    SettingsRow(icon: "hand.raised", title: "Blocked Users", subtitle: "None")
                    SettingsDivider()
                    SettingsRow(icon: "doc.text", title: "Data & Privacy", subtitle: "Download or delete your data")
                }

                // Support section
                SettingsSection(title: "Support") {
                    SettingsRow(icon: "questionmark.circle", title: "Help Center", subtitle: nil)
                    SettingsDivider()
                    SettingsRow(icon: "envelope.open", title: "Contact Us", subtitle: nil)
                    SettingsDivider()
                    SettingsRow(icon: "star", title: "Rate Moments", subtitle: nil)
                }

                // About section
                SettingsSection(title: "About") {
                    SettingsRow(icon: "doc.plaintext", title: "Terms of Service", subtitle: nil)
                    SettingsDivider()
                    SettingsRow(icon: "shield", title: "Privacy Policy", subtitle: nil)
                    SettingsDivider()
                    SettingsRow(icon: "info.circle", title: "Version", subtitle: "1.0.0")
                }

                // Sign out
                Button {
                    showSignOutConfirm = true
                } label: {
                    Text("SIGN OUT")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            Capsule()
                                .stroke(MomentsStyle.border, lineWidth: 0.5)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Delete account
                Button { } label: {
                    Text("DELETE ACCOUNT")
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(Color.red.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Footer
                VStack(spacing: 6) {
                    Rectangle()
                        .frame(width: 28, height: 0.5)
                        .foregroundColor(MomentsStyle.border)

                    Text("moments")
                        .font(MomentsStyle.georgiaItalic(14))
                        .foregroundColor(MomentsStyle.inactive)
                        .padding(.top, 8)

                    Text("Copenhagen · 2025")
                        .font(.system(size: 9, weight: .light))
                        .tracking(2)
                        .foregroundColor(MomentsStyle.inactive)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)

                Spacer(minLength: 40)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
        .alert("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .background(Color.white)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(MomentsStyle.primaryText)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MomentsStyle.systemRegular(15))
                    .foregroundColor(MomentsStyle.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(MomentsStyle.inactive)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(MomentsStyle.primaryText)
                .frame(width: 24)

            Text(title)
                .font(MomentsStyle.systemRegular(15))
                .foregroundColor(MomentsStyle.primaryText)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(MomentsStyle.primaryText)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Divider

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 0.5)
            .foregroundColor(MomentsStyle.border)
            .padding(.leading, 38)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
