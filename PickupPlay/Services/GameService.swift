//
//  GameService.swift
//  PickupPlay
//
import Foundation
import FirebaseFirestore

struct ValidationError: Identifiable {
    let id = UUID()
    let message: String
}

struct GameFormData {
    var title: String = ""
    var description: String = ""
    var sportId: String = ""
    var dateTime: Date = Date().addingTimeInterval(3600)
    var maxPlayers: Int = 10
    var skillLevel: SkillLevel = .beginner
    var venueId: String = ""
}

struct GameFilterOptions {
    var sportId: String?
    var skillLevel: SkillLevel?
    var maxDistance: Double = 25.0
    var dateRange: DateRange = .any

    enum DateRange: String, CaseIterable {
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case any = "Any Time"
    }

    static let `default` = GameFilterOptions()
}

class GameService {
    private let gameRepository: GameRepository
    private let db = FirebaseManager.shared.firestore

    init(gameRepository: GameRepository = GameRepository()) {
        self.gameRepository = gameRepository
    }

    func validateGame(_ game: Game) -> [ValidationError] {
        var errors: [ValidationError] = []
        if game.title.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(ValidationError(message: "Game title is required"))
        }
        if game.sportId.isEmpty {
            errors.append(ValidationError(message: "Please select a sport"))
        }
        if game.venueId.isEmpty {
            errors.append(ValidationError(message: "Please select a venue"))
        }
        if game.dateTime < Date() {
            errors.append(ValidationError(message: "Game date must be in the future"))
        }
        if game.maxPlayers < 2 {
            errors.append(ValidationError(message: "Game needs at least 2 players"))
        }
        return errors
    }

    func checkAvailability(gameId: String) async -> Bool {
        do {
            if let game = try await gameRepository.getGame(id: gameId) {
                return !game.isFull && game.status == .upcoming
            }
        } catch {
            print("Error checking availability: \(error)")
        }
        return false
    }

    func buildGameObject(from formData: GameFormData, userId: String, location: GeoPoint) -> Game {
        Game.new(
            organizerId: userId,
            sportId: formData.sportId,
            venueId: formData.venueId,
            title: formData.title,
            description: formData.description,
            dateTime: formData.dateTime,
            maxPlayers: formData.maxPlayers,
            skillLevel: formData.skillLevel,
            location: location
        )
    }

    func createGame(_ game: Game) async throws -> String {
        try await gameRepository.createGame(game)

        let chatRoomData: [String: Any] = [
            "id": UUID().uuidString,
            "gameId": game.id,
            "type": "GAME_CHAT",
            "participantIds": game.playerIds,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date()),
            "lastMessagePreview": "Game chat created"
        ]

        let chatRoomId = chatRoomData["id"] as! String
        try await db.collection("chatRooms").document(chatRoomId).setData(chatRoomData)
        try await gameRepository.updateGame(id: game.id, data: ["chatRoomId": chatRoomId])

        return game.id
    }

    func joinGame(gameId: String, userId: String) async throws -> Game {
        try await gameRepository.joinGame(gameId: gameId, userId: userId)
        guard let updated = try await gameRepository.getGame(id: gameId) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        return updated
    }

    func leaveGame(gameId: String, userId: String) async throws {
        try await gameRepository.leaveGame(gameId: gameId, userId: userId)
    }

    func cancelGame(gameId: String, organizerId: String) async throws {
        guard let game = try await gameRepository.getGame(id: gameId),
              game.organizerId == organizerId else {
            throw NSError(domain: "GameService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Only the organizer can cancel this game"])
        }
        try await gameRepository.updateGame(id: gameId, data: ["status": GameStatus.cancelled.rawValue])
    }

    func balanceTeams(game: Game) -> [Team] {
        let players = game.playerIds
        let halfCount = players.count / 2

        var teamA = Team.new(gameId: game.id, name: "Team A")
        var teamB = Team.new(gameId: game.id, name: "Team B")

        for (index, playerId) in players.enumerated() {
            if index < halfCount {
                teamA.playerIds.append(playerId)
            } else {
                teamB.playerIds.append(playerId)
            }
        }

        return [teamA, teamB]
    }

    func addPlayerToTeam(gameId: String, teamId: String, userId: String) async throws {
        guard var game = try await gameRepository.getGame(id: gameId) else { return }
        if let teamIndex = game.teams.firstIndex(where: { $0.id == teamId }) {
            game.teams[teamIndex].playerIds.append(userId)
            let teamsData = try game.teams.map { try Firestore.Encoder().encode($0) }
            try await gameRepository.updateGame(id: gameId, data: ["teams": teamsData])
        }
    }

    func removePlayerFromTeam(gameId: String, teamId: String, userId: String) async throws {
        guard var game = try await gameRepository.getGame(id: gameId) else { return }
        if let teamIndex = game.teams.firstIndex(where: { $0.id == teamId }) {
            game.teams[teamIndex].playerIds.removeAll { $0 == userId }
            let teamsData = try game.teams.map { try Firestore.Encoder().encode($0) }
            try await gameRepository.updateGame(id: gameId, data: ["teams": teamsData])
        }
    }
}
