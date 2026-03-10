//
//  GameViewModel.swift
//  PickupPlay
//
import Foundation
import Combine
import CoreLocation
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

    init() {
        self.gameRepository = GameRepository()
        self.venueRepository = VenueRepository()
        self.gameService = GameService(gameRepository: gameRepository)
        self.venueService = VenueService(venueRepository: venueRepository)
        self.locationService = LocationService()
        self.gameHistoryRepo = GameHistoryRepo()
        self.cacheRepository = CacheRepository()
    }

    func fetchNearbyGames(location: CLLocation? = nil, radius: Double = 25.0) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var loc = location
            if loc == nil {
                loc = await locationService.getCurrentLocation()
            }
            let games = try await gameRepository.getNearbyGames(
                latitude: loc?.coordinate.latitude ?? 43.6532,
                longitude: loc?.coordinate.longitude ?? -79.3832,
                radiusKm: radius
            )
            self.games = games
            cacheRepository.cacheGames(games)
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
            var filtered: [Game]
            if let sportId = filters.sportId, !sportId.isEmpty {
                filtered = try await gameRepository.getGamesForSport(sportId: sportId)
            } else {
                filtered = try await gameRepository.getNearbyGames(latitude: 43.6532, longitude: -79.3832, radiusKm: filters.maxDistance)
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
            let location = await locationService.getCurrentLocation()
            let loc = location ?? CLLocation(latitude: 43.6532, longitude: -79.3832)
            nearbyVenues = try await venueService.fetchNearbyVenues(location: loc, radius: 25.0, sportFilter: nil)
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
            location = GeoPoint(latitude: 43.6532, longitude: -79.3832)
        }

        let game = gameService.buildGameObject(from: formData, userId: userId, location: location)

        let errors = gameService.validateGame(game)
        if !errors.isEmpty {
            self.errorMessage = errors.map(\.message).joined(separator: "\n")
            return nil
        }

        do {
            let gameId = try await gameService.createGame(game)
            let history = GameHistory.fromGame(game, userId: userId)
            gameHistoryRepo.saveToHistory(history)
            await fetchNearbyGames()
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
            let history = GameHistory.fromGame(updatedGame, userId: userId)
            gameHistoryRepo.saveToHistory(history)

            if let index = games.firstIndex(where: { $0.id == gameId }) {
                games[index] = updatedGame
            }
            selectedGame = updatedGame
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
                if let index = games.firstIndex(where: { $0.id == gameId }) {
                    games[index] = game
                }
                selectedGame = game
            }
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
            if let index = games.firstIndex(where: { $0.id == game.id }) {
                games[index] = game
            }
            selectedGame = game
        } catch {
            self.errorMessage = "Failed to update game: \(error.localizedDescription)"
        }
    }

    func cancelGame(gameId: String, organizerId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await gameService.cancelGame(gameId: gameId, organizerId: organizerId)
            if let index = games.firstIndex(where: { $0.id == gameId }) {
                games[index].status = .cancelled
            }
            selectedGame?.status = .cancelled
        } catch {
            self.errorMessage = "Failed to cancel game: \(error.localizedDescription)"
        }
    }

    func balanceTeams(gameId: String) async {
        guard let game = games.first(where: { $0.id == gameId }) ?? selectedGame else { return }
        isLoading = true
        defer { isLoading = false }

        let teams = gameService.balanceTeams(game: game)
        do {
            let teamsData = try teams.map { try Firestore.Encoder().encode($0) }
            try await gameRepository.updateGame(id: gameId, data: ["teams": teamsData])
            if let index = games.firstIndex(where: { $0.id == gameId }) {
                games[index].teams = teams
            }
            selectedGame?.teams = teams
        } catch {
            self.errorMessage = "Failed to balance teams: \(error.localizedDescription)"
        }
    }
}
