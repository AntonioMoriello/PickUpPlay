import SwiftUI

struct GameDetailsView: View {
    let game: Game
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var playerDirectory = PlayerDirectoryViewModel()
    @State private var showJoinConfirm = false
    @State private var showLeaveConfirm = false
    @State private var showSkillWarning = false
    @State private var showRoster = false
    @State private var showEditGame = false
    @State private var showTeamBuilder = false
    @State private var showChat = false
    @State private var showShare = false
    @State private var showRatePlayers = false

    private var currentUserId: String {
        authViewModel.currentUser?.id ?? ""
    }

    private var currentGame: Game {
        gameViewModel.selectedGame ?? game
    }

    private var isOrganizer: Bool {
        currentGame.organizerId == currentUserId
    }

    private var isParticipant: Bool {
        currentGame.playerIds.contains(currentUserId)
    }

    private var sportName: String {
        Sport.allSports.first(where: { $0.id == currentGame.sportId })?.name ?? currentGame.sportId.capitalized
    }

    private var sportIcon: String {
        Sport.allSports.first(where: { $0.id == currentGame.sportId })?.iconName ?? "sportscourt.fill"
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    infoSection
                    rosterPreviewSection
                    actionSection
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Game Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isOrganizer {
                    Menu {
                        Button { showEditGame = true } label: {
                            Label("Edit Game", systemImage: "pencil")
                        }
                        Button { showTeamBuilder = true } label: {
                            Label("Team Builder", systemImage: "person.2.badge.gearshape")
                        }
                        if currentGame.status == .upcoming || currentGame.status == .inProgress {
                            Button {
                                Task {
                                    await gameViewModel.completeGame(
                                        gameId: currentGame.id,
                                        organizerId: currentUserId
                                    )
                                }
                            } label: {
                                Label("Mark Completed", systemImage: "checkmark.circle")
                            }
                        }
                        Button(role: .destructive) {
                            Task { await gameViewModel.cancelGame(gameId: currentGame.id, organizerId: currentUserId) }
                        } label: {
                            Label("Cancel Game", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(AppTheme.gradient)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditGame) {
            EditGameView(game: currentGame)
        }
        .sheet(isPresented: $showTeamBuilder) {
            NavigationStack {
                TeamBuilderView(game: currentGame)
            }
        }
        .alert("Join Game?", isPresented: $showJoinConfirm) {
            Button("Join") {
                Task { await gameViewModel.joinGame(gameId: currentGame.id, userId: currentUserId) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll be added to this game's roster.")
        }
        .alert("Skill Level Mismatch", isPresented: $showSkillWarning) {
            Button("Join Anyway") {
                showJoinConfirm = true
            }
            Button("Find Another", role: .cancel) {}
        } message: {
            Text("This game is marked as \(currentGame.skillLevel.displayName). Your skill level may not match. Continue anyway?")
        }
        .alert("Leave Game?", isPresented: $showLeaveConfirm) {
            Button("Leave", role: .destructive) {
                Task { await gameViewModel.leaveGame(gameId: currentGame.id, userId: currentUserId) }
            }
            Button("Stay", role: .cancel) {}
        } message: {
            Text("You'll be removed from the roster.")
        }
        .navigationDestination(isPresented: $showChat) {
            ChatRoomView(chatRoomId: currentGame.chatRoomId)
        }
        .sheet(isPresented: $showShare) {
            ShareToSocialView(game: currentGame)
        }
        .sheet(isPresented: $showRatePlayers) {
            RatePlayersView(game: currentGame)
        }
        .onAppear {
            gameViewModel.selectedGame = game
            Task { await playerDirectory.load(userIds: game.playerIds) }
            Task { await gameViewModel.reloadGame(gameId: game.id) }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gamesDidChange)) { _ in
            Task { await gameViewModel.reloadGame(gameId: currentGame.id) }
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
            Task { await playerDirectory.load(userIds: currentGame.playerIds) }
        }
        .errorBanner(message: $gameViewModel.errorMessage)
        .loading(isLoading: gameViewModel.isLoading)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGreen.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: sportIcon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppTheme.gradient)
            }

            Text(currentGame.title)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                StatusBadge(status: currentGame.status)
                SkillLevelBadge(level: currentGame.skillLevel)
            }

            if !currentGame.description.isEmpty {
                Text(currentGame.description)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 16)
    }

    private var infoSection: some View {
        VStack(spacing: 16) {
            InfoRow(icon: "sportscourt.fill", label: "Sport", value: sportName)
            Divider()
            InfoRow(icon: "calendar", label: "Date", value: currentGame.dateTime.formatted(date: .abbreviated, time: .omitted))
            Divider()
            InfoRow(icon: "clock.fill", label: "Time", value: currentGame.dateTime.formatted(date: .omitted, time: .shortened))
            Divider()
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.gradient)
                    .frame(width: 24)
                Text("Players")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(currentGame.currentPlayers) / \(currentGame.maxPlayers)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(currentGame.isFull ? AppTheme.accentRose : AppTheme.accentGreen)
            }
        }
        .padding(20)
        .glassCard(padding: 0)
        .padding(.horizontal, 16)
    }

    private var rosterPreviewSection: some View {
        VStack(spacing: 12) {
            HStack {
                SectionHeader(title: "Roster (\(currentGame.currentPlayers))", icon: "person.3.fill")
                Spacer()
                Button("View All") {
                    showRoster = true
                }
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(AppTheme.gradient)
                .padding(.trailing, 20)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(currentGame.playerIds, id: \.self) { playerId in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.gradient)
                                    .frame(width: 44, height: 44)
                                Text(playerDirectory.initials(for: playerId))
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.white)
                            }
                            Text(playerDirectory.displayName(for: playerId))
                                .font(.caption2)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Text(playerId == currentGame.organizerId ? "Host" : "Player")
                                .font(.caption2)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationDestination(isPresented: $showRoster) {
            PlayerRosterView(game: currentGame)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            if isParticipant && !currentGame.chatRoomId.isEmpty {
                HStack(spacing: 12) {
                    Button {
                        showChat = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                    }
                    .buttonStyle(AppSecondaryButtonStyle())

                    Button {
                        showShare = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    }
                    .buttonStyle(AppSecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
            }

            if currentGame.status == .cancelled {
                Text("This game has been cancelled")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.accentRose)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)
            } else if currentGame.status == .completed && isParticipant {
                Button("Rate Players") {
                    showRatePlayers = true
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 20)
            } else if isParticipant {
                if !isOrganizer {
                    Button("Leave Game") {
                        showLeaveConfirm = true
                    }
                    .buttonStyle(AppSecondaryButtonStyle())
                    .padding(.horizontal, 20)
                }
            } else if !currentGame.isFull && currentGame.status == .upcoming {
                Button("Join Game") {
                    handleJoinTap()
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 20)
            } else if currentGame.isFull {
                Text("This game is full")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)
            }
        }
    }

    private func handleJoinTap() {
        if let userSkill = authViewModel.currentUser?.sportSkills.first(where: { $0.sportId == currentGame.sportId }) {
            let skillOrder: [SkillLevel] = [.beginner, .intermediate, .advanced, .expert]
            let userIndex = skillOrder.firstIndex(of: userSkill.level) ?? 0
            let gameIndex = skillOrder.firstIndex(of: currentGame.skillLevel) ?? 0
            if abs(userIndex - gameIndex) > 1 {
                showSkillWarning = true
                return
            }
        }
        showJoinConfirm = true
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.gradient)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
        }
    }
}
