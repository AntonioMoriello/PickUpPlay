//
//  GameCardView.swift
//  PickupPlay
//
import SwiftUI
import FirebaseFirestore

struct GameCardView: View {
    let game: Game
    var onTap: (() -> Void)? = nil

    private var sportName: String {
        Sport.allSports.first(where: { $0.id == game.sportId })?.name ?? game.sportId.capitalized
    }

    private var sportIcon: String {
        Sport.allSports.first(where: { $0.id == game.sportId })?.iconName ?? "sportscourt.fill"
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentGreen.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: sportIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.gradient)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.title)
                            .font(.headline)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text(sportName)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    StatusBadge(status: game.status)
                }

                HStack(spacing: 16) {
                    Label {
                        Text(game.dateTime, style: .date)
                            .font(.caption)
                            .fontDesign(.rounded)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    Label {
                        Text(game.dateTime, style: .time)
                            .font(.caption)
                            .fontDesign(.rounded)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(game.currentPlayers)/\(game.maxPlayers)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                    .foregroundColor(game.isFull ? AppTheme.accentRose : AppTheme.accentGreen)
                }

                HStack(spacing: 8) {
                    SkillLevelBadge(level: game.skillLevel)
                    
                    if game.spotsLeft > 0 {
                        Text("\(game.spotsLeft) spots left")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundColor(AppTheme.accentGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.accentGreen.opacity(0.1)))
                    } else {
                        Text("Full")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundColor(AppTheme.accentRose)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.accentRose.opacity(0.1)))
                    }
                }
            }
            .padding(16)
            .glassCard(padding: 0)
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    let status: GameStatus

    private var color: Color {
        switch status {
        case .upcoming: return AppTheme.accentGreen
        case .inProgress: return AppTheme.accentAmber
        case .completed: return AppTheme.accentCyan
        case .cancelled: return AppTheme.accentRose
        case .draft: return .gray
        }
    }

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}
