import Foundation
import FirebaseFirestore

class PlayerRatingRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "ratings"
    private let userRepository = UserRepository()

    func submitRating(_ rating: PlayerRating) async throws {
        try db.collection(collection).document(rating.id).setData(from: rating)
    }

    func getRatingsForUser(userId: String) async throws -> [PlayerRating] {
        let snapshot = try await db.collection(collection)
            .whereField("ratedUserId", isEqualTo: userId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: PlayerRating.self)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    func getRatingsForGame(gameId: String) async throws -> [PlayerRating] {
        let snapshot = try await db.collection(collection)
            .whereField("gameId", isEqualTo: gameId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: PlayerRating.self)
        }
    }

    func hasRated(raterId: String, ratedUserId: String, gameId: String) async throws -> Bool {
        let snapshot = try await db.collection(collection)
            .whereField("raterId", isEqualTo: raterId)
            .whereField("ratedUserId", isEqualTo: ratedUserId)
            .whereField("gameId", isEqualTo: gameId)
            .limit(to: 1)
            .getDocuments()

        return !snapshot.documents.isEmpty
    }

    func averageRating(for userId: String) async throws -> Double {
        let ratings = try await getRatingsForUser(userId: userId)
        guard !ratings.isEmpty else { return 5.0 }

        let total = ratings.reduce(0.0) { partialResult, rating in
            partialResult + ((rating.skillRating + rating.sportsmanshipRating) / 2.0)
        }
        return total / Double(ratings.count)
    }

    func refreshReliabilityScore(for userId: String) async throws -> Double {
        let average = try await averageRating(for: userId)
        try await userRepository.updateUser(id: userId, data: [
            "reliabilityScore": average
        ])
        AppEvents.post(.profileDidChange)
        return average
    }
}
