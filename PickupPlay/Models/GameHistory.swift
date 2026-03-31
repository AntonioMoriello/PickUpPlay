import Foundation

struct GameHistory: Identifiable, Codable {
    let id: String
    var userId: String
    var gameId: String
    var sportId: String
    var venueId: String
    var datePlayed: Date
    var attended: Bool
    var teamId: String
    var result: GameResult
    var stats: [String: Int]
}

extension GameHistory {
    static func completedHistories(from game: Game) -> [GameHistory] {
        let indexedTeams = Dictionary(uniqueKeysWithValues: game.teams.map { ($0.id, $0) })

        return game.playerIds.map { playerId in
            let team = game.teams.first(where: { $0.playerIds.contains(playerId) })
            let result = resolveResult(for: team, allTeams: indexedTeams)

            return GameHistory(
                id: "\(game.id)_\(playerId)",
                userId: playerId,
                gameId: game.id,
                sportId: game.sportId,
                venueId: game.venueId,
                datePlayed: game.dateTime,
                attended: true,
                teamId: team?.id ?? "",
                result: result,
                stats: [:]
            )
        }
    }

    private static func resolveResult(for team: Team?, allTeams: [String: Team]) -> GameResult {
        guard let team else { return .notRecorded }

        let highestScore = allTeams.values.map(\.score).max() ?? 0
        let lowestScore = allTeams.values.map(\.score).min() ?? 0

        guard highestScore != lowestScore else {
            return highestScore == 0 ? .notRecorded : .draw
        }

        return team.score == highestScore ? .win : .loss
    }
}
