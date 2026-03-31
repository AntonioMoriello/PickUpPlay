import Foundation
import CoreLocation
import MapKit
import FirebaseFirestore

class VenueService {
    private let venueRepository: VenueRepository

    init(venueRepository: VenueRepository = VenueRepository()) {
        self.venueRepository = venueRepository
    }

    func fetchNearbyVenues(location: CLLocation, radius: Double, sportFilter: String?) async throws -> [Venue] {
        let allVenues = try await venueRepository.getNearbyVenues(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radiusKm: radius
        )

        let maxDistanceMeters = radius * 1_000
        let nearbyVenues = allVenues
            .filter { venue in
                let venueLocation = CLLocation(
                    latitude: venue.coordinates.latitude,
                    longitude: venue.coordinates.longitude
                )
                return location.distance(from: venueLocation) <= maxDistanceMeters
            }
            .sorted { lhs, rhs in
                let lhsDistance = location.distance(from: CLLocation(
                    latitude: lhs.coordinates.latitude,
                    longitude: lhs.coordinates.longitude
                ))
                let rhsDistance = location.distance(from: CLLocation(
                    latitude: rhs.coordinates.latitude,
                    longitude: rhs.coordinates.longitude
                ))
                return lhsDistance < rhsDistance
            }

        if let sportFilter = sportFilter, !sportFilter.isEmpty {
            return nearbyVenues.filter { $0.sportTypes.contains(sportFilter) }
        }
        return nearbyVenues
    }

    func getVenueDetails(venueId: String) async throws -> Venue {
        guard let venue = try await venueRepository.getVenue(id: venueId) else {
            throw NSError(domain: "VenueService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Venue not found"])
        }
        return venue
    }

    func openInMaps(venue: Venue) {
        let coordinate = CLLocationCoordinate2D(
            latitude: venue.coordinates.latitude,
            longitude: venue.coordinates.longitude
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = venue.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    func recalculateRating(venueId: String) async throws -> Double {
        let reviews = try await venueRepository.getReviews(venueId: venueId)
        guard !reviews.isEmpty else { return 0.0 }
        let totalRating = reviews.reduce(0.0) { $0 + $1.rating }
        let average = totalRating / Double(reviews.count)

        try await venueRepository.updateVenue(id: venueId, data: [
            "rating": average,
            "reviewCount": reviews.count
        ])
        return average
    }
}
