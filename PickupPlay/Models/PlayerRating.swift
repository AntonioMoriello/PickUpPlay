import Foundation

struct PlayerRating: Identifiable, Codable {
    let id: String
    var raterId: String
    var ratedUserId: String
    var gameId: String
    var sportId: String
    var skillRating: Double
    var sportsmanshipRating: Double
    var comment: String
    var createdAt: Date
}

extension PlayerRating {
    static func new(raterId: String, ratedUserId: String, gameId: String, sportId: String, skillRating: Double, sportsmanshipRating: Double, comment: String) -> PlayerRating {
        PlayerRating(
            id: UUID().uuidString,
            raterId: raterId,
            ratedUserId: ratedUserId,
            gameId: gameId,
            sportId: sportId,
            skillRating: skillRating,
            sportsmanshipRating: sportsmanshipRating,
            comment: comment,
            createdAt: Date()
        )
    }
}
