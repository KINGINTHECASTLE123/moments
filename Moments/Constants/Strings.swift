import Foundation

// MARK: - Strings

/// Central translation registry. All UI strings go through here.
/// Usage: `Text(Strings.tabGames)`
enum Strings {

    private static var lang: Language { AppLanguage.shared.current }

    // MARK: - Tabs

    static var tabHome: String { lang == .english ? "Home" : "Hjem" }
    static var tabGames: String { lang == .english ? "Games" : "Spil" }
    static var tabFood: String { lang == .english ? "Food" : "Mad" }
    static var tabDrinks: String { lang == .english ? "Drinks" : "Drinks" }
    static var tabMusic: String { lang == .english ? "Music" : "Musik" }
    static var tabCommunity: String { lang == .english ? "Community" : "Fællesskab" }

    // MARK: - Landing

    static var landingCreateProfile: String { lang == .english ? "CREATE PROFILE" : "OPRET PROFIL" }
    static var landingSignIn: String { lang == .english ? "SIGN IN" : "LOG IND" }

    // MARK: - Sign In

    static var signInWelcomeBack: String { lang == .english ? "Welcome back" : "Velkommen tilbage" }
    static var signInSubtitle: String { lang == .english ? "Sign in to your account" : "Log ind på din konto" }
    static var signInEmailLabel: String { lang == .english ? "EMAIL" : "EMAIL" }
    static var signInEmailPlaceholder: String { lang == .english ? "your@email.com" : "din@email.com" }
    static var signInPasswordLabel: String { lang == .english ? "PASSWORD" : "ADGANGSKODE" }
    static var signInPasswordPlaceholder: String { lang == .english ? "Enter your password" : "Indtast din adgangskode" }
    static var signInForgotPassword: String { lang == .english ? "FORGOT PASSWORD?" : "GLEMT ADGANGSKODE?" }
    static var signInButton: String { lang == .english ? "SIGN IN" : "LOG IND" }

    // MARK: - Create Account

    static var createAccountTitle: String { lang == .english ? "Create account" : "Opret konto" }
    static var createAccountSubtitle: String { lang == .english ? "Let's get you started" : "Lad os komme i gang" }
    static var createAccountFullNameLabel: String { lang == .english ? "FULL NAME" : "FULDE NAVN" }
    static var createAccountFullNamePlaceholder: String { lang == .english ? "Your name" : "Dit navn" }
    static var createAccountEmailLabel: String { lang == .english ? "EMAIL" : "EMAIL" }
    static var createAccountEmailPlaceholder: String { lang == .english ? "your@email.com" : "din@email.com" }
    static var createAccountPasswordLabel: String { lang == .english ? "PASSWORD" : "ADGANGSKODE" }
    static var createAccountPasswordPlaceholder: String { lang == .english ? "Choose a password" : "Vælg en adgangskode" }
    static var createAccountPasswordTooShort: String { lang == .english ? "Password must be at least 6 characters." : "Adgangskoden skal være mindst 6 tegn." }
    static var createAccountFillAllFields: String { lang == .english ? "Please fill in all fields." : "Udfyld venligst alle felter." }
    static var createAccountProfileTitle: String { lang == .english ? "Your profile" : "Din profil" }
    static var createAccountProfileSubtitle: String { lang == .english ? "How others will see you" : "Sådan ser andre dig" }
    static var createAccountAddPhoto: String { lang == .english ? "ADD PHOTO" : "TILFØJ FOTO" }
    static var createAccountUsernameLabel: String { lang == .english ? "USERNAME" : "BRUGERNAVN" }
    static var createAccountUsernamePlaceholder: String { lang == .english ? "@username" : "@brugernavn" }
    static var createAccountBioLabel: String { lang == .english ? "BIO" : "BIO" }
    static var createAccountBioPlaceholder: String { lang == .english ? "Tell us about yourself..." : "Fortæl lidt om dig selv..." }
    static var createAccountInterestsTitle: String { lang == .english ? "Your interests" : "Dine interesser" }
    static var createAccountInterestsSubtitle: String { lang == .english ? "Pick at least 3 to personalize your experience" : "Vælg mindst 3 for at tilpasse din oplevelse" }
    static var createAccountUsernameInvalid: String { lang == .english ? "Username can only contain letters, numbers, dots, and underscores (2-30 characters)." : "Brugernavnet må kun indeholde bogstaver, tal, punktummer og understreger (2-30 tegn)." }
    static var createAccountChooseUsername: String { lang == .english ? "Please choose a username." : "Vælg venligst et brugernavn." }
    static var createAccountContinue: String { lang == .english ? "CONTINUE" : "FORTSÆT" }
    static var createAccountGetStarted: String { lang == .english ? "GET STARTED" : "KOM I GANG" }

    // MARK: - Forgot Password

    static var forgotPasswordTitle: String { lang == .english ? "Reset password" : "Nulstil adgangskode" }
    static var forgotPasswordSubtitle: String { lang == .english ? "Enter your email and we'll send you a link to reset your password." : "Indtast din email, så sender vi dig et link til at nulstille din adgangskode." }
    static var forgotPasswordEmailLabel: String { lang == .english ? "EMAIL" : "EMAIL" }
    static var forgotPasswordEmailPlaceholder: String { lang == .english ? "your@email.com" : "din@email.com" }
    static var forgotPasswordCheckEmail: String { lang == .english ? "Check your email" : "Tjek din email" }
    static var forgotPasswordSentPrefix: String { lang == .english ? "We've sent a password reset link to" : "Vi har sendt et link til nulstilling af adgangskode til" }
    static var forgotPasswordSendButton: String { lang == .english ? "SEND RESET LINK" : "SEND NULSTILLINGSLINK" }
    static var forgotPasswordBackToSignIn: String { lang == .english ? "BACK TO SIGN IN" : "TILBAGE TIL LOG IND" }

