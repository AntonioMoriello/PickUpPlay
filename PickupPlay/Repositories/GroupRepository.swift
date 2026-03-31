import Foundation
import FirebaseFirestore

class GroupRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "groups"

    func createGroup(_ group: SportGroup) async throws {
        try db.collection(collection).document(group.id).setData(from: group)
    }

    func getGroup(id: String) async throws -> SportGroup? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try? document.data(as: SportGroup.self)
    }

    func getGroupsForUser(userId: String) async throws -> [SportGroup] {
        let snapshot = try await db.collection(collection)
            .whereField("memberIds", arrayContains: userId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: SportGroup.self)
        }
    }

    func getPublicGroups() async throws -> [SportGroup] {
        let snapshot = try await db.collection(collection)
            .whereField("isPublic", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: SportGroup.self)
        }
    }

    func joinGroup(groupId: String, userId: String) async throws {
        try await db.collection(collection).document(groupId).updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ])
    }

    func leaveGroup(groupId: String, userId: String) async throws {
        try await db.collection(collection).document(groupId).updateData([
            "memberIds": FieldValue.arrayRemove([userId]),
            "adminIds": FieldValue.arrayRemove([userId])
        ])
    }

    func promoteToAdmin(groupId: String, userId: String) async throws {
        try await db.collection(collection).document(groupId).updateData([
            "adminIds": FieldValue.arrayUnion([userId])
        ])
    }

    func removeMember(groupId: String, userId: String) async throws {
        try await db.collection(collection).document(groupId).updateData([
            "memberIds": FieldValue.arrayRemove([userId]),
            "adminIds": FieldValue.arrayRemove([userId])
        ])
    }

    func updateGroup(id: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(id).updateData(data)
    }
}
