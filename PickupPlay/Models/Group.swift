import Foundation
import FirebaseFirestore

struct SportGroup: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var imageURL: String
    var creatorId: String
    var chatRoomId: String
    var adminIds: [String]
    var memberIds: [String]
    var sportIds: [String]
    var location: GeoPoint
    var isPublic: Bool
    var createdAt: Date

    var memberCount: Int { memberIds.count }
}

extension SportGroup {
    static func new(name: String, description: String, creatorId: String, sportIds: [String], isPublic: Bool, location: GeoPoint) -> SportGroup {
        SportGroup(
            id: UUID().uuidString,
            name: name,
            description: description,
            imageURL: "",
            creatorId: creatorId,
            chatRoomId: "",
            adminIds: [creatorId],
            memberIds: [creatorId],
            sportIds: sportIds,
            location: location,
            isPublic: isPublic,
            createdAt: Date()
        )
    }
}
