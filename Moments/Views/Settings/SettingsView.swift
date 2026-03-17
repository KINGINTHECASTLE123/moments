import SwiftUI

enum SettingsDestination: Hashable {
    case editProfile
    case email
    case password
    case connectedAccounts
    case profileVisibility
    case blockedUsers
    case dataPrivacy
    case helpCenter
    case contactUs
    case rateMoments
    case termsOfService
    case privacyPolicy
    case version
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(NotificationService.self) private var notificationService
    @AppStorage(StorageKeys.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage(StorageKeys.momentReminders) private var momentReminders = true
    @AppStorage(StorageKeys.friendActivity) private var friendActivity = false
    @AppStorage(StorageKeys.darkMode) private var darkMode = false
    @AppStorage(StorageKeys.hapticsEnabled) private var haptics = true
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showDeleteReauth = false
    @State private var deletePassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Account section
                SettingsSection(title: "Account") {
                    NavigationLink(value: SettingsDestination.editProfile) {
                        SettingsRow(icon: "person.crop.circle", title: "Edit Profile", subtitle: "Name, bio, photo")
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.email) {
                        SettingsRow(icon: "envelope", title: "Email", subtitle: userViewModel.currentUser?.email ?? "")
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.password) {
                        SettingsRow(icon: "lock", title: "Password", subtitle: "Change your password")
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.connectedAccounts) {
                        SettingsRow(icon: "link", title: "Connected Accounts", subtitle: "Spotify, Instagram")
                    }
                    .buttonStyle(.plain)
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
                    NavigationLink(value: SettingsDestination.profileVisibility) {
                        SettingsRow(icon: "eye.slash", title: "Profile Visibility", subtitle: "Friends only")
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.blockedUsers) {
                        SettingsRow(icon: "hand.raised", title: "Blocked Users", subtitle: "None")
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.dataPrivacy) {
                        SettingsRow(icon: "doc.text", title: "Data & Privacy", subtitle: "Download or delete your data")
                    }
                    .buttonStyle(.plain)
                }

                // Support section
                SettingsSection(title: "Support") {
                    NavigationLink(value: SettingsDestination.helpCenter) {
                        SettingsRow(icon: "questionmark.circle", title: "Help Center", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.contactUs) {
                        SettingsRow(icon: "envelope.open", title: "Contact Us", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.rateMoments) {
                        SettingsRow(icon: "star", title: "Rate Moments", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                }

                // About section
                SettingsSection(title: "About") {
                    NavigationLink(value: SettingsDestination.termsOfService) {
                        SettingsRow(icon: "doc.plaintext", title: "Terms of Service", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.privacyPolicy) {
                        SettingsRow(icon: "shield", title: "Privacy Policy", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.version) {
                        SettingsRow(icon: "info.circle", title: "Version", subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                    .buttonStyle(.plain)
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
                Button {
                    deletePassword = ""
                    showDeleteConfirm = true
                } label: {
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

                    Text("Copenhagen · \(Calendar.current.component(.year, from: Date()))")
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
        .navigationDestination(for: SettingsDestination.self) { destination in
            switch destination {
            case .editProfile:
                EditProfileView()
            case .email:
                ChangeEmailView()
            case .password:
                ChangePasswordView()
            case .connectedAccounts:
                ConnectedAccountsView()
            case .profileVisibility:
                SettingsDetailView(
                    title: "Profile Visibility",
                    eyebrow: "Privacy",
                    headline: "Control who sees your profile.",
                    detailText: "Your profile is currently visible to friends only. Adjust visibility when you want to be more discoverable or keep things close."
                )
            case .blockedUsers:
                SettingsDetailView(
                    title: "Blocked Users",
                    eyebrow: "Privacy",
                    headline: "Review people you have blocked.",
                    detailText: "Blocking removes visibility across community interactions and prevents new activity between you and those accounts."
                )
            case .dataPrivacy:
                SettingsDetailView(
                    title: "Data & Privacy",
                    eyebrow: "Privacy",
                    headline: "Manage the data attached to your account.",
                    detailText: "You can request an export of your account information or start a deletion request if you want to remove your data from Moments."
                )
            case .helpCenter:
                SettingsDetailView(
                    title: "Help Center",
                    eyebrow: "Support",
                    headline: "Find answers fast.",
                    detailText: "Browse setup guides, troubleshooting notes, and FAQs for account access, sharing, posting, and playlist features."
                )
            case .contactUs:
                SettingsDetailView(
                    title: "Contact Us",
                    eyebrow: "Support",
                    headline: "Get in touch with the team.",
                    detailText: "For support requests, bug reports, or feedback, email us at momentsapp1@outlook.com. We aim to respond within 48 hours."
                )
            case .rateMoments:
                SettingsDetailView(
                    title: "Rate Moments",
                    eyebrow: "Support",
                    headline: "Share how the app feels to use.",
                    detailText: "Ratings and short reviews help shape the product and make it easier for the right people to discover Moments."
                )
            case .termsOfService:
                SettingsDetailView(
                    title: "Terms of Service",
                    eyebrow: "About",
                    headline: "Terms of use for Moments.",
                    detailText: """
                    Last updated: March 2026

                    By using Moments, you agree to these terms. You must be at least 13 years old to use this app.

                    You are responsible for all content you post. Do not post content that is illegal, harmful, threatening, abusive, harassing, defamatory, or otherwise objectionable.

                    We reserve the right to remove content or suspend accounts that violate these terms without prior notice.

                    Your content remains yours. By posting, you grant Moments a non-exclusive license to display it within the app.

                    The app is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of the app.

                    We may update these terms at any time. Continued use after changes constitutes acceptance.

                    For questions, contact us at momentsapp1@outlook.com.
                    """
                )
            case .privacyPolicy:
                SettingsDetailView(
                    title: "Privacy Policy",
                    eyebrow: "About",
                    headline: "How we handle your information.",
                    detailText: """
                    Last updated: March 2026

                    Moments collects: your name, email address, profile photo, and content you post (text and images). This data is stored securely using Firebase (Google Cloud).

                    We use your data solely to provide the app's functionality: authentication, profile display, and community features.

                    We do not sell, share, or rent your personal data to third parties. We do not track you across other apps or websites.

                    If you connect Spotify, we store an access token securely in your device's Keychain. We do not access your Spotify account data beyond playback control and playlist cover art.

                    You can delete your account and all associated data at any time from Settings → Delete Account.

                    We use no third-party analytics or advertising SDKs. The app does not contain ads.

                    For data requests or questions, contact momentsapp1@outlook.com.
                    """
                )
            case .version:
                SettingsDetailView(
                    title: "Version",
                    eyebrow: "About",
                    headline: "Current build",
                    detailText: "Moments \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")\nDesigned in Copenhagen with a focus on intimate social experiences."
                )
            }
        }
        .alert("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Haptics.warning()
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: notificationsEnabled) { _, enabled in
            Task {
                if enabled {
                    await notificationService.requestAuthorization()
                    if momentReminders {
                        await notificationService.scheduleMomentReminders()
                    }
                } else {
                    notificationService.cancelMomentReminders()
                }
            }
        }
        .onChange(of: momentReminders) { _, enabled in
            Task {
                guard notificationsEnabled else { return }
                await notificationService.updateMomentReminders(enabled: enabled)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showDeleteReauth = true
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .alert("Confirm Password", isPresented: $showDeleteReauth) {
            SecureField("Password", text: $deletePassword)
            Button("Cancel", role: .cancel) { }
            Button("Delete Forever", role: .destructive) {
                Task {
                    guard case .signedIn(let uid) = authViewModel.authState else { return }
                    let reauthed = await authViewModel.reauthenticate(
                        email: userViewModel.currentUser?.email ?? "",
                        password: deletePassword
                    )
                    guard reauthed else { return }
                    // Delete Firestore data first while still authenticated
                    await userViewModel.deleteUserData(uid: uid)
                    guard userViewModel.errorMessage == nil else { return }
                    // Then delete the auth account
                    await authViewModel.deleteAccount()
                }
            }
        } message: {
            Text("Enter your password to confirm account deletion.")
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
            .background(MomentsStyle.cardBackground)
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
                .tint(MomentsStyle.accent)
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

struct SettingsDetailView: View {
    let title: String
    let eyebrow: String
    let headline: String
    let detailText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow.uppercased())
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)

                    Text(title)
                        .font(MomentsStyle.georgiaItalic(34))
                        .foregroundColor(MomentsStyle.primaryText)

                    Text(headline)
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                HairlineCard {
                    Text(detailText)
                        .font(MomentsStyle.systemLight(14))
                        .foregroundColor(MomentsStyle.primaryText)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 32)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AuthViewModel())
            .environment(UserViewModel())
            .environment(NotificationService())
    }
}
