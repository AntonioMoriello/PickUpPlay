//
//  MapViewStub.swift
//  PickupPlay
//
import SwiftUI
import MapKit

struct MapViewStub: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .ignoresSafeArea(edges: .bottom)

                VStack {
                    Spacer()
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accentGreen.opacity(0.12))
                                .frame(width: 48, height: 48)

                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(AppTheme.gradient)
                        }

                        Text("Game pins coming soon")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)

                        Text("Tap pins to view game details and join")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapViewStub()
}
