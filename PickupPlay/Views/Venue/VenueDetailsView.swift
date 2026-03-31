import SwiftUI
import MapKit
import FirebaseFirestore

struct VenueDetailsView: View {
    let venue: Venue
    @StateObject private var venueViewModel = VenueViewModel()
    @State private var showReviews = false

    private var venueCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: venue.coordinates.latitude, longitude: venue.coordinates.longitude)
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: venueCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))) {
                        Marker(venue.name, coordinate: venueCoordinate)
                            .tint(AppTheme.accentCyan)
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(venue.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                Text(venue.address)
                                    .font(.subheadline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()

                            Button {
                                venueViewModel.toggleFavorite(venue: venue)
                            } label: {
                                Image(systemName: venueViewModel.isFavorite(venueId: venue.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(venueViewModel.isFavorite(venueId: venue.id) ? AppTheme.accentRose : .secondary)
                            }
                        }

                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppTheme.accentAmber)
                                Text(String(format: "%.1f", venue.rating))
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                Text("(\(venue.reviewCount) reviews)")
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)

                            if venue.isVerified {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(AppTheme.accentGreen)
                                    Text("Verified")
                                        .fontDesign(.rounded)
                                        .foregroundColor(AppTheme.accentGreen)
                                }
                                .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                            .fontDesign(.rounded)

                        InfoRow(icon: "clock.fill", label: "Hours", value: venue.operatingHours)
                        Divider()
                        InfoRow(icon: "lock.open.fill", label: "Access", value: venue.isPublic ? "Public" : "Private")
                    }
                    .padding(20)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Amenities")
                            .font(.headline)
                            .fontDesign(.rounded)

                        FlowLayout(spacing: 8) {
                            ForEach(venue.amenities, id: \.self) { amenity in
                                HStack(spacing: 4) {
                                    Image(systemName: amenityIcon(amenity))
                                        .font(.caption2)
                                    Text(amenity)
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(AppTheme.accentGreen.opacity(0.1)))
                                .foregroundColor(AppTheme.accentGreen)
                            }
                        }
                    }
                    .padding(20)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sports Available")
                            .font(.headline)
                            .fontDesign(.rounded)

                        FlowLayout(spacing: 8) {
                            ForEach(venue.sportTypes, id: \.self) { sportId in
                                let sport = Sport.allSports.first(where: { $0.id == sportId })
                                HStack(spacing: 4) {
                                    Image(systemName: sport?.iconName ?? "sportscourt.fill")
                                        .font(.caption2)
                                    Text(sport?.name ?? sportId.capitalized)
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(AppTheme.accentCyan.opacity(0.1)))
                                .foregroundColor(AppTheme.accentCyan)
                            }
                        }
                    }
                    .padding(20)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        Button {
                            venueViewModel.openDirections(venue: venue)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("Get Directions")
                            }
                        }
                        .buttonStyle(AppPrimaryButtonStyle())

                        Button {
                            showReviews = true
                        } label: {
                            HStack {
                                Image(systemName: "star.bubble")
                                Text("Reviews")
                            }
                        }
                        .buttonStyle(AppSecondaryButtonStyle())
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Venue Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showReviews) {
            VenueReviewsView(venue: venue)
        }
    }

    private func amenityIcon(_ amenity: String) -> String {
        switch amenity.lowercased() {
        case "lights": return "lightbulb.fill"
        case "water fountain", "water": return "drop.fill"
        case "parking": return "car.fill"
        case "restrooms": return "figure.stand"
        case "indoor": return "building.2.fill"
        case "locker rooms": return "lock.fill"
        case "bleachers": return "chair.fill"
        default: return "checkmark.circle.fill"
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                subview.place(at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ), proposal: .unspecified)
            }
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxHeight = max(maxHeight, currentY + size.height)
        }

        return (positions, CGSize(width: maxWidth, height: maxHeight))
    }
}
