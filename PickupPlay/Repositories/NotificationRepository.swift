import Foundation
import FirebaseFirestore

class NotificationRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "notifications"

    func getNotifications(userId: String) async throws -> [AppNotification] {
        let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .limit(to: 50)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: AppNotification.self)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    func markAsRead(notificationId: String) async throws {
        try await db.collection(collection).document(notificationId).updateData([
            "isRead": true
        ])
        AppEvents.post(.notificationsDidChange)
    }

    func createNotification(_ notification: AppNotification) async throws {
        try db.collection(collection).document(notification.id).setData(from: notification)
        AppEvents.post(.notificationsDidChange)
    }

    func deleteNotification(id: String) async throws {
        try await db.collection(collection).document(id).delete()
        AppEvents.post(.notificationsDidChange)
    }

    func markAllAsRead(userId: String) async throws {
        let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()

        let batch = db.batch()
        for doc in snapshot.documents {
            batch.updateData(["isRead": true], forDocument: doc.reference)
        }
        try await batch.commit()
        AppEvents.post(.notificationsDidChange)
    }
}