    static func verificationSentTo(_ email: String) -> String {
        lang == .english
            ? "We've sent a password reset link to \(email)"
            : "Vi har sendt et link til nulstilling af adgangskode til \(email)"
    }

    // MARK: - Home

    // "moments" is a brand name — intentionally not translated.
    static var homeBrandName: String { "moments" }
    static var homeCreateMoment: String { lang == .english ? "Create new moment" : "Opret nyt moment" }
    static var homeLiveMoment: String { lang == .english ? "LIVE MOMENT" : "LIVE MOMENT" }
    static var homeViewActiveMoment: String { lang == .english ? "View active moment" : "Se aktivt moment" }
    static var homeSettings: String { lang == .english ? "Settings" : "Indstillinger" }
    static var homeViewProfile: String { lang == .english ? "View profile" : "Se profil" }

    // MARK: - Games

    static var gamesTitle: String { lang == .english ? "Games" : "Spil" }
    static var gamesSubtitle: String { lang == .english ? "Break the ice, spark the night" : "Bryd isen, tænd aftenen" }
    static var gamesLightSocial: String { lang == .english ? "Light & Social" : "Let & Socialt" }
    static var gamesDeepPlayful: String { lang == .english ? "Deep & Playful" : "Dybt & Legende" }
    static var gamesHowToPlay: String { lang == .english ? "How to Play" : "Sådan spiller du" }
    static var gamesStartGame: String { lang == .english ? "START GAME" : "START SPIL" }
    static var gamesEndGame: String { lang == .english ? "END GAME" : "AFSLUT SPIL" }
    static var gamesNext: String { lang == .english ? "NEXT" : "NÆSTE" }
    static var gamesFinish: String { lang == .english ? "FINISH" : "AFSLUT" }
    static var gamesPrompts: String { lang == .english ? "prompts" : "kort" }
    static var gamesOf: String { lang == .english ? "of" : "af" }
    static var gamesOr: String { lang == .english ? "or" : "eller" }

    // Game play instructions (indexed to match GameType order)
    static var gameInstructionWouldYouRather: String { lang == .english ? "Read both options aloud. Everyone picks a side." : "Læs begge muligheder højt. Alle vælger side." }
    static var gameInstructionHeadsUp: String { lang == .english ? "Hold phone to your forehead. Friends describe the word." : "Hold telefonen mod panden. Venner beskriver ordet." }
    static var gameInstructionCharades: String { lang == .english ? "Act it out. No talking, no pointing." : "Vis det. Ingen tale, ingen pegeri." }
    static var gameInstructionLateNight: String { lang == .english ? "Read aloud. Everyone takes a turn answering." : "Læs højt. Alle svarer på skift." }
    static var gameInstructionFlirtyFun: String { lang == .english ? "Read the prompt. Be bold." : "Læs kortet. Vær modig." }
    static var gameInstructionHighStakes: String { lang == .english ? "Complete the dare — or face the penalty." : "Udfør udfordringen — eller tag konsekvensen." }

    // MARK: - Food

    static var foodTitle: String { lang == .english ? "Food" : "Mad" }
    static var foodSubtitle: String { lang == .english ? "Curated dishes for every course" : "Udvalgte retter til enhver anledning" }
    static var foodCouldntLoad: String { lang == .english ? "Couldn't load dishes" : "Kunne ikke indlæse retter" }
    static var foodTryAgain: String { lang == .english ? "TRY AGAIN" : "PRØV IGEN" }
    static var foodIngredients: String { lang == .english ? "Ingredients" : "Ingredienser" }
    static var foodInstructions: String { lang == .english ? "Instructions" : "Fremgangsmåde" }

    static func foodEmptyState(_ category: String) -> String {
        lang == .english
            ? "No dishes have been added for \(category) yet."
            : "Der er endnu ikke tilføjet retter til \(category)."
    }

    // Food category names
    static var foodCategoryStarters: String { lang == .english ? "Starters" : "Forretter" }
    static var foodCategoryMains: String { lang == .english ? "Mains" : "Hovedretter" }
    static var foodCategoryDesserts: String { lang == .english ? "Desserts" : "Desserter" }

    // MARK: - Drinks

    static var drinksTitle: String { lang == .english ? "Drinks" : "Drinks" }
    static var drinksSubtitle: String { lang == .english ? "Curated cocktails, juices & mocktails" : "Udvalgte cocktails, juices og mocktails" }
    static var drinksCouldntLoad: String { lang == .english ? "Couldn't load drinks" : "Kunne ikke indlæse drinks" }
    static var drinksTryAgain: String { lang == .english ? "TRY AGAIN" : "PRØV IGEN" }
    static var drinksIngredients: String { lang == .english ? "Ingredients" : "Ingredienser" }
    static var drinksInstructions: String { lang == .english ? "Instructions" : "Fremgangsmåde" }

    static func drinksEmptyState(_ category: String) -> String {
        lang == .english
            ? "No drinks have been added for \(category) yet."
            : "Der er endnu ikke tilføjet drinks til \(category)."
    }

