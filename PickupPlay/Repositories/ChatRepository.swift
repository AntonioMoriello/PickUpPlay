import Foundation
import FirebaseFirestore

class ChatRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "chatRooms"

    func getChatRoom(id: String) async throws -> ChatRoom? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try? document.data(as: ChatRoom.self)
    }

    func getChatRoomsForUser(userId: String) async throws -> [ChatRoom] {
        let snapshot = try await db.collection(collection)
            .whereField("participantIds", arrayContains: userId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ChatRoom.self)
        }
        .sorted { $0.updatedAt > $1.updatedAt }
    }

    func getMessages(chatRoomId: String) async throws -> [Message] {
        let snapshot = try await db.collection(collection).document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .limit(to: 100)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Message.self)
        }
    }

    func createChatRoom(_ chatRoom: ChatRoom) async throws {
        try db.collection(collection).document(chatRoom.id).setData(from: chatRoom)
    }

    func addParticipant(chatRoomId: String, userId: String) async throws {
        try await db.collection(collection).document(chatRoomId).updateData([
            "participantIds": FieldValue.arrayUnion([userId])
        ])
    }

    func removeParticipant(chatRoomId: String, userId: String) async throws {
        try await db.collection(collection).document(chatRoomId).updateData([
            "participantIds": FieldValue.arrayRemove([userId])
        ])
    }

    func markAsRead(chatRoomId: String, messageId: String) async throws {
        try await db.collection(collection).document(chatRoomId)
            .collection("messages").document(messageId)
            .updateData(["isRead": true])
    }
}
