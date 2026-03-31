import Foundation

enum TeamBalancer {
    static func balanceTeams(for game: Game, skillLevelsByPlayerId: [String: SkillLevel] = [:]) -> [Team] {
        let players = game.playerIds.sorted { lhs, rhs in
            let lhsScore = skillWeight(for: skillLevelsByPlayerId[lhs])
            let rhsScore = skillWeight(for: skillLevelsByPlayerId[rhs])
            if lhsScore == rhsScore {
                return lhs < rhs
            }
            return lhsScore > rhsScore
        }

        var teams = game.teams.isEmpty
            ? [Team.new(gameId: game.id, name: "Team A"), Team.new(gameId: game.id, name: "Team B")]
            : game.teams.map { team in
                Team(id: team.id, gameId: team.gameId, name: team.name, playerIds: [], score: team.score)
            }
        var teamScores = Array(repeating: 0, count: teams.count)

        for playerId in players {
            let nextIndex = (0..<teams.count).min { lhs, rhs in
                let lhsTuple = (teamScores[lhs], teams[lhs].playerIds.count)
                let rhsTuple = (teamScores[rhs], teams[rhs].playerIds.count)
                return lhsTuple < rhsTuple
            } ?? 0

            teams[nextIndex].playerIds.append(playerId)
            teamScores[nextIndex] += skillWeight(for: skillLevelsByPlayerId[playerId])
        }

        return teams
    }

    private static func skillWeight(for level: SkillLevel?) -> Int {
        switch level {
        case .beginner:
            return 1
        case .intermediate:
            return 2
        case .advanced:
            return 3
        case .expert:
            return 4
        case .none:
            return 2
        }
    }
}
