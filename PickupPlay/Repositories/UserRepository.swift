import Foundation
import FirebaseFirestore

class UserRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "users"
    private let notificationService = NotificationService()

    func createUser(_ user: User) async throws {
        try db.collection(collection).document(user.id).setData(from: user)
    }

    func getUser(id: String) async throws -> User? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try document.data(as: User.self)
    }

    func updateUser(id: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(id).updateData(data)
    }

    func updateUser(_ user: User) async throws {
        try db.collection(collection).document(user.id).setData(from: user, merge: true)
    }

    func followUser(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()
        let currentUserRef = db.collection(collection).document(currentUserId)
        let targetUserRef = db.collection(collection).document(targetUserId)

        batch.updateData([
            "followingIds": FieldValue.arrayUnion([targetUserId])
        ], forDocument: currentUserRef)

        batch.updateData([
            "followerIds": FieldValue.arrayUnion([currentUserId])
        ], forDocument: targetUserRef)

        try await batch.commit()
        try? await notificationService.createNotification(
            userId: targetUserId,
            title: "New Follower",
            body: "Someone started following your profile.",
            type: .newFollower,
            referenceId: currentUserId
        )
        AppEvents.post(.profileDidChange)
    }

    func unfollowUser(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()
        let currentUserRef = db.collection(collection).document(currentUserId)
        let targetUserRef = db.collection(collection).document(targetUserId)

        batch.updateData([
            "followingIds": FieldValue.arrayRemove([targetUserId])
        ], forDocument: currentUserRef)

        batch.updateData([
            "followerIds": FieldValue.arrayRemove([currentUserId])
        ], forDocument: targetUserRef)

        try await batch.commit()
        AppEvents.post(.profileDidChange)
    }

    func updateSportSkills(userId: String, sportSkills: [SportSkill]) async throws {
        let encoded = try sportSkills.map { try Firestore.Encoder().encode($0) }
        try await db.collection(collection).document(userId).updateData([
            "sportSkills": encoded
        ])
    }

    func incrementGameCounts(userId: String, gamesPlayedDelta: Int = 0, gamesOrganizedDelta: Int = 0) async throws {
        var data: [String: Any] = [:]

        if gamesPlayedDelta != 0 {
            data["gamesPlayed"] = FieldValue.increment(Int64(gamesPlayedDelta))
        }

        if gamesOrganizedDelta != 0 {
            data["gamesOrganized"] = FieldValue.increment(Int64(gamesOrganizedDelta))
        }

        guard !data.isEmpty else { return }
        try await db.collection(collection).document(userId).updateData(data)
    }

    func incrementSportParticipation(userId: String, sportId: String) async throws {
        guard var user = try await getUser(id: userId) else { return }

        if let index = user.sportSkills.firstIndex(where: { $0.sportId == sportId }) {
            user.sportSkills[index].gamesPlayedInSport += 1
        } else {
            user.sportSkills.append(
                SportSkill(
                    sportId: sportId,
                    level: .beginner,
                    preferredPosition: "",
                    gamesPlayedInSport: 1,
                    stats: [:]
                )
            )
        }

        let encoded = try user.sportSkills.map { try Firestore.Encoder().encode($0) }
        try await db.collection(collection).document(userId).updateData([
            "sportSkills": encoded
        ])
    }
}
