//
//  MapView.swift
//  PickupPlay
//
import SwiftUI
import MapKit

struct GameMapView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var venueViewModel = VenueViewModel()
    @State private var selectedGame: Game? = nil
    @State private var showGameDetails = false
    @State private var showVenueDetails = false
    @State private var selectedVenueForDetails: Venue? = nil
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $mapPosition) {
                    UserAnnotation()

                    if mapViewModel.mapMode == .games {
                        ForEach(mapViewModel.gameAnnotations) { annotation in
                            Annotation(annotation.title, coordinate: annotation.coordinate) {
                                GameMapPin(
                                    annotation: annotation,
                                    isSelected: mapViewModel.selectedGameAnnotation?.id == annotation.id
                                )
                                .onTapGesture {
                                    mapViewModel.selectedGameAnnotation = annotation
                                    selectedGame = annotation.game
                                    showGameDetails = true
                                }
                            }
                        }
                    } else {
                        ForEach(mapViewModel.venueAnnotations) { annotation in
                            Annotation(annotation.title, coordinate: annotation.coordinate) {
                                VenueMapPin(
                                    annotation: annotation,
                                    isSelected: mapViewModel.selectedVenueAnnotation?.id == annotation.id
                                )
                                .onTapGesture {
                                    mapViewModel.selectedVenueAnnotation = annotation
                                    selectedVenueForDetails = annotation.venue
                                    showVenueDetails = true
                                }
                            }
                        }
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea(edges: .bottom)

                VStack {
                    Picker("Mode", selection: $mapViewModel.mapMode) {
                        ForEach(MapMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Spacer()

                    HStack {
                        Spacer()
                        Button {
                            mapPosition = .userLocation(fallback: .automatic)
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.accentCyan)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(.ultraThinMaterial))
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showGameDetails) {
                if let game = selectedGame {
                    GameDetailsView(game: game)
                }
            }
            .sheet(isPresented: $showVenueDetails) {
                if let venue = selectedVenueForDetails {
                    NavigationStack {
                        VenueDetailsView(venue: venue)
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            .onAppear {
                Task {
                    await gameViewModel.fetchNearbyGames()
                    mapViewModel.updateAnnotations(games: gameViewModel.games)
                    await venueViewModel.fetchNearbyVenues()
                    mapViewModel.updateVenueAnnotations(venues: venueViewModel.venues)
                }
            }
        }
    }
}