    // Drinks category names
    static var drinksCategoryCocktails: String { lang == .english ? "Cocktails" : "Cocktails" }
    static var drinksCategoryJuices: String { lang == .english ? "Juices" : "Juices" }
    static var drinksCategoryMocktails: String { lang == .english ? "Mocktails" : "Mocktails" }

    // MARK: - Music

    static var musicTitle: String { lang == .english ? "Music" : "Musik" }
    static var musicSubtitle: String { lang == .english ? "Set the mood for every moment" : "Sæt stemningen til ethvert moment" }
    static var musicTonightsPick: String { lang == .english ? "TONIGHT'S PICK" : "AFTENENS VALG" }
    static var musicBrowseByMood: String { lang == .english ? "BROWSE BY MOOD" : "BROWSE EFTER STEMNING" }
    static var musicAllPlaylists: String { lang == .english ? "ALL PLAYLISTS" : "ALLE SPILLELISTER" }
    static var musicConnectSpotify: String { lang == .english ? "CONNECT SPOTIFY" : "TILSLUT SPOTIFY" }
    static var musicConnectPrompt: String { lang == .english ? "Connect your Spotify account to play music, browse your playlists, and control playback directly from Moments." : "Tilslut din Spotify-konto for at afspille musik, gennemse dine spillelister og styre afspilningen direkte fra Moments." }
    static var musicConnect: String { lang == .english ? "CONNECT" : "TILSLUT" }
    static var musicDisconnect: String { lang == .english ? "DISCONNECT" : "AFBRYD" }
    static var musicPlay: String { lang == .english ? "PLAY" : "AFSPIL" }
    static var musicShuffle: String { lang == .english ? "SHUFFLE" : "SHUFFLE" }
    static var musicViewInSpotify: String { lang == .english ? "VIEW IN SPOTIFY" : "ÅBN I SPOTIFY" }
    static var musicNowPlaying: String { lang == .english ? "NOW PLAYING" : "SPILLER NU" }
    static var musicConnected: String { lang == .english ? "Connected" : "Tilsluttet" }
    static var musicNotConnected: String { lang == .english ? "Not connected" : "Ikke tilsluttet" }
    static var musicConnectedToSpotify: String { lang == .english ? "Connected to Spotify" : "Tilsluttet Spotify" }
    static var musicNoPlaylistSelected: String { lang == .english ? "No playlist selected" : "Ingen spilleliste valgt" }
    static var musicTapToPlay: String { lang == .english ? "Tap to play on Spotify" : "Tryk for at afspille på Spotify" }
    static var musicConnectToPlay: String { lang == .english ? "Connect Spotify to control playback" : "Tilslut Spotify for at styre afspilning" }
    static var musicConnectToPlayButton: String { lang == .english ? "CONNECT TO PLAY" : "TILSLUT FOR AT AFSPILLE" }
    static var musicCuratedPlaylist: String { lang == .english ? "Curated playlist" : "Udvalgt spilleliste" }

    // Mood filter labels
    static var musicMoodAll: String { lang == .english ? "All" : "Alle" }
    static var musicMoodIntimate: String { lang == .english ? "Intimate" : "Intim" }
    static var musicMoodEnergetic: String { lang == .english ? "Energetic" : "Energisk" }
    static var musicMoodChill: String { lang == .english ? "Chill" : "Afslappet" }

    // MARK: - Accessibility

    static func likeButtonLiked(_ count: Int) -> String {
        lang == .english
            ? "Unlike, \(count) likes"
            : "Fjern like, \(count) likes"
    }

    static func likeButtonNotLiked(_ count: Int) -> String {
        lang == .english
            ? "Like, \(count) likes"
            : "Like, \(count) likes"
    }

    // MARK: - Community

    static var communityTitle: String { lang == .english ? "Community" : "Fællesskab" }
    static var communitySubtitle: String { lang == .english ? "What's happening around you" : "Hvad sker der omkring dig" }
    static var communityCouldntLoad: String { lang == .english ? "Couldn't load posts" : "Kunne ikke indlæse opslag" }
    static var communityTryAgain: String { lang == .english ? "TRY AGAIN" : "PRØV IGEN" }
    static var communityEmptyTitle: String { lang == .english ? "No posts yet" : "Ingen opslag endnu" }
    static var communityEmptySubtitle: String { lang == .english ? "Be the first to share something with the community" : "Vær den første til at dele noget med fællesskabet" }
    static var communityCreatePost: String { lang == .english ? "CREATE POST" : "OPRET OPSLAG" }
    static var communityDeletePost: String { lang == .english ? "Delete Post" : "Slet opslag" }
    static var communityDeletePostConfirmation: String { lang == .english ? "This post will be permanently deleted." : "Dette opslag slettes permanent." }
    static var communityCancel: String { lang == .english ? "Cancel" : "Annuller" }
    static var communityDelete: String { lang == .english ? "Delete" : "Slet" }
    static var communityReportPost: String { lang == .english ? "Report Post" : "Anmeld opslag" }
    static var communityReportPostTitle: String { lang == .english ? "Why are you reporting this?" : "Hvorfor anmelder du dette?" }
    static var communityReportPostConfirmation: String { lang == .english ? "Thank you. We'll review this post." : "Tak. Vi gennemgår dette opslag." }
    static var communityReportSpam: String { lang == .english ? "Spam" : "Spam" }
    static var communityReportHarassment: String { lang == .english ? "Harassment" : "Chikane" }
    static var communityReportInappropriate: String { lang == .english ? "Inappropriate content" : "Upassende indhold" }
    static var communityReportOther: String { lang == .english ? "Other" : "Andet" }
    static var communityReportComment: String { lang == .english ? "Report Comment" : "Anmeld kommentar" }
    static var communityReportCommentConfirmation: String { lang == .english ? "Thank you. We'll review this comment." : "Tak. Vi gennemgår denne kommentar." }

