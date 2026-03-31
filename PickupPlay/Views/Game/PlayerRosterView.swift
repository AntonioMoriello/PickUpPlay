import SwiftUI

struct PlayerRosterView: View {
    let game: Game
    @StateObject private var playerDirectory = PlayerDirectoryViewModel()

    private var sportName: String {
        Sport.allSports.first(where: { $0.id == game.sportId })?.name ?? game.sportId.capitalized
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("\(game.currentPlayers)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.gradient)
                            Text("Players")
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassCard(padding: 0)

                        VStack(spacing: 4) {
                            Text("\(game.maxPlayers)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("Max")
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassCard(padding: 0)

                        VStack(spacing: 4) {
                            Text("\(game.spotsLeft)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(game.spotsLeft > 0 ? AppTheme.accentGreen : AppTheme.accentRose)
                            Text("Spots Left")
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassCard(padding: 0)
                    }
                    .padding(.horizontal, 16)

                    if !game.teams.isEmpty {
                        ForEach(game.teams) { team in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(team.name)
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                    Spacer()
                                    Text("Score: \(team.score)")
                                        .font(.subheadline)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.secondary)
                                }

                                ForEach(team.playerIds, id: \.self) { playerId in
                                    PlayerRow(
                                        playerId: playerId,
                                        displayName: playerDirectory.displayName(for: playerId),
                                        initials: playerDirectory.initials(for: playerId),
                                        isOrganizer: playerId == game.organizerId,
                                        teamName: team.name
                                    )
                                }
                            }
                            .padding(16)
                            .glassCard(padding: 0)
                            .padding(.horizontal, 16)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        if game.teams.isEmpty {
                            Text("All Players")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 20)
                        } else {
                            Text("Unassigned")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 20)
                        }

                        let assignedPlayers = game.teams.flatMap { $0.playerIds }
                        let unassigned = game.playerIds.filter { !assignedPlayers.contains($0) }

                        ForEach(unassigned, id: \.self) { playerId in
                            PlayerRow(
                                playerId: playerId,
                                displayName: playerDirectory.displayName(for: playerId),
                                initials: playerDirectory.initials(for: playerId),
                                isOrganizer: playerId == game.organizerId,
                                teamName: nil
                            )
                            .padding(.horizontal, 16)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Roster")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await playerDirectory.load(userIds: game.playerIds) }
        }
    }
}

struct PlayerRow: View {
    let playerId: String
    let displayName: String
    let initials: String
    let isOrganizer: Bool
    var teamName: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isOrganizer ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray5)))
                    .frame(width: 40, height: 40)
                Text(initials)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundColor(isOrganizer ? .white : .primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .lineLimit(1)
                if isOrganizer {
                    Text("Organizer")
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.accentGreen)
                }
            }

            Spacer()

            if let teamName {
                Text(teamName)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(.systemGray6)))
            }
        }
        .padding(12)
        .glassCard(padding: 0)
    }
}
