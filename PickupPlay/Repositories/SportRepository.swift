//
//  SportRepository.swift
//  PickupPlay
//
import Foundation
import FirebaseFirestore

class SportRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "sports"

    func getAllSports() async throws -> [Sport] {
        let snapshot = try await db.collection(collection).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Sport.self)
        }
    }

    func getSport(id: String) async throws -> Sport? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try document.data(as: Sport.self)
    }

    func getSportsByCategory(_ category: SportCategory) async throws -> [Sport] {
        let snapshot = try await db.collection(collection)
            .whereField("category", isEqualTo: category.rawValue)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Sport.self)
        }
    }

    func populateSportsIfNeeded() async throws {
        let snapshot = try await db.collection(collection).limit(to: 1).getDocuments()
        guard snapshot.documents.isEmpty else { return }

        let batch = db.batch()
        for sport in Sport.allSports {
            let ref = db.collection(collection).document(sport.id)
            try batch.setData(from: sport, forDocument: ref)
        }
        try await batch.commit()
    }
}
