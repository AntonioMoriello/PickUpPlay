import Foundation

struct Message: Identifiable, Codable {
    let id: String
    var chatRoomId: String
    var senderId: String
    var content: String
    var type: MessageType
    var timestamp: Date
    var isRead: Bool
}

extension Message {
    static func new(chatRoomId: String, senderId: String, content: String, type: MessageType = .text) -> Message {
        Message(
            id: UUID().uuidString,
            chatRoomId: chatRoomId,
            senderId: senderId,
            content: content,
            type: type,
            timestamp: Date(),
            isRead: false
        )
    }
}
