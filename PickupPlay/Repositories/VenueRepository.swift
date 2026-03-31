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
        let sampleVenueIDs = Venue.sampleVenues.map(\.id)
        let snapshot = try await db.collection(collection)
            .whereField(FieldPath.documentID(), in: sampleVenueIDs)
            .getDocuments()

        let batch = db.batch()
        var hasWrites = false
        let existingVenues: [String: Venue] = Dictionary(uniqueKeysWithValues: snapshot.documents.compactMap { document in
            guard let venue = try? document.data(as: Venue.self) else { return nil }
            return (venue.id, venue)
        })

        for venue in Venue.sampleVenues {
            let ref = db.collection(collection).document(venue.id)
            if let existing = existingVenues[venue.id] {
                guard needsSampleVenueSync(existing: existing, sample: venue) else { continue }
                batch.setData(sampleVenueMetadata(for: venue), forDocument: ref, merge: true)
            } else {
                try batch.setData(from: venue, forDocument: ref)
            }
            hasWrites = true
        }

        guard hasWrites else { return }
        try await batch.commit()
    }

    private func sampleVenueMetadata(for venue: Venue) -> [String: Any] {
        [
            "name": venue.name,
            "address": venue.address,
            "coordinates": venue.coordinates,
            "sportTypes": venue.sportTypes,
            "amenities": venue.amenities,
            "photoURLs": venue.photoURLs,
            "operatingHours": venue.operatingHours,
            "isPublic": venue.isPublic,
            "isVerified": venue.isVerified
        ]
    }

    private func needsSampleVenueSync(existing: Venue, sample: Venue) -> Bool {
        existing.name != sample.name ||
        existing.address != sample.address ||
        existing.coordinates.latitude != sample.coordinates.latitude ||
        existing.coordinates.longitude != sample.coordinates.longitude ||
        existing.sportTypes != sample.sportTypes ||
        existing.amenities != sample.amenities ||
        existing.photoURLs != sample.photoURLs ||
        existing.operatingHours != sample.operatingHours ||
        existing.isPublic != sample.isPublic ||
        existing.isVerified != sample.isVerified
    }
}
