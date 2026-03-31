import Foundation
import Combine
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var currentViewer: User? = nil
    @Published var stats: PlayerStats? = nil
    @Published var achievements: [Achievement] = []
    @Published var gameHistory: [GameHistory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isOwnProfile: Bool = false
    @Published var followingList: [User] = []

    private let userRepository: UserRepository
    private let statsRepository: StatsRepository
    private let achievementRepo: AchievementRepo
    private let gameHistoryRepo: GameHistoryRepo
    private let playerRatingRepository: PlayerRatingRepository
    private let gameRepository: GameRepository

    init() {
        self.userRepository = UserRepository()
        self.statsRepository = StatsRepository()
        self.achievementRepo = AchievementRepo()
        self.gameHistoryRepo = GameHistoryRepo()
        self.playerRatingRepository = PlayerRatingRepository()
        self.gameRepository = GameRepository()
    }

    func loadProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let currentUid = FirebaseManager.shared.auth.currentUser?.uid
        isOwnProfile = userId == currentUid

        do {
            user = try await userRepository.getUser(id: userId)
            if let currentUid {
                currentViewer = try await userRepository.getUser(id: currentUid)
            } else {
                currentViewer = nil
            }

            if var user, let rating = try? await playerRatingRepository.averageRating(for: userId) {
                user.reliabilityScore = rating
                self.user = user
            }
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }

    func updateProfile(_ updates: [String: Any]) async {
        guard let userId = user?.id else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await userRepository.updateUser(id: userId, data: updates)
            user = try await userRepository.getUser(id: userId)
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }

    func followUser(_ targetUserId: String) async {
        guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await userRepository.followUser(currentUserId: currentUserId, targetUserId: targetUserId)
            user = try await userRepository.getUser(id: targetUserId)
            currentViewer = try await userRepository.getUser(id: currentUserId)
        } catch {
            errorMessage = "Failed to follow user: \(error.localizedDescription)"
        }
    }

    func unfollowUser(_ targetUserId: String) async {
        guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await userRepository.unfollowUser(currentUserId: currentUserId, targetUserId: targetUserId)
            user = try await userRepository.getUser(id: targetUserId)
            currentViewer = try await userRepository.getUser(id: currentUserId)
        } catch {
            errorMessage = "Failed to unfollow user: \(error.localizedDescription)"
        }
    }

    func fetchStats(userId: String, months: Int? = nil) async {
        let organizedGames = (try? await gameRepository.getGamesOrganizedBy(userId: userId)) ?? []
        let organizedGamesCount: Int

        if let months {
            let cutoff = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
            organizedGamesCount = organizedGames.filter { $0.dateTime >= cutoff }.count
            stats = statsRepository.getSeasonSummary(
                userId: userId,
                months: months,
                organizedGamesCount: organizedGamesCount
            )
        } else {
            organizedGamesCount = organizedGames.count
            stats = statsRepository.getOverallStats(
                userId: userId,
                organizedGamesCount: organizedGamesCount
            )
        }
    }

    func fetchGameHistory(userId: String) {
        gameHistory = gameHistoryRepo.getHistory(userId: userId)
    }

    func fetchAchievements(userId: String) async {
        let history = gameHistoryRepo.getHistory(userId: userId)
        let organizedGames = (try? await gameRepository.getGamesOrganizedBy(userId: userId)) ?? []
        let profile: User?
        if let user {
            profile = user
        } else {
            profile = try? await userRepository.getUser(id: userId)
        }
        let followerCount = profile?.followerIds.count ?? 0

        achievementRepo.syncProgress(
            userId: userId,
            history: history,
            organizedGamesCount: organizedGames.count,
            followerCount: followerCount
        )
        achievements = achievementRepo.getAchievements(userId: userId)
    }

    func fetchFollowingList(userId: String) async {
        guard let user = user else { return }
        isLoading = true
        defer { isLoading = false }

        var users: [User] = []
        for followingId in user.followingIds {
            if let followedUser = try? await userRepository.getUser(id: followingId) {
                users.append(followedUser)
            }
        }
        followingList = users
    }

    func isFollowing(userId: String) -> Bool {
        guard !isOwnProfile else { return false }
        return currentViewer?.followingIds.contains(userId) ?? false
    }

    func canViewProfileDetails() -> Bool {
        guard let user else { return false }
        if isOwnProfile { return true }

        switch user.profileVisibility ?? .everyone {
        case .everyone:
            return true
        case .followersOnly:
            return currentViewer?.followingIds.contains(user.id) ?? false
        case .nobody:
            return false
        }
    }
}
