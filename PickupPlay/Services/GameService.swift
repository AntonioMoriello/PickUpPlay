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
    private let userRepository: UserRepository
    private let chatService: ChatService
    private let notificationService: NotificationService

    init(gameRepository: GameRepository = GameRepository()) {
        self.gameRepository = gameRepository
        self.userRepository = UserRepository()
        self.chatService = ChatService()
        self.notificationService = NotificationService()
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
        let chatRoom = try await chatService.createChatRoom(
            type: .gameChat,
            participantIds: game.playerIds,
            gameId: game.id
        )
        try await gameRepository.updateGame(id: game.id, data: ["chatRoomId": chatRoom.id])
        guard let createdGame = try await gameRepository.getGame(id: game.id) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        try? await notificationService.createGameNotification(game: createdGame, forUserId: game.organizerId)
        notificationService.scheduleLocalReminder(for: createdGame, minutesBefore: 60, userId: game.organizerId)
        AppEvents.post(.chatRoomsDidChange)

        return game.id
    }

    func joinGame(gameId: String, userId: String) async throws -> Game {
        guard let existingGame = try await gameRepository.getGame(id: gameId) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        guard existingGame.status == .upcoming else {
            throw NSError(domain: "GameService", code: 400, userInfo: [NSLocalizedDescriptionKey: "This game is no longer open for joining"])
        }
        guard !existingGame.isFull else {
            throw NSError(domain: "GameService", code: 400, userInfo: [NSLocalizedDescriptionKey: "This game is already full"])
        }
        guard !existingGame.playerIds.contains(userId) else {
            return existingGame
        }

        try await gameRepository.joinGame(gameId: gameId, userId: userId)

        if !existingGame.chatRoomId.isEmpty {
            try await chatService.addParticipant(chatRoomId: existingGame.chatRoomId, userId: userId)
        }

        guard let updated = try await gameRepository.getGame(id: gameId) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        if existingGame.organizerId != userId {
            try? await notificationService.createNotification(
                userId: existingGame.organizerId,
                title: "Player Joined",
                body: "A player joined \(existingGame.title).",
                type: .playerJoined,
                referenceId: gameId
            )
        }
        notificationService.scheduleLocalReminder(for: updated, minutesBefore: 60, userId: userId)
        AppEvents.post(.chatRoomsDidChange)
        return updated
    }

    func leaveGame(gameId: String, userId: String) async throws {
        guard let existingGame = try await gameRepository.getGame(id: gameId) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        guard existingGame.organizerId != userId else {
            throw NSError(domain: "GameService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Organizers cannot leave their own game"])
        }
        guard existingGame.playerIds.contains(userId) else { return }

        try await gameRepository.leaveGame(gameId: gameId, userId: userId)

        if !existingGame.chatRoomId.isEmpty {
            try await chatService.removeParticipant(chatRoomId: existingGame.chatRoomId, userId: userId)
        }

        notificationService.cancelLocalReminder(for: gameId)
        try? await notificationService.createNotification(
            userId: existingGame.organizerId,
            title: "Player Left",
            body: "A player left \(existingGame.title).",
            type: .playerLeft,
            referenceId: gameId
        )
        AppEvents.post(.chatRoomsDidChange)
    }

    func cancelGame(gameId: String, organizerId: String) async throws -> Game {
        guard let game = try await gameRepository.getGame(id: gameId),
              game.organizerId == organizerId else {
            throw NSError(domain: "GameService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Only the organizer can cancel this game"])
        }
        try await gameRepository.updateGame(id: gameId, data: ["status": GameStatus.cancelled.rawValue])
        for participantId in game.playerIds where participantId != organizerId {
            try? await notificationService.createNotification(
                userId: participantId,
                title: "Game Cancelled",
                body: "\(game.title) has been cancelled by the organizer.",
                type: .gameCancelled,
                referenceId: game.id
            )
        }
        notificationService.cancelLocalReminder(for: game.id)
        AppEvents.post(.chatRoomsDidChange)
        guard let updatedGame = try await gameRepository.getGame(id: gameId) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        return updatedGame
    }

    func completeGame(gameId: String, organizerId: String) async throws -> Game {
        guard let game = try await gameRepository.getGame(id: gameId),
              game.organizerId == organizerId else {
            throw NSError(domain: "GameService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Only the organizer can complete this game"])
        }
        guard game.status != .cancelled else {
            throw NSError(domain: "GameService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cancelled games cannot be completed"])
        }
        guard game.status != .completed else {
            return game
        }

        let teams = game.teams.isEmpty && game.playerIds.count > 1 ? balanceTeams(game: game) : game.teams
        let teamsData = try teams.map { try Firestore.Encoder().encode($0) }

        try await gameRepository.updateGame(id: gameId, data: [
            "status": GameStatus.completed.rawValue,
            "teams": teamsData
        ])

        for playerId in Set(game.playerIds) {
            try? await userRepository.incrementGameCounts(userId: playerId, gamesPlayedDelta: 1)
            try? await userRepository.incrementSportParticipation(userId: playerId, sportId: game.sportId)
            if playerId != organizerId {
                try? await notificationService.createNotification(
                    userId: playerId,
                    title: "Game Completed",
                    body: "\(game.title) has been marked as completed.",
                    type: .gameUpdate,
                    referenceId: game.id
                )
            }
        }

        notificationService.cancelLocalReminder(for: game.id)
        guard let updatedGame = try await gameRepository.getGame(id: gameId) else {
            throw NSError(domain: "GameService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
        }
        return updatedGame
    }

    func balanceTeams(game: Game, skillLevelsByPlayerId: [String: SkillLevel] = [:]) -> [Team] {
        TeamBalancer.balanceTeams(for: game, skillLevelsByPlayerId: skillLevelsByPlayerId)
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
