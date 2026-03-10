//
//  SportBrowserView.swift
//  PickupPlay
//
import SwiftUI

struct SportBrowserView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var searchText = ""
    @State private var selectedSportId: String? = nil

    private var groupedSports: [(SportCategory, [Sport])] {
        let filtered = searchText.isEmpty
            ? Sport.allSports
            : Sport.allSports.filter { $0.name.lowercased().contains(searchText.lowercased()) }

        let grouped = Dictionary(grouping: filtered) { $0.category }
        return SportCategory.allCases.compactMap { cat in
            guard let sports = grouped[cat], !sports.isEmpty else { return nil }
            return (cat, sports)
        }
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(groupedSports, id: \.0) { category, sports in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(categoryDisplayName(category))
                                .font(.headline)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 20)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(sports) { sport in
                                    NavigationLink(destination: GameListView()) {
                                        SportBrowserCell(sport: sport)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Sports")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search sports...")
    }

    private func categoryDisplayName(_ category: SportCategory) -> String {
        switch category {
        case .teamSport: return "Team Sports"
        case .racquetNet: return "Racquet & Net"
        case .individual: return "Individual"
        case .fitness: return "Fitness"
        case .outdoor: return "Outdoor"
        case .custom: return "Custom"
        }
    }
}

struct SportBrowserCell: View {
    let sport: Sport

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGreen.opacity(0.1))
                    .frame(width: 52, height: 52)
                Image(systemName: sport.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppTheme.gradient)
            }

            Text(sport.name)
                .font(.caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(padding: 0)
    }
}
