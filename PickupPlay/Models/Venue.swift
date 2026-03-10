//
//  Venue.swift
//  PickupPlay
//
import Foundation
import FirebaseFirestore

struct Venue: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var address: String
    var coordinates: GeoPoint
    var sportTypes: [String]
    var amenities: [String]
    var photoURLs: [String]
    var rating: Double
    var reviewCount: Int
    var operatingHours: String
    var isPublic: Bool
    var isVerified: Bool

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.id == rhs.id
    }
}

extension Venue {
    static let sampleVenues: [Venue] = [
        Venue(id: "venue_1", name: "Central Park Courts", address: "123 Park Ave",
              coordinates: GeoPoint(latitude: 43.6532, longitude: -79.3832),
              sportTypes: ["basketball", "tennis", "volleyball"],
              amenities: ["Lights", "Water Fountain", "Parking", "Restrooms"],
              photoURLs: [], rating: 4.5, reviewCount: 28,
              operatingHours: "6:00 AM - 10:00 PM", isPublic: true, isVerified: true),
        Venue(id: "venue_2", name: "Riverside Athletic Fields", address: "456 River Rd",
              coordinates: GeoPoint(latitude: 43.6555, longitude: -79.3800),
              sportTypes: ["soccer", "football", "ultimate_frisbee"],
              amenities: ["Lights", "Parking", "Bleachers"],
              photoURLs: [], rating: 4.2, reviewCount: 15,
              operatingHours: "7:00 AM - 9:00 PM", isPublic: true, isVerified: true),
        Venue(id: "venue_3", name: "Community Recreation Center", address: "789 Main St",
              coordinates: GeoPoint(latitude: 43.6510, longitude: -79.3870),
              sportTypes: ["basketball", "volleyball", "badminton", "table_tennis"],
              amenities: ["Indoor", "Lights", "Water Fountain", "Parking", "Locker Rooms"],
              photoURLs: [], rating: 4.7, reviewCount: 42,
              operatingHours: "6:00 AM - 11:00 PM", isPublic: false, isVerified: true),
    ]
}