    // Create Post
    static var createPostPlaceholder: String { lang == .english ? "Share a moment..." : "Del et øjeblik..." }
    static var createPostTitle: String { lang == .english ? "Posting to Community" : "Opslår til fællesskab" }
    static var createPostTag: String { lang == .english ? "TAG" : "TAG" }
    static var createPostNavigationTitle: String { lang == .english ? "New Post" : "Nyt opslag" }
    static var createPostCancel: String { lang == .english ? "Cancel" : "Annuller" }
    static var createPostPost: String { lang == .english ? "POST" : "OPSLÅ" }

    // Post Detail / Comments
    static var postDetailComments: String { lang == .english ? "COMMENTS" : "KOMMENTARER" }
    static var postDetailAddComment: String { lang == .english ? "Add a comment..." : "Tilføj en kommentar..." }
    static var postDetailReply: String { lang == .english ? "REPLY" : "SVAR" }
    static var postDetailDeleteComment: String { lang == .english ? "Delete Comment" : "Slet kommentar" }

    // MARK: - Profile

    static var profileTitle: String { lang == .english ? "Profile" : "Profil" }
    static var profileEditProfile: String { lang == .english ? "EDIT PROFILE" : "REDIGER PROFIL" }
    static var profileInterests: String { lang == .english ? "INTERESTS" : "INTERESSER" }
    static var profileFavorites: String { lang == .english ? "FAVORITES" : "FAVORITTER" }
    static var profileRecentMoments: String { lang == .english ? "RECENT MOMENTS" : "SENESTE MOMENTER" }
    static var profileComingSoon: String { lang == .english ? "COMING SOON" : "KOMMER SNART" }
    static var profileNoMomentsYet: String { lang == .english ? "No moments yet" : "Ingen momenter endnu" }
    static var profileNoMomentsSubtitle: String { lang == .english ? "Create your first moment to see it here." : "Opret dit første moment for at se det her." }
    static var profileNoFavoritesSubtitle: String { lang == .english ? "Complete a moment to see your favourites here." : "Afslut et moment for at se dine favoritter her." }
    static var profileFavouritePlaylist: String { lang == .english ? "Top playlist" : "Favoritspilleliste" }
    static var profileFavouriteGame: String { lang == .english ? "Most played game" : "Mest spillede spil" }
    static var profileFavouriteDish: String { lang == .english ? "Most cooked dish" : "Mest lavede ret" }
    static var profileMemberSince: String { lang == .english ? "Member since" : "Medlem siden" }
    static var profileMoments: String { lang == .english ? "Moments" : "Momenter" }
    static var profileFriends: String { lang == .english ? "Friends" : "Venner" }
    static var profileLikes: String { lang == .english ? "Likes" : "Likes" }
    static var profilePeople: String { lang == .english ? "people" : "personer" }

    // Edit Profile
    static var editProfileTitle: String { lang == .english ? "Edit Profile" : "Rediger profil" }
    static var editProfileFullNameLabel: String { lang == .english ? "FULL NAME" : "FULDE NAVN" }
    static var editProfileFullNamePlaceholder: String { lang == .english ? "Your name" : "Dit navn" }
    static var editProfileUsernameLabel: String { lang == .english ? "USERNAME" : "BRUGERNAVN" }
    static var editProfileUsernamePlaceholder: String { lang == .english ? "@username" : "@brugernavn" }
    static var editProfileBioLabel: String { lang == .english ? "BIO" : "BIO" }
    static var editProfileBioPlaceholder: String { lang == .english ? "Tell us about yourself..." : "Fortæl lidt om dig selv..." }
    static var editProfileInterests: String { lang == .english ? "INTERESTS" : "INTERESSER" }
    static var editProfileSaveChanges: String { lang == .english ? "SAVE CHANGES" : "GEM ÆNDRINGER" }
    static var editProfileCancel: String { lang == .english ? "Cancel" : "Annuller" }

    // MARK: - Settings

    static var settingsTitle: String { lang == .english ? "Settings" : "Indstillinger" }
    static var settingsLanguage: String { lang == .english ? "Language" : "Sprog" }

    // Account section
    static var settingsSectionAccount: String { lang == .english ? "Account" : "Konto" }
    static var settingsRowEditProfile: String { lang == .english ? "Edit Profile" : "Rediger profil" }
    static var settingsRowEditProfileSubtitle: String { lang == .english ? "Name, bio, photo" : "Navn, bio, foto" }
    static var settingsRowEmail: String { lang == .english ? "Email" : "Email" }
    static var settingsRowPassword: String { lang == .english ? "Password" : "Adgangskode" }
    static var settingsRowPasswordSubtitle: String { lang == .english ? "Change your password" : "Skift din adgangskode" }
    static var settingsRowConnectedAccounts: String { lang == .english ? "Connected Accounts" : "Tilknyttede konti" }
    static var settingsRowConnectedAccountsSubtitle: String { lang == .english ? "Spotify, Instagram" : "Spotify, Instagram" }

