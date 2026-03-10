//
//  GameHistory.swift
//  PickupPlay
//
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
    static func fromGame(_ game: Game, userId: String) -> GameHistory {
        GameHistory(
            id: UUID().uuidString,
            userId: userId,
            gameId: game.id,
            sportId: game.sportId,
            venueId: game.venueId,
            datePlayed: game.dateTime,
            attended: false,
            teamId: "",
            result: .notRecorded,
            stats: [:]
        )
    }
}
