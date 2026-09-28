import SwiftUI

enum SettingsDestination: Hashable {
    case editProfile
    case email
    case password
    case connectedAccounts
    case profileVisibility
    case blockedUsers
    case dataPrivacy
    case termsOfService
    case privacyPolicy
    case version
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(NotificationService.self) private var notificationService
    @Environment(AppLanguage.self) private var appLanguage
    @AppStorage(StorageKeys.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage(StorageKeys.momentReminders) private var momentReminders = true
    @AppStorage(StorageKeys.friendActivity) private var friendActivity = false
    @AppStorage(StorageKeys.darkMode) private var darkMode = false
    @AppStorage(StorageKeys.hapticsEnabled) private var haptics = true
    @Environment(\.openURL) private var openURL
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showDeleteReauth = false
    @State private var deletePassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Account section
                SettingsSection(title: Strings.settingsSectionAccount) {
                    NavigationLink(value: SettingsDestination.editProfile) {
                        SettingsRow(icon: "person.crop.circle", title: Strings.settingsRowEditProfile, subtitle: Strings.settingsRowEditProfileSubtitle)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.email) {
                        SettingsRow(icon: "envelope", title: Strings.settingsRowEmail, subtitle: userViewModel.currentUser?.email ?? "")
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.password) {
                        SettingsRow(icon: "lock", title: Strings.settingsRowPassword, subtitle: Strings.settingsRowPasswordSubtitle)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.connectedAccounts) {
                        SettingsRow(icon: "link", title: Strings.settingsRowConnectedAccounts, subtitle: Strings.settingsRowConnectedAccountsSubtitle)
                    }
                    .buttonStyle(.plain)
                }

                // Notifications section
                SettingsSection(title: Strings.settingsSectionNotifications) {
                    SettingsToggleRow(icon: "bell", title: Strings.settingsRowPushNotifications, isOn: $notificationsEnabled)
                    SettingsDivider()
                    SettingsToggleRow(icon: "clock", title: Strings.settingsRowMomentReminders, isOn: $momentReminders)
                    SettingsDivider()
                    SettingsToggleRow(icon: "person.2", title: Strings.settingsRowFriendActivity, isOn: $friendActivity)
                }

                // Appearance section
                SettingsSection(title: Strings.settingsSectionAppearance) {
                    SettingsToggleRow(icon: "moon", title: Strings.settingsRowDarkMode, isOn: $darkMode)
                    SettingsDivider()
                    SettingsToggleRow(icon: "hand.tap", title: Strings.settingsRowHapticFeedback, isOn: $haptics)
                }

                // Privacy section
                SettingsSection(title: Strings.settingsSectionPrivacy) {
                    NavigationLink(value: SettingsDestination.profileVisibility) {
                        SettingsRow(icon: "eye.slash", title: Strings.settingsRowProfileVisibility, subtitle: Strings.settingsRowProfileVisibilitySubtitle)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.blockedUsers) {
                        SettingsRow(icon: "hand.raised", title: Strings.settingsRowBlockedUsers, subtitle: Strings.settingsRowBlockedUsersSubtitle)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.dataPrivacy) {
                        SettingsRow(icon: "doc.text", title: Strings.settingsRowDataPrivacy, subtitle: Strings.settingsRowDataPrivacySubtitle)
                    }
                    .buttonStyle(.plain)
                }

                // Support section
                SettingsSection(title: Strings.settingsSectionSupport) {
                    Button {
                        openURL(URL(string: "mailto:momentsapp1@outlook.com?subject=Help")!)
                    } label: {
                        SettingsRow(icon: "questionmark.circle", title: Strings.settingsRowHelpCenter, subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    Button {
                        openURL(URL(string: "mailto:momentsapp1@outlook.com")!)
                    } label: {
                        SettingsRow(icon: "envelope.open", title: Strings.settingsRowContactUs, subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    Button {
                        openURL(URL(string: "itms-apps://itunes.apple.com/app/id6741511686?action=write-review")!)
                    } label: {
                        SettingsRow(icon: "star", title: Strings.settingsRowRateMoments, subtitle: nil)
                    }
                    .buttonStyle(.plain)
                }

                // About section
                SettingsSection(title: Strings.settingsSectionAbout) {
                    NavigationLink(value: SettingsDestination.termsOfService) {
                        SettingsRow(icon: "doc.plaintext", title: Strings.settingsRowTermsOfService, subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.privacyPolicy) {
                        SettingsRow(icon: "shield", title: Strings.settingsRowPrivacyPolicy, subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    SettingsDivider()
                    NavigationLink(value: SettingsDestination.version) {
                        SettingsRow(icon: "info.circle", title: Strings.settingsRowVersion, subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                    .buttonStyle(.plain)
                }

                // Sign out
                Button {
                    showSignOutConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 12, weight: .regular))

                        Text(Strings.settingsSignOut)
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                    }
                    .foregroundColor(.red.opacity(0.78))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(MomentsStyle.cardBackground)
                    .overlay(
                        Capsule()
                            .stroke(MomentsStyle.border, lineWidth: 0.5)
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(MomentsSecondaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text(Strings.settingsDangerZone)
                        .font(.system(size: 10, weight: .light))
                        .tracking(3)
                        .foregroundColor(MomentsStyle.secondaryText)

                    Button {
                        deletePassword = ""
                        showDeleteConfirm = true
                    } label: {
                        HairlineCard {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(MomentsStyle.surfaceSecondary)
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "trash")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(MomentsStyle.primaryText)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(Strings.settingsDeleteAccount)
                                        .font(MomentsStyle.systemMedium(14))
                                        .foregroundColor(MomentsStyle.primaryText)

                                    Text(Strings.settingsDeleteAccountSubtitle)
                                        .font(MomentsStyle.systemLight(12))
                                        .foregroundColor(MomentsStyle.secondaryText)
                                        .lineSpacing(2)
                                }

                                Spacer(minLength: 12)

                                Text(Strings.settingsDeleteForever.uppercased())
                                    .font(.system(size: 8, weight: .light))
                                    .tracking(2)
                                    .foregroundColor(MomentsStyle.secondaryText)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

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
                Text(Strings.settingsTitle)
                    .font(MomentsStyle.georgiaItalic(18))
                    .foregroundColor(MomentsStyle.primaryText)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.select()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        AppLanguage.shared.current = AppLanguage.shared.current == .english ? .danish : .english
                    }
                } label: {
                    Image(appLanguage.current == .english ? "flag-da" : "flag-en")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .navigationDestination(for: SettingsDestination.self) { destination in
            SettingsDestinationView(destination: destination)
        }
        .alert(Strings.settingsSignOutAlertTitle, isPresented: $showSignOutConfirm) {
            Button(Strings.settingsCancel, role: .cancel) { }
            Button(Strings.settingsSignOutConfirm, role: .destructive) {
                Haptics.warning()
                authViewModel.signOut()
            }
        } message: {
            Text(Strings.settingsSignOutAlertMessage)
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
        .alert(Strings.settingsDeleteAlertTitle, isPresented: $showDeleteConfirm) {
            Button(Strings.settingsCancel, role: .cancel) { }
            Button(Strings.settingsDeleteContinue, role: .destructive) {
                showDeleteReauth = true
            }
        } message: {
            Text(Strings.settingsDeleteAlertMessage)
        }
        .alert(Strings.settingsDeleteReauthTitle, isPresented: $showDeleteReauth) {
            SecureField(Strings.settingsDeletePasswordPlaceholder, text: $deletePassword)
            Button(Strings.settingsCancel, role: .cancel) { }
            Button(Strings.settingsDeleteForever, role: .destructive) {
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
            Text(Strings.settingsDeleteReauthMessage)
        }
    }

}

// MARK: - Settings Destination View

struct SettingsDestinationView: View {
    let destination: SettingsDestination

    var body: some View {
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
            detail(Strings.settingsDetailProfileVisibilityTitle, eyebrow: Strings.settingsDetailProfileVisibilityEyebrow, headline: Strings.settingsDetailProfileVisibilityHeadline, text: Strings.settingsDetailProfileVisibilityBody)
        case .blockedUsers:
            detail(Strings.settingsDetailBlockedUsersTitle, eyebrow: Strings.settingsDetailBlockedUsersEyebrow, headline: Strings.settingsDetailBlockedUsersHeadline, text: Strings.settingsDetailBlockedUsersBody)
        case .dataPrivacy:
            detail(Strings.settingsDetailDataPrivacyTitle, eyebrow: Strings.settingsDetailDataPrivacyEyebrow, headline: Strings.settingsDetailDataPrivacyHeadline, text: Strings.settingsDetailDataPrivacyBody)
        case .termsOfService:
            detail(Strings.settingsDetailTermsTitle, eyebrow: Strings.settingsDetailTermsEyebrow, headline: Strings.settingsDetailTermsHeadline, text: Strings.settingsDetailTermsBody)
        case .privacyPolicy:
            detail(Strings.settingsDetailPrivacyTitle, eyebrow: Strings.settingsDetailPrivacyEyebrow, headline: Strings.settingsDetailPrivacyHeadline, text: Strings.settingsDetailPrivacyBody)
        case .version:
            detail(Strings.settingsDetailVersionTitle, eyebrow: Strings.settingsDetailVersionEyebrow, headline: Strings.settingsDetailVersionHeadline, text: Strings.settingsDetailVersionBody(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"))
        }
    }

    private func detail(_ title: String, eyebrow: String, headline: String, text: String) -> SettingsDetailView {
        SettingsDetailView(title: title, eyebrow: eyebrow, headline: headline, detailText: text)
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
        .contentShape(Rectangle())
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
            .environment(AppLanguage.shared)
    }
}