    // Notifications section
    static var settingsSectionNotifications: String { lang == .english ? "Notifications" : "Notifikationer" }
    static var settingsRowPushNotifications: String { lang == .english ? "Push Notifications" : "Push-notifikationer" }
    static var settingsRowMomentReminders: String { lang == .english ? "Moment Reminders" : "Momentpåmindelser" }
    static var settingsRowFriendActivity: String { lang == .english ? "Friend Activity" : "Vennernes aktivitet" }

    // Appearance section
    static var settingsSectionAppearance: String { lang == .english ? "Appearance" : "Udseende" }
    static var settingsRowDarkMode: String { lang == .english ? "Dark Mode" : "Mørk tilstand" }
    static var settingsRowHapticFeedback: String { lang == .english ? "Haptic Feedback" : "Haptisk feedback" }

    // Privacy section
    static var settingsSectionPrivacy: String { lang == .english ? "Privacy" : "Privatliv" }
    static var settingsRowProfileVisibility: String { lang == .english ? "Profile Visibility" : "Profilsynlighed" }
    static var settingsRowProfileVisibilitySubtitle: String { lang == .english ? "Friends only" : "Kun venner" }
    static var settingsRowBlockedUsers: String { lang == .english ? "Blocked Users" : "Blokerede brugere" }
    static var settingsRowBlockedUsersSubtitle: String { lang == .english ? "None" : "Ingen" }
    static var settingsRowDataPrivacy: String { lang == .english ? "Data & Privacy" : "Data og privatliv" }
    static var settingsRowDataPrivacySubtitle: String { lang == .english ? "Download or delete your data" : "Hent eller slet dine data" }

    // Support section
    static var settingsSectionSupport: String { lang == .english ? "Support" : "Support" }
    static var settingsRowHelpCenter: String { lang == .english ? "Help Center" : "Hjælpecenter" }
    static var settingsRowContactUs: String { lang == .english ? "Contact Us" : "Kontakt os" }
    static var settingsRowRateMoments: String { lang == .english ? "Rate Moments" : "Bedøm Moments" }

    // About section
    static var settingsSectionAbout: String { lang == .english ? "About" : "Om" }
    static var settingsRowTermsOfService: String { lang == .english ? "Terms of Service" : "Servicevilkår" }
    static var settingsRowPrivacyPolicy: String { lang == .english ? "Privacy Policy" : "Privatlivspolitik" }
    static var settingsRowVersion: String { lang == .english ? "Version" : "Version" }

    // Actions
    static var settingsSignOut: String { lang == .english ? "SIGN OUT" : "LOG UD" }
    static var settingsDeleteAccount: String { lang == .english ? "DELETE ACCOUNT" : "SLET KONTO" }

    // Sign out alert
    static var settingsSignOutAlertTitle: String { lang == .english ? "Sign Out" : "Log ud" }
    static var settingsSignOutAlertMessage: String { lang == .english ? "Are you sure you want to sign out?" : "Er du sikker på, at du vil logge ud?" }
    static var settingsSignOutConfirm: String { lang == .english ? "Sign Out" : "Log ud" }

    // Delete account alerts
    static var settingsDeleteAlertTitle: String { lang == .english ? "Delete Account" : "Slet konto" }
    static var settingsDeleteAlertMessage: String { lang == .english ? "This will permanently delete your account and all associated data. This action cannot be undone." : "Dette sletter permanent din konto og alle tilknyttede data. Denne handling kan ikke fortrydes." }
    static var settingsDeleteContinue: String { lang == .english ? "Continue" : "Fortsæt" }
    static var settingsDeleteReauthTitle: String { lang == .english ? "Confirm Password" : "Bekræft adgangskode" }
    static var settingsDeleteReauthMessage: String { lang == .english ? "Enter your password to confirm account deletion." : "Indtast din adgangskode for at bekræfte sletning af konto." }
    static var settingsDeletePasswordPlaceholder: String { lang == .english ? "Password" : "Adgangskode" }
    static var settingsDeleteForever: String { lang == .english ? "Delete Forever" : "Slet permanent" }
    static var settingsCancel: String { lang == .english ? "Cancel" : "Annuller" }

    // Settings detail pages
    static var settingsDetailProfileVisibilityTitle: String { lang == .english ? "Profile Visibility" : "Profilsynlighed" }
    static var settingsDetailProfileVisibilityEyebrow: String { lang == .english ? "Privacy" : "Privatliv" }
    static var settingsDetailProfileVisibilityHeadline: String { lang == .english ? "Control who sees your profile." : "Styr hvem der ser din profil." }
    static var settingsDetailProfileVisibilityBody: String { lang == .english ? "Your profile is currently visible to friends only. Adjust visibility when you want to be more discoverable or keep things close." : "Din profil er i øjeblikket kun synlig for venner. Juster synligheden, når du vil være mere synlig eller holde tingene tæt på." }

    static var settingsDetailBlockedUsersTitle: String { lang == .english ? "Blocked Users" : "Blokerede brugere" }
    static var settingsDetailBlockedUsersEyebrow: String { lang == .english ? "Privacy" : "Privatliv" }
    static var settingsDetailBlockedUsersHeadline: String { lang == .english ? "Review people you have blocked." : "Gennemse personer, du har blokeret." }
    static var settingsDetailBlockedUsersBody: String { lang == .english ? "Blocking removes visibility across community interactions and prevents new activity between you and those accounts." : "Blokering fjerner synlighed på tværs af fællesskabsinteraktioner og forhindrer ny aktivitet mellem dig og de konti." }

