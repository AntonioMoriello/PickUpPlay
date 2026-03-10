//
//  GameListView.swift
//  PickupPlay
//
import SwiftUI

struct GameListView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showFilters = false
    @State private var searchText = ""

    private var filteredGames: [Game] {
        if searchText.isEmpty {
            return gameViewModel.games
        }
        let lowered = searchText.lowercased()
        return gameViewModel.games.filter {
            $0.title.lowercased().contains(lowered)
        }
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if gameViewModel.isLoading && gameViewModel.games.isEmpty {
                ProgressView("Loading games...")
                    .fontDesign(.rounded)
            } else if filteredGames.isEmpty {
                EmptyStateView(
                    icon: "sportscourt",
                    title: "No Games Found",
                    message: "No games match your search or filters. Try adjusting your criteria or create a new game!",
                    actionTitle: "Clear Filters"
                ) {
                    searchText = ""
                    gameViewModel.filterOptions = .default
                    Task { await gameViewModel.fetchNearbyGames() }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredGames) { game in
                            NavigationLink(destination: GameDetailsView(game: game)) {
                                GameCardView(game: game)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    await gameViewModel.fetchNearbyGames()
                }
            }
        }
        .navigationTitle("Games")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search games...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(AppTheme.gradient)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSearchView(filterOptions: $gameViewModel.filterOptions) {
                Task { await gameViewModel.applyFilters(gameViewModel.filterOptions) }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            Task { await gameViewModel.fetchNearbyGames() }
        }
        .errorBanner(message: $gameViewModel.errorMessage)
    }
}
