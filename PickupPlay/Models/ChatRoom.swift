import Foundation

struct ChatRoom: Identifiable, Codable {
    let id: String
    var gameId: String?
    var groupId: String?
    var type: ChatRoomType
    var participantIds: [String]
    var createdAt: Date
    var updatedAt: Date
    var lastMessagePreview: String
}

extension ChatRoom {
    static func new(type: ChatRoomType, participantIds: [String], gameId: String? = nil, groupId: String? = nil) -> ChatRoom {
        ChatRoom(
            id: UUID().uuidString,
            gameId: gameId,
            groupId: groupId,
            type: type,
            participantIds: participantIds,
            createdAt: Date(),
            updatedAt: Date(),
            lastMessagePreview: ""
        )
    }
}
