import Foundation

struct AppNotification: Identifiable, Codable {
    let id: String
    var userId: String
    var title: String
    var body: String
    var type: NotificationType
    var referenceId: String
    var isRead: Bool
    var createdAt: Date
}

extension AppNotification {
    static func new(userId: String, title: String, body: String, type: NotificationType, referenceId: String) -> AppNotification {
        AppNotification(
            id: UUID().uuidString,
            userId: userId,
            title: title,
            body: body,
            type: type,
            referenceId: referenceId,
            isRead: false,
            createdAt: Date()
        )
    }
}
