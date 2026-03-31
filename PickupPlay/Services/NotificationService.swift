import Foundation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

class NotificationService {
    private let db = FirebaseManager.shared.firestore
    private let notificationRepository = NotificationRepository()
    private let userPrefsRepo = UserPrefsRepo()

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleLocalReminder(for game: Game, minutesBefore: Int, userId: String? = nil) {
        if let userId, !isNotificationEnabled(.gameReminder, userId: userId) {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Game Reminder"
        content.body = "\(game.title) starts in \(minutesBefore) minutes!"
        content.sound = .default

        let triggerDate = game.dateTime.addingTimeInterval(-Double(minutesBefore * 60))
        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "game_\(game.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelLocalReminder(for gameId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "game_\(gameId)"
        ])
    }

    func handleFCMToken(_ token: String) async {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            try await db.collection("users").document(userId).updateData([
                "fcmToken": token
            ])
        } catch {
            print("Failed to persist FCM token: \(error)")
        }
    }

    func createGameNotification(game: Game, forUserId: String) async throws {
        try await createNotification(
            userId: forUserId,
            title: "Game Created",
            body: "Your game \"\(game.title)\" has been published!",
            type: .gameUpdate,
            referenceId: game.id
        )
    }

    func createNotification(
        userId: String,
        title: String,
        body: String,
        type: NotificationType,
        referenceId: String
    ) async throws {
        guard isNotificationEnabled(type, userId: userId) else { return }

        let notification = AppNotification.new(
            userId: userId,
            title: title,
            body: body,
            type: type,
            referenceId: referenceId
        )
        try await notificationRepository.createNotification(notification)
        AppEvents.post(.notificationsDidChange)
    }

    func isNotificationEnabled(_ type: NotificationType, userId: String) -> Bool {
        guard let prefs = userPrefsRepo.getPreferences(userId: userId) else { return true }

        switch type {
        case .gameInvite:
            return prefs.notificationPrefs.gameInvite
        case .gameUpdate:
            return prefs.notificationPrefs.gameUpdate
        case .gameReminder:
            return prefs.notificationPrefs.gameReminder
        case .gameCancelled:
            return prefs.notificationPrefs.gameCancelled
        case .playerJoined:
            return prefs.notificationPrefs.playerJoined
        case .playerLeft:
            return prefs.notificationPrefs.playerLeft
        case .newMessage:
            return prefs.notificationPrefs.newMessage
        case .newFollower:
            return prefs.notificationPrefs.newFollower
        case .achievementUnlocked:
            return prefs.notificationPrefs.achievementUnlocked
        case .ratingReceived:
            return prefs.notificationPrefs.ratingReceived
        case .groupInvite:
            return prefs.notificationPrefs.groupInvite
        case .groupUpdate:
            return prefs.notificationPrefs.groupUpdate
        }
    }
}
