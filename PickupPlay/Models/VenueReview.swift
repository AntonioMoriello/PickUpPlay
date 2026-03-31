import Foundation

struct VenueReview: Identifiable, Codable {
    let id: String
    var venueId: String
    var userId: String
    var rating: Double
    var comment: String
    var photoURLs: [String]
    var createdAt: Date
    var helpfulCount: Int
}

extension VenueReview {
    static func new(venueId: String, userId: String, rating: Double, comment: String) -> VenueReview {
        VenueReview(
            id: UUID().uuidString,
            venueId: venueId,
            userId: userId,
            rating: rating,
            comment: comment,
            photoURLs: [],
            createdAt: Date(),
            helpfulCount: 0
        )
    }
}
