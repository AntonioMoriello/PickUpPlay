import Foundation
import CoreLocation
import FirebaseFirestore

class GameRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "games"

    func createGame(_ game: Game) async throws {
        try db.collection(collection).document(game.id).setData(from: game)
    }

    func getGame(id: String) async throws -> Game? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try? document.data(as: Game.self)
    }

    func updateGame(id: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(id).updateData(data)
    }

    func deleteGame(id: String) async throws {
        try await db.collection(collection).document(id).delete()
    }

    func getNearbyGames(latitude: Double, longitude: Double, radiusKm: Double) async throws -> [Game] {
        let snapshot = try await db.collection(collection)
            .whereField("status", isEqualTo: GameStatus.upcoming.rawValue)
            .getDocuments()

        let searchLocation = CLLocation(latitude: latitude, longitude: longitude)
        let maxDistanceMeters = radiusKm * 1_000

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Game.self)
        }
        .filter { game in
            let gameLocation = CLLocation(
                latitude: game.location.latitude,
                longitude: game.location.longitude
            )
            return searchLocation.distance(from: gameLocation) <= maxDistanceMeters
        }
        .sorted { lhs, rhs in
            let lhsDistance = searchLocation.distance(from: CLLocation(
                latitude: lhs.location.latitude,
                longitude: lhs.location.longitude
            ))
            let rhsDistance = searchLocation.distance(from: CLLocation(
                latitude: rhs.location.latitude,
                longitude: rhs.location.longitude
            ))

            if lhsDistance == rhsDistance {
                return lhs.dateTime < rhs.dateTime
            }
            return lhsDistance < rhsDistance
        }
    }

    func getGamesForSport(sportId: String) async throws -> [Game] {
        let snapshot = try await db.collection(collection)
            .whereField("sportId", isEqualTo: sportId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Game.self)
        }
        .filter { $0.status == .upcoming }
    }

    func joinGame(gameId: String, userId: String) async throws {
        try await db.collection(collection).document(gameId).updateData([
            "playerIds": FieldValue.arrayUnion([userId])
        ])
    }

    func leaveGame(gameId: String, userId: String) async throws {
        try await db.collection(collection).document(gameId).updateData([
            "playerIds": FieldValue.arrayRemove([userId])
        ])
    }

    func getGamesOrganizedBy(userId: String) async throws -> [Game] {
        let snapshot = try await db.collection(collection)
            .whereField("organizerId", isEqualTo: userId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Game.self)
        }
        .sorted { $0.dateTime > $1.dateTime }
    }

    func getGamesForPlayer(userId: String) async throws -> [Game] {
        let snapshot = try await db.collection(collection)
            .whereField("playerIds", arrayContains: userId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Game.self)
        }
        .sorted { $0.dateTime > $1.dateTime }
    }
}
