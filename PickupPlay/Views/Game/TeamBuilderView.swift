import SwiftUI

struct TeamBuilderView: View {
    let game: Game
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var playerDirectory = PlayerDirectoryViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var teams: [Team] = []
    @State private var showAutoBalance = false

    private var unassignedPlayers: [String] {
        let assigned = Set(teams.flatMap { $0.playerIds })
        return game.playerIds.filter { !assigned.contains($0) }
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    if teams.isEmpty {
                        VStack(spacing: 16) {
                            Text("No teams created yet")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Button("Create 2 Teams") {
                                    teams = [
                                        Team.new(gameId: game.id, name: "Team A"),
                                        Team.new(gameId: game.id, name: "Team B")
                                    ]
                                }
                                .buttonStyle(AppPrimaryButtonStyle())

                                Button("Auto-Balance") {
                                    Task {
                                        teams = await gameViewModel.autoBalanceTeams(for: game)
                                    }
                                }
                                .buttonStyle(AppSecondaryButtonStyle())
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                    } else {
                        ForEach(Array(teams.enumerated()), id: \.element.id) { index, team in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(team.name)
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                    Spacer()
                                    HStack(spacing: 8) {
                                        Text("Score:")
                                            .font(.subheadline)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.secondary)
                                        Button { if teams[index].score > 0 { teams[index].score -= 1 } } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                        Text("\(team.score)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .fontDesign(.rounded)
                                            .frame(minWidth: 24)
                                        Button { teams[index].score += 1 } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundStyle(AppTheme.gradient)
                                        }
                                    }
                                }

                                if team.playerIds.isEmpty {
                                    Text("No players assigned")
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach(team.playerIds, id: \.self) { playerId in
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(width: 32, height: 32)
                                                Text(playerDirectory.initials(for: playerId))
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .fontDesign(.rounded)
                                            }
                                            Text(playerDirectory.displayName(for: playerId))
                                                .font(.subheadline)
                                                .fontDesign(.rounded)
                                                .lineLimit(1)
                                            Spacer()
                                            Button {
                                                teams[index].playerIds.removeAll { $0 == playerId }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .glassCard(padding: 0)
                            .padding(.horizontal, 16)
                        }

                        if !unassignedPlayers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Unassigned Players")
                                    .font(.headline)
                                    .fontDesign(.rounded)

                                ForEach(unassignedPlayers, id: \.self) { playerId in
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.accentAmber.opacity(0.15))
                                                .frame(width: 32, height: 32)
                                            Text(playerDirectory.initials(for: playerId))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .fontDesign(.rounded)
                                        }
                                        Text(playerDirectory.displayName(for: playerId))
                                            .font(.subheadline)
                                            .fontDesign(.rounded)
                                            .lineLimit(1)
                                        Spacer()

                                        ForEach(Array(teams.enumerated()), id: \.element.id) { teamIndex, team in
                                            Button(team.name) {
                                                teams[teamIndex].playerIds.append(playerId)
                                            }
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .fontDesign(.rounded)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().fill(AppTheme.accentGreen.opacity(0.15)))
                                            .foregroundColor(AppTheme.accentGreen)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .glassCard(padding: 0)
                            .padding(.horizontal, 16)
                        }

                        HStack(spacing: 12) {
                            Button("Auto-Balance") {
                                Task {
                                    teams = await gameViewModel.autoBalanceTeams(for: game)
                                }
                            }
                            .buttonStyle(AppSecondaryButtonStyle())

                            Button("Save Teams") {
                                Task { await saveTeams() }
                            }
                            .buttonStyle(AppPrimaryButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Team Builder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .fontDesign(.rounded)
                    .foregroundStyle(AppTheme.gradient)
            }
        }
        .onAppear {
            teams = game.teams
            Task { await playerDirectory.load(userIds: game.playerIds) }
        }
        .errorBanner(message: $gameViewModel.errorMessage)
        .loading(isLoading: gameViewModel.isLoading)
    }

    private func saveTeams() async {
        var updatedGame = game
        updatedGame.teams = teams
        await gameViewModel.updateGame(updatedGame)
        if gameViewModel.errorMessage == nil {
            dismiss()
        }
    }
}