    static var settingsDetailDataPrivacyTitle: String { lang == .english ? "Data & Privacy" : "Data og privatliv" }
    static var settingsDetailDataPrivacyEyebrow: String { lang == .english ? "Privacy" : "Privatliv" }
    static var settingsDetailDataPrivacyHeadline: String { lang == .english ? "Manage the data attached to your account." : "Administrer de data, der er knyttet til din konto." }
    static var settingsDetailDataPrivacyBody: String { lang == .english ? "You can request an export of your account information or start a deletion request if you want to remove your data from Moments." : "Du kan anmode om en eksport af dine kontooplysninger eller starte en sletningsanmodning, hvis du vil fjerne dine data fra Moments." }

    static var settingsDetailTermsTitle: String { lang == .english ? "Terms of Service" : "Servicevilkår" }
    static var settingsDetailTermsEyebrow: String { lang == .english ? "About" : "Om" }
    static var settingsDetailTermsHeadline: String { lang == .english ? "Terms of use for Moments." : "Brugsvilkår for Moments." }
    static var settingsDetailTermsBody: String {
        lang == .english
        ? """
          Last updated: March 2026

          By using Moments, you agree to these terms. You must be at least 13 years old to use this app.

          You are responsible for all content you post. Do not post content that is illegal, harmful, threatening, abusive, harassing, defamatory, or otherwise objectionable.

          We reserve the right to remove content or suspend accounts that violate these terms without prior notice.

          Your content remains yours. By posting, you grant Moments a non-exclusive license to display it within the app.

          The app is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of the app.

          We may update these terms at any time. Continued use after changes constitutes acceptance.

          For questions, contact us at momentsapp1@outlook.com.
          """
        : """
          Sidst opdateret: marts 2026

          Ved at bruge Moments accepterer du disse vilkår. Du skal være mindst 13 år for at bruge denne app.

          Du er ansvarlig for alt indhold, du slår op. Slå ikke indhold op, der er ulovligt, skadeligt, truende, krænkende, chikanerende, ærekrænkende eller på anden måde stødende.

          Vi forbeholder os retten til at fjerne indhold eller suspendere konti, der overtræder disse vilkår, uden forudgående varsel.

          Dit indhold forbliver dit. Ved at slå op giver du Moments en ikke-eksklusiv licens til at vise det i appen.

          Appen leveres "som den er" uden garantier af nogen art. Vi er ikke ansvarlige for nogen skader, der opstår som følge af din brug af appen.

          Vi kan til enhver tid opdatere disse vilkår. Fortsat brug efter ændringer udgør accept.

          For spørgsmål, kontakt os på momentsapp1@outlook.com.
          """
    }

    static var settingsDetailPrivacyTitle: String { lang == .english ? "Privacy Policy" : "Privatlivspolitik" }
    static var settingsDetailPrivacyEyebrow: String { lang == .english ? "About" : "Om" }
    static var settingsDetailPrivacyHeadline: String { lang == .english ? "How we handle your information." : "Sådan håndterer vi dine oplysninger." }
    static var settingsDetailPrivacyBody: String {
        lang == .english
        ? """
          Last updated: March 2026

          Moments collects: your name, email address, profile photo, and content you post (text and images). This data is stored securely using Firebase (Google Cloud).

          We use your data solely to provide the app's functionality: authentication, profile display, and community features.

          We do not sell, share, or rent your personal data to third parties. We do not track you across other apps or websites.

          If you connect Spotify, we store an access token securely in your device's Keychain. We do not access your Spotify account data beyond playback control and playlist cover art.

          You can delete your account and all associated data at any time from Settings → Delete Account.

          We use no third-party analytics or advertising SDKs. The app does not contain ads.

          For data requests or questions, contact momentsapp1@outlook.com.
          """
        : """
          Sidst opdateret: marts 2026

          Moments indsamler: dit navn, din emailadresse, dit profilfoto og det indhold, du slår op (tekst og billeder). Disse data gemmes sikkert ved hjælp af Firebase (Google Cloud).

          Vi bruger kun dine data til at levere appens funktionalitet: godkendelse, profilvisning og fællesskabsfunktioner.

          Vi sælger, deler eller udlejer ikke dine personlige data til tredjeparter. Vi sporer dig ikke på tværs af andre apps eller hjemmesider.

          Hvis du tilslutter Spotify, gemmer vi et adgangstoken sikkert i din enheds nøglering. Vi tilgår ikke dine Spotify-kontodata ud over afspilningskontrol og spillelisteforsider.

          Du kan til enhver tid slette din konto og alle tilknyttede data fra Indstillinger → Slet konto.

          Vi bruger ingen tredjepartsanalyse- eller reklame-SDK'er. Appen indeholder ingen annoncer.

          For dataforespørgsler eller spørgsmål, kontakt momentsapp1@outlook.com.
          """
    }

    static func settingsDetailVersionBody(_ version: String) -> String {
        lang == .english
            ? "Moments \(version)\nDesigned in Copenhagen with a focus on intimate social experiences."
            : "Moments \(version)\nDesignet i København med fokus på intime sociale oplevelser."
    }

    static var settingsDetailVersionTitle: String { lang == .english ? "Version" : "Version" }
    static var settingsDetailVersionEyebrow: String { lang == .english ? "About" : "Om" }
    static var settingsDetailVersionHeadline: String { lang == .english ? "Current build" : "Aktuel version" }

    // MARK: - Change Email

