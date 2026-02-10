//
//  GameListViewStub.swift
//  PickupPlay
//
import SwiftUI

struct GameListViewStub: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 20) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.accentCyan.opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(AppTheme.gradient)
                    }

                    Text("No Games Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)

                    Text("Nearby games will appear here.\nFull game browsing coming soon.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()
                }
            }
            .navigationTitle("Games")
        }
    }
}

#Preview {
    GameListViewStub()
}
