import Foundation
import Combine
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var selectedGame: Game? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var filterOptions: GameFilterOptions = .default

    @Published var formData: GameFormData = GameFormData()
    @Published var nearbyVenues: [Venue] = []
    @Published var selectedVenue: Venue? = nil
    @Published var formStep: Int = 0
    @Published var isFormValid: Bool = false

    private let gameService: GameService
    private let gameRepository: GameRepository
    private let venueService: VenueService
    private let locationService: LocationService
    private let gameHistoryRepo: GameHistoryRepo
    private let cacheRepository: CacheRepository
    private let venueRepository: VenueRepository
    private let userRepository: UserRepository
    private let achievementRepo: AchievementRepo
    private let userPrefsRepo: UserPrefsRepo

    init() {
        self.gameRepository = GameRepository()
        self.venueRepository = VenueRepository()
        self.gameService = GameService(gameRepository: gameRepository)
        self.venueService = VenueService(venueRepository: venueRepository)
        self.locationService = LocationService()
        self.gameHistoryRepo = GameHistoryRepo()
        self.cacheRepository = CacheRepository()
        self.userRepository = UserRepository()
        self.achievementRepo = AchievementRepo()
        self.userPrefsRepo = UserPrefsRepo()
    }

    func fetchNearbyGames(location: CLLocation? = nil, radius: Double = 25.0) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let searchLocation = await resolveSearchLocation(requested: location)
            let nearbyGames = try await fetchDemoAwareGames(
                around: searchLocation,
                requestedLocation: location,
                radius: radius
            )
            self.games = nearbyGames
            cacheRepository.cacheGames(nearbyGames)
        } catch {
            self.errorMessage = "Failed to fetch games: \(error.localizedDescription)"
            self.games = cacheRepository.getCachedGames()
        }
    }

    func applyFilters(_ filters: GameFilterOptions) async {
        self.filterOptions = filters
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let searchLocation = await resolveSearchLocation()
            var filtered = try await fetchDemoAwareGames(
                around: searchLocation,
                radius: filters.maxDistance
            )

            if let sportId = filters.sportId, !sportId.isEmpty {
                filtered = filtered.filter { $0.sportId == sportId }
            }

            if let level = filters.skillLevel {
                filtered = filtered.filter { $0.skillLevel == level }
            }

            let now = Date()
            switch filters.dateRange {
            case .today:
                filtered = filtered.filter { Calendar.current.isDateInToday($0.dateTime) }
            case .thisWeek:
                let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
                filtered = filtered.filter { $0.dateTime >= now && $0.dateTime <= weekEnd }
            case .thisMonth:
                let monthEnd = Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now
                filtered = filtered.filter { $0.dateTime >= now && $0.dateTime <= monthEnd }
            case .any:
                break
            }

            self.games = filtered
            cacheRepository.cacheGames(filtered)
        } catch {
            self.errorMessage = "Failed to apply filters: \(error.localizedDescription)"
        }
    }

    func initializeCreateForm() async {
        isLoading = true
        defer { isLoading = false }

        formData = GameFormData()
        formStep = 0
        selectedVenue = nil

        do {
            try await venueRepository.populateVenuesIfNeeded()
            let searchLocation = await resolveSearchLocation()
            nearbyVenues = try await fetchDemoAwareVenues(around: searchLocation)
        } catch {
            self.errorMessage = "Failed to load venues: \(error.localizedDescription)"
        }
    }

    func setVenue(_ venue: Venue) {
        selectedVenue = venue
        formData.venueId = venue.id
        validateForm()
    }

    func validateForm() {
        isFormValid = !formData.title.trimmingCharacters(in: .whitespaces).isEmpty
            && !formData.sportId.isEmpty
            && !formData.venueId.isEmpty
            && formData.dateTime > Date()
            && formData.maxPlayers >= 2
    }

    func createGame(userId: String) async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let location: GeoPoint
        if let venue = selectedVenue {
            location = venue.coordinates
        } else {
            location = AppLocationDefaults.defaultGeoPoint
        }

        let game = gameService.buildGameObject(from: formData, userId: userId, location: location)

        let errors = gameService.validateGame(game)
        if !errors.isEmpty {
            self.errorMessage = errors.map(\.message).joined(separator: "\n")
            return nil
        }

        do {
            let gameId = try await gameService.createGame(game)
            do {
                try await userRepository.incrementGameCounts(userId: userId, gamesOrganizedDelta: 1)
            } catch {
                print("Failed to sync organizer stats: \(error)")
            }
            await refreshAchievementProgress(userId: userId)
            if let createdGame = try await gameRepository.getGame(id: gameId) {
                applyLocalGameUpdate(createdGame)
            }
            AppEvents.post(.gamesDidChange)
            AppEvents.post(.profileDidChange)
            return gameId
        } catch {
            self.errorMessage = "Failed to create game: \(error.localizedDescription)"
            return nil
        }
    }

    func joinGame(gameId: String, userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let updatedGame = try await gameService.joinGame(gameId: gameId, userId: userId)
            applyLocalGameUpdate(updatedGame)
            AppEvents.post(.gamesDidChange)
            AppEvents.post(.profileDidChange)
        } catch {
            self.errorMessage = "Failed to join game: \(error.localizedDescription)"
        }
    }

    func leaveGame(gameId: String, userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await gameService.leaveGame(gameId: gameId, userId: userId)
            if let game = try await gameRepository.getGame(id: gameId) {
                applyLocalGameUpdate(game)
            }
            AppEvents.post(.gamesDidChange)
            AppEvents.post(.profileDidChange)
        } catch {
            self.errorMessage = "Failed to leave game: \(error.localizedDescription)"
        }
    }

    func updateGame(_ game: Game) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let data = try Firestore.Encoder().encode(game)
            try await gameRepository.updateGame(id: game.id, data: data)
            applyLocalGameUpdate(game)
            AppEvents.post(.gamesDidChange)
        } catch {
            self.errorMessage = "Failed to update game: \(error.localizedDescription)"
        }
    }

    func cancelGame(gameId: String, organizerId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let updatedGame = try await gameService.cancelGame(gameId: gameId, organizerId: organizerId)
            applyLocalGameUpdate(updatedGame)
            AppEvents.post(.gamesDidChange)
        } catch {
            self.errorMessage = "Failed to cancel game: \(error.localizedDescription)"
        }
    }

    func balanceTeams(gameId: String) async {
        guard let game = games.first(where: { $0.id == gameId }) ?? selectedGame else { return }
        isLoading = true
        defer { isLoading = false }

        let teams = await autoBalanceTeams(for: game)
        do {
            let teamsData = try teams.map { try Firestore.Encoder().encode($0) }
            try await gameRepository.updateGame(id: gameId, data: ["teams": teamsData])
            if let index = games.firstIndex(where: { $0.id == gameId }) {
                games[index].teams = teams
            }
            selectedGame?.teams = teams
            AppEvents.post(.gamesDidChange)
        } catch {
            self.errorMessage = "Failed to balance teams: \(error.localizedDescription)"
        }
    }

    func autoBalanceTeams(for game: Game) async -> [Team] {
        let skillLevels = await buildSkillMap(for: game.playerIds, sportId: game.sportId)
        return gameService.balanceTeams(game: game, skillLevelsByPlayerId: skillLevels)
    }

    func completeGame(gameId: String, organizerId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let completedGame = try await gameService.completeGame(gameId: gameId, organizerId: organizerId)
            applyLocalGameUpdate(completedGame)

            let histories = GameHistory.completedHistories(from: completedGame)
            histories.forEach { gameHistoryRepo.saveToHistory($0) }

            for userId in Set(histories.map(\.userId)) {
                await refreshAchievementProgress(userId: userId)
            }

            AppEvents.post(.gamesDidChange)
            AppEvents.post(.profileDidChange)
        } catch {
            self.errorMessage = "Failed to complete game: \(error.localizedDescription)"
        }
    }

    func reloadGame(gameId: String) async {
        do {
            if let game = try await gameRepository.getGame(id: gameId) {
                applyLocalGameUpdate(game)
            }
        } catch {
            errorMessage = "Failed to refresh game: \(error.localizedDescription)"
        }
    }

    private func refreshAchievementProgress(userId: String) async {
        let history = gameHistoryRepo.getHistory(userId: userId)
        let organizedGames = (try? await gameRepository.getGamesOrganizedBy(userId: userId)) ?? []
        let followerCount = ((try? await userRepository.getUser(id: userId))?.followerIds.count) ?? 0

        achievementRepo.syncProgress(
            userId: userId,
            history: history,
            organizedGamesCount: organizedGames.count,
            followerCount: followerCount
        )
    }

    private func resolveSearchLocation(requested: CLLocation? = nil) async -> CLLocation {
        if let requested {
            return requested
        }

        if let userId = FirebaseManager.shared.auth.currentUser?.uid,
           let prefs = userPrefsRepo.getPreferences(userId: userId),
           !prefs.privacySettings.locationSharing {
            return AppLocationDefaults.defaultLocation
        }

        if let currentLocation = await locationService.getCurrentLocation() {
            return currentLocation
        }

        return AppLocationDefaults.defaultLocation
    }

    private func fetchDemoAwareGames(
        around location: CLLocation,
        requestedLocation: CLLocation? = nil,
        radius: Double
    ) async throws -> [Game] {
        let nearbyGames = try await gameRepository.getNearbyGames(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radiusKm: radius
        )

        if nearbyGames.isEmpty,
           shouldFallbackToDemoArea(from: location, requestedLocation: requestedLocation) {
            return try await gameRepository.getNearbyGames(
                latitude: AppLocationDefaults.defaultLocation.coordinate.latitude,
                longitude: AppLocationDefaults.defaultLocation.coordinate.longitude,
                radiusKm: radius
            )
        }

        return nearbyGames
    }

    private func fetchDemoAwareVenues(
        around location: CLLocation,
        requestedLocation: CLLocation? = nil,
        sportFilter: String? = nil
    ) async throws -> [Venue] {
        let nearbyVenues = try await venueService.fetchNearbyVenues(
            location: location,
            radius: 25.0,
            sportFilter: sportFilter
        )

        if nearbyVenues.isEmpty,
           shouldFallbackToDemoArea(from: location, requestedLocation: requestedLocation) {
            return try await venueService.fetchNearbyVenues(
                location: AppLocationDefaults.defaultLocation,
                radius: 25.0,
                sportFilter: sportFilter
            )
        }

        return nearbyVenues
    }

    private func shouldFallbackToDemoArea(from resolvedLocation: CLLocation, requestedLocation: CLLocation?) -> Bool {
        requestedLocation == nil &&
        resolvedLocation.distance(from: AppLocationDefaults.defaultLocation) > 1_000
    }

    private func buildSkillMap(for playerIds: [String], sportId: String) async -> [String: SkillLevel] {
        var skillMap: [String: SkillLevel] = [:]

        for playerId in playerIds {
            if let user = try? await userRepository.getUser(id: playerId),
               let skill = user.sportSkills.first(where: { $0.sportId == sportId })?.level {
                skillMap[playerId] = skill
            }
        }

        return skillMap
    }

    private func applyLocalGameUpdate(_ game: Game) {
        if let index = games.firstIndex(where: { $0.id == game.id }) {
            games[index] = game
        } else {
            games.insert(game, at: 0)
        }

        games.sort { $0.dateTime < $1.dateTime }
        selectedGame = game
        cacheRepository.cacheGames(games)
    }
}
