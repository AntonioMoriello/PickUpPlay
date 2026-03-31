import Foundation
import FirebaseFirestore

struct Game: Identifiable, Codable {
    let id: String
    var organizerId: String
    var sportId: String
    var venueId: String
    var chatRoomId: String
    var groupId: String?
    var title: String
    var description: String
    var dateTime: Date
    var maxPlayers: Int
    var skillLevel: SkillLevel
    var status: GameStatus
    var playerIds: [String]
    var teams: [Team]
    var location: GeoPoint
    var createdAt: Date

    var currentPlayers: Int { playerIds.count }
    var isFull: Bool { currentPlayers >= maxPlayers }
    var spotsLeft: Int { max(0, maxPlayers - currentPlayers) }
}

extension Game {
    static func new(
        organizerId: String,
        sportId: String,
        venueId: String,
        title: String,
        description: String,
        dateTime: Date,
        maxPlayers: Int,
        skillLevel: SkillLevel,
        location: GeoPoint
    ) -> Game {
        Game(
            id: UUID().uuidString,
            organizerId: organizerId,
            sportId: sportId,
            venueId: venueId,
            chatRoomId: "",
            groupId: nil,
            title: title,
            description: description,
            dateTime: dateTime,
            maxPlayers: maxPlayers,
            skillLevel: skillLevel,
            status: .upcoming,
            playerIds: [organizerId],
            teams: [],
            location: location,
            createdAt: Date()
        )
    }
}
