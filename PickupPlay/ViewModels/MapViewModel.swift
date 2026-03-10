//
//  MapViewModel.swift
//  PickupPlay
//
import Foundation
import MapKit
import Combine
import FirebaseFirestore

struct GameAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String
    let sportId: String
    let spotsLeft: Int
    let game: Game
}

struct VenueAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String
    let sportTypes: [String]
    let rating: Double
    let venue: Venue
}

enum MapMode: String, CaseIterable {
    case games = "Games"
    case venues = "Venues"
}

@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var gameAnnotations: [GameAnnotation] = []
    @Published var venueAnnotations: [VenueAnnotation] = []
    @Published var selectedGameAnnotation: GameAnnotation? = nil
    @Published var selectedVenueAnnotation: VenueAnnotation? = nil
    @Published var userLocation: CLLocation? = nil
    @Published var mapMode: MapMode = .games

    private let locationService: LocationService

    init() {
        self.locationService = LocationService()
    }

    func updateAnnotations(games: [Game]) {
        gameAnnotations = games.map { game in
            GameAnnotation(
                id: game.id,
                coordinate: CLLocationCoordinate2D(
                    latitude: game.location.latitude,
                    longitude: game.location.longitude
                ),
                title: game.title,
                sportId: game.sportId,
                spotsLeft: game.spotsLeft,
                game: game
            )
        }
    }

    func updateVenueAnnotations(venues: [Venue]) {
        venueAnnotations = venues.map { venue in
            VenueAnnotation(
                id: venue.id,
                coordinate: CLLocationCoordinate2D(
                    latitude: venue.coordinates.latitude,
                    longitude: venue.coordinates.longitude
                ),
                title: venue.name,
                sportTypes: venue.sportTypes,
                rating: venue.rating,
                venue: venue
            )
        }
    }

    func centerOnUser() async {
        if let location = await locationService.getCurrentLocation() {
            userLocation = location
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    func setMapMode(_ mode: MapMode) {
        mapMode = mode
    }
}
