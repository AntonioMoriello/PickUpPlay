import Foundation

struct Team: Identifiable, Codable {
    let id: String
    var gameId: String
    var name: String
    var playerIds: [String]
    var score: Int
}

extension Team {
    static func new(gameId: String, name: String) -> Team {
        Team(
            id: UUID().uuidString,
            gameId: gameId,
            name: name,
            playerIds: [],
            score: 0
        )
    }
}
