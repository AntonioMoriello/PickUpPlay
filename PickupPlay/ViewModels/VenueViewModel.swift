import Foundation
import Combine
import CoreLocation
import FirebaseAuth

@MainActor
class VenueViewModel: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var selectedVenue: Venue? = nil
    @Published var reviews: [VenueReview] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let venueRepository: VenueRepository
    private let venueService: VenueService
    private let favoriteVenuesRepo: FavoriteVenuesRepo
    private let locationService: LocationService
    private let userPrefsRepo: UserPrefsRepo

    init() {
        self.venueRepository = VenueRepository()
        self.venueService = VenueService(venueRepository: venueRepository)
        self.favoriteVenuesRepo = FavoriteVenuesRepo()
        self.locationService = LocationService()
        self.userPrefsRepo = UserPrefsRepo()
    }

    func fetchNearbyVenues(location: CLLocation? = nil, sportFilter: String? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await venueRepository.populateVenuesIfNeeded()
            let sharingDisabled: Bool
            if let currentUserId = FirebaseManager.shared.auth.currentUser?.uid,
               let prefs = userPrefsRepo.getPreferences(userId: currentUserId) {
                sharingDisabled = !prefs.privacySettings.locationSharing
            } else {
                sharingDisabled = false
            }
            let deviceLocation = sharingDisabled ? nil : await locationService.getCurrentLocation()
            let resolvedLocation = location ?? deviceLocation ?? AppLocationDefaults.defaultLocation
            var nearbyVenues = try await venueService.fetchNearbyVenues(
                location: resolvedLocation,
                radius: 25.0,
                sportFilter: sportFilter
            )

            if nearbyVenues.isEmpty,
               shouldFallbackToDemoArea(from: resolvedLocation, requestedLocation: location) {
                nearbyVenues = try await venueService.fetchNearbyVenues(
                    location: AppLocationDefaults.defaultLocation,
                    radius: 25.0,
                    sportFilter: sportFilter
                )
            }

            venues = nearbyVenues
        } catch {
            self.errorMessage = "Failed to fetch venues: \(error.localizedDescription)"
        }
    }

    func getDetails(venueId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            selectedVenue = try await venueService.getVenueDetails(venueId: venueId)
        } catch {
            self.errorMessage = "Failed to load venue: \(error.localizedDescription)"
        }
    }

    func fetchReviews(venueId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            reviews = try await venueRepository.getReviews(venueId: venueId)
        } catch {
            self.errorMessage = "Failed to load reviews: \(error.localizedDescription)"
        }
    }

    func submitReview(_ review: VenueReview) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await venueRepository.addReview(venueId: review.venueId, review: review)
            _ = try await venueService.recalculateRating(venueId: review.venueId)
            await fetchReviews(venueId: review.venueId)
            await getDetails(venueId: review.venueId)
            AppEvents.post(.venuesDidChange)
        } catch {
            self.errorMessage = "Failed to submit review: \(error.localizedDescription)"
        }
    }

    func toggleFavorite(venue: Venue) {
        if favoriteVenuesRepo.isFavorite(venueId: venue.id) {
            favoriteVenuesRepo.removeFavorite(venueId: venue.id)
        } else {
            favoriteVenuesRepo.addFavorite(venueId: venue.id, venueName: venue.name)
        }
        objectWillChange.send()
    }

    func isFavorite(venueId: String) -> Bool {
        favoriteVenuesRepo.isFavorite(venueId: venueId)
    }

    func openDirections(venue: Venue) {
        venueService.openInMaps(venue: venue)
    }

    func getSavedVenues() -> [(venueId: String, venueName: String, savedAt: Date)] {
        favoriteVenuesRepo.getFavorites()
    }

    private func shouldFallbackToDemoArea(from resolvedLocation: CLLocation, requestedLocation: CLLocation?) -> Bool {
        requestedLocation == nil &&
        resolvedLocation.distance(from: AppLocationDefaults.defaultLocation) > 1_000
    }
}
