import SwiftUI
import FirebaseFirestore

struct SavedVenuesView: View {
    @StateObject private var venueViewModel = VenueViewModel()
    @State private var savedVenues: [(venueId: String, venueName: String, savedAt: Date)] = []
    @State private var selectedVenue: Venue? = nil
    @State private var showVenueDetails = false

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if savedVenues.isEmpty {
                EmptyStateView(
                    icon: "heart.slash",
                    title: "No Saved Venues",
                    message: "Save your favorite venues to quickly find them later."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(savedVenues, id: \.venueId) { saved in
                            SavedVenueRow(venueName: saved.venueName, savedAt: saved.savedAt) {
                                Task {
                                    await venueViewModel.getDetails(venueId: saved.venueId)
                                    if let venue = venueViewModel.selectedVenue {
                                        selectedVenue = venue
                                        showVenueDetails = true
                                    }
                                }
                            } onRemove: {
                                venueViewModel.toggleFavorite(venue: Venue(
                                    id: saved.venueId, name: saved.venueName, address: "",
                                    coordinates: .init(latitude: 0, longitude: 0),
                                    sportTypes: [], amenities: [], photoURLs: [],
                                    rating: 0, reviewCount: 0, operatingHours: "",
                                    isPublic: true, isVerified: false
                                ))
                                loadSaved()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Saved Venues")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVenueDetails) {
            if let venue = selectedVenue {
                NavigationStack {
                    VenueDetailsView(venue: venue)
                }
            }
        }
        .onAppear { loadSaved() }
    }

    private func loadSaved() {
        savedVenues = venueViewModel.getSavedVenues()
    }
}

struct SavedVenueRow: View {
    let venueName: String
    let savedAt: Date
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.accentCyan.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppTheme.gradient)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(venueName)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                    Text("Saved \(savedAt, style: .relative) ago")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.accentRose)
                }
            }
            .padding(16)
            .glassCard(padding: 0)
        }
        .buttonStyle(.plain)
    }
}
