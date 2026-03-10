//
//  VenueRepository.swift
//  PickupPlay
//
import Foundation
import FirebaseFirestore

class VenueRepository {
    private let db = FirebaseManager.shared.firestore
    private let collection = "venues"

    func getVenue(id: String) async throws -> Venue? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try? document.data(as: Venue.self)
    }

    func getNearbyVenues(latitude: Double, longitude: Double, radiusKm: Double) async throws -> [Venue] {
        let snapshot = try await db.collection(collection)
            .limit(to: 50)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Venue.self)
        }
    }

    func searchVenues(query: String) async throws -> [Venue] {
        let snapshot = try await db.collection(collection).getDocuments()
        let allVenues = snapshot.documents.compactMap { doc in
            try? doc.data(as: Venue.self)
        }
        let lowered = query.lowercased()
        return allVenues.filter {
            $0.name.lowercased().contains(lowered) || $0.address.lowercased().contains(lowered)
        }
    }

    func updateVenue(id: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(id).updateData(data)
    }

    func addReview(venueId: String, review: VenueReview) async throws {
        try db.collection(collection).document(venueId)
            .collection("reviews").document(review.id)
            .setData(from: review)
    }

    func getReviews(venueId: String) async throws -> [VenueReview] {
        let snapshot = try await db.collection(collection).document(venueId)
            .collection("reviews")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: VenueReview.self)
        }
    }

    func populateVenuesIfNeeded() async throws {
        let snapshot = try await db.collection(collection).limit(to: 1).getDocuments()
        guard snapshot.documents.isEmpty else { return }

        let batch = db.batch()
        for venue in Venue.sampleVenues {
            let ref = db.collection(collection).document(venue.id)
            try batch.setData(from: venue, forDocument: ref)
        }
        try await batch.commit()
    }
}
