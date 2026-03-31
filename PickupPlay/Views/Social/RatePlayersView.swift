import SwiftUI

struct PlayerRatingData {
    var skill: Double = 3
    var sportsmanship: Double = 3
    var comment: String = ""
}

struct RatePlayersView: View {
    let game: Game
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerDirectory = PlayerDirectoryViewModel()
    @State private var ratings: [String: PlayerRatingData] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showSuccess = false

    private let ratingRepo = PlayerRatingRepository()
    private let notificationService = NotificationService()

    private var currentUserId: String {
        authViewModel.currentUser?.id ?? ""
    }

    private var otherPlayers: [String] {
        game.playerIds.filter { $0 != currentUserId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Rate the players from this game")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)

                        ForEach(otherPlayers, id: \.self) { playerId in
                            PlayerRatingCard(
                                playerId: playerId,
                                displayName: playerDirectory.displayName(for: playerId),
                                initials: playerDirectory.initials(for: playerId),
                                ratingData: bindingForPlayer(playerId)
                            )
                                .padding(.horizontal, 16)
                        }

                        Button("Submit Ratings") {
                            submitRatings()
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Rate Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { dismiss() }
                        .fontDesign(.rounded)
                }
            }
            .alert("Ratings Submitted!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            }
            .loading(isLoading: isLoading)
            .errorBanner(errorMessage)
            .onAppear {
                Task { await playerDirectory.load(userIds: otherPlayers) }
            }
        }
    }

    private func bindingForPlayer(_ playerId: String) -> Binding<PlayerRatingData> {
        Binding(
            get: { ratings[playerId] ?? PlayerRatingData() },
            set: { ratings[playerId] = $0 }
        )
    }

    private func submitRatings() {
        isLoading = true
        Task {
            do {
                for playerId in otherPlayers {
                    let alreadyRated = try await ratingRepo.hasRated(
                        raterId: currentUserId,
                        ratedUserId: playerId,
                        gameId: game.id
                    )
                    if alreadyRated {
                        continue
                    }

                    let r = ratings[playerId] ?? PlayerRatingData()
                    let rating = PlayerRating.new(
                        raterId: currentUserId,
                        ratedUserId: playerId,
                        gameId: game.id,
                        sportId: game.sportId,
                        skillRating: r.skill,
                        sportsmanshipRating: r.sportsmanship,
                        comment: r.comment
                    )
                    try await ratingRepo.submitRating(rating)
                    _ = try? await ratingRepo.refreshReliabilityScore(for: playerId)
                    try? await notificationService.createNotification(
                        userId: playerId,
                        title: "New Rating Received",
                        body: "You received a new post-game rating for \(game.title).",
                        type: .ratingReceived,
                        referenceId: game.id
                    )
                }
                isLoading = false
                showSuccess = true
            } catch {
                isLoading = false
                errorMessage = "Failed to submit ratings: \(error.localizedDescription)"
            }
        }
    }
}

struct PlayerRatingCard: View {
    let playerId: String
    let displayName: String
    let initials: String
    @Binding var ratingData: PlayerRatingData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            playerHeader
            skillRatingSection
            sportsmanshipSection
            commentField
        }
        .padding(16)
        .glassCard(padding: 0)
    }

    private var playerHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.gradient)
                    .frame(width: 40, height: 40)
                Text(initials)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
            }
            Text(displayName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
        }
    }

    private var skillRatingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Skill")
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
            StarRatingRow(rating: $ratingData.skill, color: AppTheme.accentAmber)
        }
    }

    private var sportsmanshipSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sportsmanship")
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
            StarRatingRow(rating: $ratingData.sportsmanship, color: AppTheme.accentGreen)
        }
    }

    private var commentField: some View {
        TextField("Comment (optional)", text: $ratingData.comment)
            .font(.caption)
            .fontDesign(.rounded)
            .modernInput()
    }
}

struct StarRatingRow: View {
    @Binding var rating: Double
    let color: Color

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                    .foregroundColor(color)
                    .onTapGesture {
                        rating = Double(star)
                    }
            }
        }
    }
}
