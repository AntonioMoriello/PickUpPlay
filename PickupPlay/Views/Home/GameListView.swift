import SwiftUI

struct GameListView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showFilters = false
    @State private var searchText = ""
    private let initialSportId: String?
    private let screenTitle: String

    init(initialSportId: String? = nil, screenTitle: String = "Games") {
        self.initialSportId = initialSportId
        self.screenTitle = screenTitle
    }

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
                    Task { await loadGames() }
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
                    await loadGames()
                }
            }
        }
        .navigationTitle(screenTitle)
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
                Task { await loadGames() }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            Task { await loadGames() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gamesDidChange)) { _ in
            Task { await loadGames() }
        }
        .errorBanner(message: $gameViewModel.errorMessage)
    }

    private func loadGames() async {
        if let initialSportId, !initialSportId.isEmpty {
            gameViewModel.filterOptions.sportId = initialSportId
        }

        let hasFilters = gameViewModel.filterOptions.sportId != nil
            || gameViewModel.filterOptions.skillLevel != nil
            || gameViewModel.filterOptions.dateRange != .any
            || gameViewModel.filterOptions.maxDistance != GameFilterOptions.default.maxDistance

        if hasFilters {
            await gameViewModel.applyFilters(gameViewModel.filterOptions)
        } else {
            await gameViewModel.fetchNearbyGames()
        }
    }
}