    static var changeEmailEyebrow: String { lang == .english ? "ACCOUNT" : "KONTO" }
    static var changeEmailTitle: String { lang == .english ? "Change email" : "Skift email" }
    static var changeEmailSubtitle: String { lang == .english ? "A verification link will be sent to your new email address." : "Et bekræftelseslink sendes til din nye emailadresse." }
    static var changeEmailNewEmailLabel: String { lang == .english ? "NEW EMAIL" : "NY EMAIL" }
    static var changeEmailNewEmailPlaceholder: String { lang == .english ? "your@email.com" : "din@email.com" }
    static var changeEmailPasswordLabel: String { lang == .english ? "CURRENT PASSWORD" : "NUVÆRENDE ADGANGSKODE" }
    static var changeEmailPasswordPlaceholder: String { lang == .english ? "Confirm your password" : "Bekræft din adgangskode" }
    static var changeEmailCheckEmailTitle: String { lang == .english ? "Check your email" : "Tjek din email" }
    static var changeEmailUpdateButton: String { lang == .english ? "UPDATE EMAIL" : "OPDATER EMAIL" }
    static var changeEmailDone: String { lang == .english ? "DONE" : "FÆRDIG" }
    static var changeEmailNavigationTitle: String { lang == .english ? "Email" : "Email" }

    static func changeEmailSentTo(_ email: String) -> String {
        lang == .english
            ? "We've sent a verification link to \(email)"
            : "Vi har sendt et bekræftelseslink til \(email)"
    }

    // MARK: - Change Password

    static var changePasswordEyebrow: String { lang == .english ? "ACCOUNT" : "KONTO" }
    static var changePasswordTitle: String { lang == .english ? "Change password" : "Skift adgangskode" }
    static var changePasswordSubtitle: String { lang == .english ? "Choose a strong password you haven't used before." : "Vælg en stærk adgangskode, du ikke har brugt før." }
    static var changePasswordCurrentLabel: String { lang == .english ? "CURRENT PASSWORD" : "NUVÆRENDE ADGANGSKODE" }
    static var changePasswordCurrentPlaceholder: String { lang == .english ? "Enter current password" : "Indtast nuværende adgangskode" }
    static var changePasswordNewLabel: String { lang == .english ? "NEW PASSWORD" : "NY ADGANGSKODE" }
    static var changePasswordNewPlaceholder: String { lang == .english ? "At least 6 characters" : "Mindst 6 tegn" }
    static var changePasswordConfirmLabel: String { lang == .english ? "CONFIRM PASSWORD" : "BEKRÆFT ADGANGSKODE" }
    static var changePasswordConfirmPlaceholder: String { lang == .english ? "Re-enter new password" : "Gentag ny adgangskode" }
    static var changePasswordMismatch: String { lang == .english ? "Passwords don't match." : "Adgangskoderne stemmer ikke overens." }
    static var changePasswordSuccessTitle: String { lang == .english ? "Password updated" : "Adgangskode opdateret" }
    static var changePasswordSuccessSubtitle: String { lang == .english ? "Your password has been changed successfully." : "Din adgangskode er blevet ændret." }
    static var changePasswordUpdateButton: String { lang == .english ? "UPDATE PASSWORD" : "OPDATER ADGANGSKODE" }
    static var changePasswordDone: String { lang == .english ? "DONE" : "FÆRDIG" }
    static var changePasswordNavigationTitle: String { lang == .english ? "Password" : "Adgangskode" }

    // MARK: - Connected Accounts

    static var connectedAccountsEyebrow: String { lang == .english ? "ACCOUNT" : "KONTO" }
    static var connectedAccountsTitle: String { lang == .english ? "Connected Accounts" : "Tilknyttede konti" }
    static var connectedAccountsSubtitle: String { lang == .english ? "Manage linked services." : "Administrer tilknyttede tjenester." }
    static var connectedAccountsSpotify: String { "Spotify" }
    static var connectedAccountsConnected: String { lang == .english ? "Connected" : "Tilsluttet" }
    static var connectedAccountsNotConnected: String { lang == .english ? "Not connected" : "Ikke tilsluttet" }
    static var connectedAccountsDisconnect: String { lang == .english ? "DISCONNECT" : "AFBRYD" }
    static var connectedAccountsConnect: String { lang == .english ? "CONNECT" : "TILSLUT" }

    // MARK: - Create Moment

    static var createMomentStep1Title: String { lang == .english ? "What kind of evening?" : "Hvad slags aften?" }
    static var createMomentStep1Subtitle: String { lang == .english ? "Pick a vibe or start from scratch" : "Vælg en stemning eller start fra bunden" }
    static var createMomentStep2Title: String { lang == .english ? "Your evening" : "Din aften" }
    static var createMomentStep2Subtitle: String { lang == .english ? "Customize to make it yours" : "Tilpas den så den bliver din" }
    static var createMomentSectionMusic: String { lang == .english ? "MUSIC" : "MUSIK" }
    static var createMomentAddPlaylist: String { lang == .english ? "Add a playlist" : "Tilføj en spilleliste" }
    static var createMomentSectionMenu: String { lang == .english ? "MENU" : "MENU" }
    static var createMomentAddDishes: String { lang == .english ? "Add dishes" : "Tilføj retter" }
    static var createMomentSectionGames: String { lang == .english ? "GAMES" : "SPIL" }
    static var createMomentAddGames: String { lang == .english ? "Add games" : "Tilføj spil" }
    static var createMomentNameTitle: String { lang == .english ? "Give your moment a name" : "Giv dit moment et navn" }
    static var createMomentNameSubtitle: String { lang == .english ? "Something to remember the evening by" : "Noget at huske aftenen på" }
    static var createMomentNameLabel: String { lang == .english ? "NAME" : "NAVN" }
    static var createMomentNamePlaceholder: String { lang == .english ? "e.g. Friday Night Dinner" : "f.eks. Fredag ​​aftenmad" }
    static var createMomentCustomTitle: String { lang == .english ? "Custom" : "Brugerdefineret" }
    static var createMomentCustomSubtitle: String { lang == .english ? "Build your own evening" : "Byg din egen aften" }
    static var createMomentContinue: String { lang == .english ? "CONTINUE" : "FORTSÆT" }
    static var createMomentCreate: String { lang == .english ? "CREATE MOMENT" : "OPRET MOMENT" }
    static var createMomentCuratedPlaylist: String { lang == .english ? "Curated playlist" : "Udvalgt spilleliste" }

