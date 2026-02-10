//
//  UserRepository.swift
//  PickupPlay
//
import Foundation
import FirebaseFirestore

class UserRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "users"

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
    }

    func updateSportSkills(userId: String, sportSkills: [SportSkill]) async throws {
        let encoded = try sportSkills.map { try Firestore.Encoder().encode($0) }
        try await db.collection(collection).document(userId).updateData([
            "sportSkills": encoded
        ])
    }
}
