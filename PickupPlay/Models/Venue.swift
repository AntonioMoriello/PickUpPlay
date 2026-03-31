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
        Venue(id: "sample_mtl_plateau_courts", name: "Complexe sportif Claude-Robillard", address: "1000 Av. Emile-Journault, Montreal, QC H2M 2E7",
              coordinates: GeoPoint(latitude: 45.552868031221, longitude: -73.636467497788),
              sportTypes: ["basketball", "badminton", "tennis", "swimming"],
              amenities: ["Indoor", "Changing Rooms", "Free Parking", "Free Wi-Fi", "Running Track", "Washrooms"],
              photoURLs: [], rating: 4.8, reviewCount: 142,
              operatingHours: "Hours vary by facility schedule", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_verdun_fields", name: "Complexe sportif Marie-Victorin", address: "7000 Blvd Maurice-Duplessis, Montreal, QC H1G 0A1",
              coordinates: GeoPoint(latitude: 45.618704, longitude: -73.609297),
              sportTypes: ["soccer", "football", "badminton", "swimming"],
              amenities: ["Indoor", "Outdoor Fields", "Changing Rooms", "Parking", "Washrooms", "Bike Stand"],
              photoURLs: [], rating: 4.7, reviewCount: 96,
              operatingHours: "7:30 AM - 10:30 PM", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_mile_end_hub", name: "Complexe Multi-Sports de Laval", address: "955 Av. de Bois-de-Boulogne, Laval, QC H7N 4G1",
              coordinates: GeoPoint(latitude: 45.57392, longitude: -73.70617),
              sportTypes: ["soccer", "badminton", "pickleball", "volleyball", "ultimate_frisbee"],
              amenities: ["Indoor", "Outdoor Fields", "Parking", "Beach Volleyball", "Pickleball Courts"],
              photoURLs: [], rating: 4.6, reviewCount: 81,
              operatingHours: "8:00 AM - 11:00 PM", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_jarry_tennis", name: "Parc Jarry Tennis Courts (Stade IGA)", address: "285 Rue Gary-Carter, Montreal, QC H2R 2W1",
              coordinates: GeoPoint(latitude: 45.535073, longitude: -73.628413),
              sportTypes: ["tennis"],
              amenities: ["Changing Rooms", "Drinking Fountain", "Showers", "Snack Bar", "Washrooms", "Free Wi-Fi"],
              photoURLs: [], rating: 4.8, reviewCount: 164,
              operatingHours: "7:00 AM - 11:00 PM", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_hochelaga_rec", name: "Parc Leroux Pickleball Courts", address: "Rue Centrale and Ave. Lacharite, Montreal, QC H8P 2C1",
              coordinates: GeoPoint(latitude: 45.434220011841, longitude: -73.595187341456),
              sportTypes: ["pickleball"],
              amenities: ["Outdoor Courts", "First-Come, First-Served"],
              photoURLs: [], rating: 4.5, reviewCount: 28,
              operatingHours: "7:00 AM - 11:00 PM", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_griffintown_courts", name: "Verdun Beach Volleyball Courts", address: "7523 Blvd LaSalle, Montreal, QC H8P 1X3",
              coordinates: GeoPoint(latitude: 45.435443315255, longitude: -73.584534566842),
              sportTypes: ["volleyball"],
              amenities: ["Beach Courts", "Waterfront", "Reservable"],
              photoURLs: [], rating: 4.7, reviewCount: 54,
              operatingHours: "7:00 AM - 9:00 PM", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_parc_ex_cricket", name: "Parc Marcelin-Wilson", address: "11301 Blvd de l'Acadie, Montreal, QC H3M 2T1",
              coordinates: GeoPoint(latitude: 45.536716, longitude: -73.684912),
              sportTypes: ["soccer", "baseball", "basketball", "tennis", "swimming"],
              amenities: ["Basketball Court", "Changing Rooms", "Free Parking", "Washrooms", "Bike Stand", "Drinking Fountain"],
              photoURLs: [], rating: 4.6, reviewCount: 63,
              operatingHours: "6:00 AM - 12:00 AM", isPublic: true, isVerified: true),
        Venue(id: "sample_mtl_old_port_ice", name: "Complexe Sportif Bell", address: "8000 Blvd Leduc, Brossard, QC J4Y 0E9",
              coordinates: GeoPoint(latitude: 45.452725, longitude: -73.445191),
              sportTypes: ["hockey", "soccer"],
              amenities: ["Indoor", "Parking", "Locker Rooms", "Pro Shop", "Restaurant"],
              photoURLs: [], rating: 4.7, reviewCount: 88,
              operatingHours: "Hours vary by rink and field schedule", isPublic: false, isVerified: true),
    ]
}
