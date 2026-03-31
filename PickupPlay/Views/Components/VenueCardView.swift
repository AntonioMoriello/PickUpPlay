import SwiftUI

struct VenueCardView: View {
    let venue: Venue
    var isFavorite: Bool = false
    var onTap: (() -> Void)? = nil
    var onFavoriteToggle: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
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
                        Text(venue.name)
                            .font(.headline)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text(venue.address)
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if let onFavoriteToggle {
                        Button {
                            onFavoriteToggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(isFavorite ? AppTheme.accentRose : .secondary)
                        }
                    }
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.accentAmber)
                        Text(String(format: "%.1f", venue.rating))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        Text("(\(venue.reviewCount))")
                            .font(.caption2)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }

                    if venue.isVerified {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundColor(AppTheme.accentGreen)
                            Text("Verified")
                                .font(.caption2)
                                .fontDesign(.rounded)
                                .foregroundColor(AppTheme.accentGreen)
                        }
                    }

                    Spacer()

                    Text(venue.isPublic ? "Public" : "Private")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundColor(venue.isPublic ? AppTheme.accentGreen : AppTheme.accentAmber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill((venue.isPublic ? AppTheme.accentGreen : AppTheme.accentAmber).opacity(0.1)))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(venue.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption2)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(.systemGray6)))
                        }
                    }
                }
            }
            .padding(16)
            .glassCard(padding: 0)
        }
        .buttonStyle(.plain)
    }
}
