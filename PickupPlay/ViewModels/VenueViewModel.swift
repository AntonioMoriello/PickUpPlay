//
//  VenueViewModel.swift
//  PickupPlay
//
import Foundation
import Combine
import CoreLocation

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

    init() {
        self.venueRepository = VenueRepository()
        self.venueService = VenueService(venueRepository: venueRepository)
        self.favoriteVenuesRepo = FavoriteVenuesRepo()
    }

    func fetchNearbyVenues(location: CLLocation? = nil, sportFilter: String? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await venueRepository.populateVenuesIfNeeded()
            let loc = location ?? CLLocation(latitude: 43.6532, longitude: -79.3832)
            venues = try await venueService.fetchNearbyVenues(location: loc, radius: 25.0, sportFilter: sportFilter)
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
}
