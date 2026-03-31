import Foundation
import Combine

struct UserPreferences: Codable, Equatable {
    var notificationPrefs: NotificationPreferences = .default
    var privacySettings: PrivacySettings = .default
    var sportPreferences: SportPreferences = .default

    static let `default` = UserPreferences()
}

struct NotificationPreferences: Codable, Equatable {
    var gameInvite: Bool = true
    var gameUpdate: Bool = true
    var gameReminder: Bool = true
    var gameCancelled: Bool = true
    var playerJoined: Bool = true
    var playerLeft: Bool = true
    var newMessage: Bool = true
    var newFollower: Bool = true
    var achievementUnlocked: Bool = true
    var ratingReceived: Bool = true
    var groupInvite: Bool = true
    var groupUpdate: Bool = true

    static let `default` = NotificationPreferences()
}

struct PrivacySettings: Codable, Equatable {
    var profileVisibility: ProfileVisibility = .everyone
    var locationSharing: Bool = true
    var showOnlineStatus: Bool = true

    enum ProfileVisibility: String, CaseIterable, Codable {
        case everyone = "Everyone"
        case followersOnly = "Followers Only"
        case nobody = "Nobody"
    }

    static let `default` = PrivacySettings()
}

struct SportPreferences: Codable, Equatable {
    var favoriteSports: [String] = []
    var skillLevels: [String: SkillLevel] = [:]

    static let `default` = SportPreferences()
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var preferences: UserPreferences = .default
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let userPrefsRepo: UserPrefsRepo
    private let authService: AuthService
    private let userRepository: UserRepository

    init() {
        self.userPrefsRepo = UserPrefsRepo()
        self.authService = AuthService()
        self.userRepository = UserRepository()
    }

    func loadPreferences(userId: String) {
        preferences = userPrefsRepo.getPreferences(userId: userId) ?? .default
    }

    func updateNotificationPrefs(_ prefs: NotificationPreferences, userId: String) {
        preferences.notificationPrefs = prefs
        userPrefsRepo.savePrefs(userId: userId, notificationPrefs: prefs)
        AppEvents.post(.notificationsDidChange)
    }

    func updatePrivacy(_ settings: PrivacySettings, userId: String) {
        preferences.privacySettings = settings
        userPrefsRepo.savePrefs(userId: userId, privacySettings: settings)
        Task {
            try? await userRepository.updateUser(id: userId, data: [
                "profileVisibility": settings.profileVisibility.rawValue,
                "locationSharingEnabled": settings.locationSharing,
                "showOnlineStatusEnabled": settings.showOnlineStatus
            ])
            AppEvents.post(.profileDidChange)
        }
    }

    func updateSportPreferences(_ prefs: SportPreferences, userId: String) {
        preferences.sportPreferences = prefs
        userPrefsRepo.savePrefs(
            userId: userId,
            sportFilter: prefs.favoriteSports.first,
            sportPreferences: prefs
        )
    }

    func logout() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
}
