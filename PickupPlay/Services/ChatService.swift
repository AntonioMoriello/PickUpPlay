import Foundation
import FirebaseFirestore

class ChatService {
    private let db = FirebaseManager.shared.firestore
    private let notificationService = NotificationService()

    func observeMessages(chatRoomId: String, handler: @escaping ([Message]) -> Void) -> ListenerRegistration {
        db.collection("chatRooms").document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
                handler(messages)
            }
    }

    func sendMessage(_ message: Message) async throws {
        try db.collection("chatRooms").document(message.chatRoomId)
            .collection("messages").document(message.id)
            .setData(from: message)

        try await db.collection("chatRooms").document(message.chatRoomId).updateData([
            "lastMessagePreview": message.content,
            "updatedAt": Timestamp(date: Date())
        ])

        if let chatRoom = try await ChatRepository().getChatRoom(id: message.chatRoomId) {
            for participantId in chatRoom.participantIds where participantId != message.senderId {
                try? await notificationService.createNotification(
                    userId: participantId,
                    title: "New Message",
                    body: message.content,
                    type: .newMessage,
                    referenceId: message.chatRoomId
                )
            }
        }

        AppEvents.post(.chatRoomsDidChange)
    }

    func addParticipant(chatRoomId: String, userId: String) async throws {
        try await db.collection("chatRooms").document(chatRoomId).updateData([
            "participantIds": FieldValue.arrayUnion([userId]),
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func removeParticipant(chatRoomId: String, userId: String) async throws {
        try await db.collection("chatRooms").document(chatRoomId).updateData([
            "participantIds": FieldValue.arrayRemove([userId]),
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func createChatRoom(type: ChatRoomType, participantIds: [String], gameId: String? = nil, groupId: String? = nil) async throws -> ChatRoom {
        let chatRoom = ChatRoom.new(type: type, participantIds: participantIds, gameId: gameId, groupId: groupId)
        try db.collection("chatRooms").document(chatRoom.id).setData(from: chatRoom)
        AppEvents.post(.chatRoomsDidChange)
        return chatRoom
    }
}
