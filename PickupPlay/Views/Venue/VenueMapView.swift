import SwiftUI
import MapKit

struct VenueMapView: View {
    @StateObject private var venueViewModel = VenueViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @State private var selectedVenue: Venue? = nil
    @State private var showVenueDetails = false
    @State private var sportFilter: String? = nil
    @State private var mapPosition: MapCameraPosition = .region(AppLocationDefaults.defaultRegion)

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $mapPosition) {
                UserAnnotation()

                ForEach(mapViewModel.venueAnnotations) { annotation in
                    Annotation(annotation.title, coordinate: annotation.coordinate) {
                        VenueMapPin(
                            annotation: annotation,
                            isSelected: mapViewModel.selectedVenueAnnotation?.id == annotation.id
                        )
                        .onTapGesture {
                            mapViewModel.selectedVenueAnnotation = annotation
                            selectedVenue = annotation.venue
                            showVenueDetails = true
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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All Venues",
                            isSelected: sportFilter == nil
                        ) {
                            sportFilter = nil
                            Task { await loadVenues() }
                        }

                        ForEach(Sport.allSports) { sport in
                            FilterChip(
                                title: sport.name,
                                icon: sport.iconName,
                                isSelected: sportFilter == sport.id
                            ) {
                                sportFilter = sport.id
                                Task { await loadVenues() }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
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
        .navigationTitle("Venues")
        .navigationBarTitleDisplayMode(.inline)
        .errorBanner(message: $venueViewModel.errorMessage)
        .sheet(isPresented: $showVenueDetails) {
            if let venue = selectedVenue {
                NavigationStack {
                    VenueDetailsView(venue: venue)
                }
                .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            Task { await loadVenues() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .venuesDidChange)) { _ in
            Task { await loadVenues() }
        }
    }

    private func loadVenues() async {
        await venueViewModel.fetchNearbyVenues(sportFilter: sportFilter)
        mapViewModel.updateVenueAnnotations(venues: venueViewModel.venues)
    }
}