    // MARK: - Moment Templates

    static var templateClassicDinnerPartyTitle: String { lang == .english ? "The Classic Dinner Party" : "Den klassiske middagsselskab" }
    static var templateClassicDinnerPartySubtitle: String { lang == .english ? "Burrata, negronis, and conversations that matter" : "Burrata, negroni og samtaler der betyder noget" }
    static var templateGameNightTitle: String { lang == .english ? "Game Night" : "Spilleaften" }
    static var templateGameNightSubtitle: String { lang == .english ? "Energy, laughter, and a little chaos" : "Energi, latter og lidt kaos" }
    static var templateDateNightTitle: String { lang == .english ? "Date Night In" : "Dateaften hjemme" }
    static var templateDateNightSubtitle: String { lang == .english ? "Set the mood for two" : "Sæt stemningen for to" }
    static var templateSundayBrunchTitle: String { lang == .english ? "Sunday Brunch" : "Søndagsbrunch" }
    static var templateSundayBrunchSubtitle: String { lang == .english ? "Slow morning, good company" : "Langsom morgen, godt selskab" }

    // MARK: - Live Moment

    static var liveMomentLive: String { lang == .english ? "Live" : "Live" }
    static var liveMomentTonightsMenu: String { lang == .english ? "TONIGHT'S MENU" : "AFTENENS MENU" }
    static var liveMomentNowPlaying: String { lang == .english ? "NOW PLAYING" : "SPILLER NU" }
    static var liveMomentNoPlaylist: String { lang == .english ? "No playlist selected" : "Ingen spilleliste valgt" }
    static var liveMomentTapToPlay: String { lang == .english ? "Tap to play on Spotify" : "Tryk for at afspille på Spotify" }
    static var liveMomentGames: String { lang == .english ? "GAMES" : "SPIL" }
    static var liveMomentEndMoment: String { lang == .english ? "END MOMENT" : "AFSLUT MOMENT" }
    static var liveMomentEndAlertTitle: String { lang == .english ? "End this moment?" : "Afslut dette moment?" }
    static var liveMomentEndAlertConfirm: String { lang == .english ? "End Moment" : "Afslut moment" }
    static var liveMomentEndAlertCancel: String { lang == .english ? "Cancel" : "Annuller" }

    // MARK: - Notifications

    static var notificationTitle: String { "moments" }

    static var notificationMessages: [String] {
        lang == .english
        ? [
            "What made you smile today? Capture the moment.",
            "A small moment is still worth remembering.",
            "Take a breath. What stands out right now?",
            "Your day has a story — save a piece of it.",
            "Don't let this one slip by. Share a moment."
          ]
        : [
            "Hvad fik dig til at smile i dag? Fang øjeblikket.",
            "Et lille øjeblik er stadig værd at huske.",
            "Træk vejret. Hvad springer ud i dag?",
            "Din dag har en historie — gem et stykke af den.",
            "Lad ikke dette slippe forbi. Del et øjeblik."
          ]
    }

    // MARK: - Auth Errors

    static var authErrorGeneric: String { lang == .english ? "Something went wrong. Please try again." : "Noget gik galt. Prøv venligst igen." }
    static var authErrorInvalidEmail: String { lang == .english ? "That email address doesn't look right." : "Den emailadresse ser ikke rigtig ud." }
    static var authErrorWrongPassword: String { lang == .english ? "Incorrect email or password." : "Forkert email eller adgangskode." }
    static var authErrorUserNotFound: String { lang == .english ? "No account found with that email." : "Ingen konto fundet med den email." }
    static var authErrorEmailInUse: String { lang == .english ? "An account with that email already exists." : "En konto med den email eksisterer allerede." }
    static var authErrorWeakPassword: String { lang == .english ? "Password is too short — use at least 6 characters." : "Adgangskoden er for kort — brug mindst 6 tegn." }
    static var authErrorNetworkError: String { lang == .english ? "No internet connection. Check your network and try again." : "Ingen internetforbindelse. Tjek dit netværk og prøv igen." }
    static var authErrorTooManyRequests: String { lang == .english ? "Too many attempts. Wait a moment and try again." : "For mange forsøg. Vent et øjeblik og prøv igen." }
    static var authErrorUserDisabled: String { lang == .english ? "This account has been disabled." : "Denne konto er blevet deaktiveret." }
    static var authErrorRequiresRecentLogin: String { lang == .english ? "For security, please sign in again before making this change." : "Af sikkerhedsmæssige årsager skal du logge ind igen, før du foretager denne ændring." }

}
