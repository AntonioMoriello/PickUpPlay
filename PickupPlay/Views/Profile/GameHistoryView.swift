import SwiftUI

struct GameHistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if profileVM.gameHistory.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No Game History",
                    message: "Completed games will appear here after you finish and record results."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(profileVM.gameHistory) { history in
                            GameHistoryCard(history: history)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Game History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                profileVM.fetchGameHistory(userId: userId)
            }
        }
    }
}

struct GameHistoryCard: View {
    let history: GameHistory

    private var sportName: String {
        Sport.allSports.first(where: { $0.id == history.sportId })?.name ?? history.sportId.capitalized
    }

    private var sportIcon: String {
        Sport.allSports.first(where: { $0.id == history.sportId })?.iconName ?? "sportscourt.fill"
    }

    private var resultColor: Color {
        switch history.result {
        case .win: return AppTheme.accentGreen
        case .loss: return AppTheme.accentRose
        case .draw: return AppTheme.accentAmber
        case .notRecorded: return .gray
        }
    }

    private var resultLabel: String {
        switch history.result {
        case .win:
            return "Win"
        case .loss:
            return "Loss"
        case .draw:
            return "Draw"
        case .notRecorded:
            return "Recorded"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGreen.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: sportIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.gradient)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(sportName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                Text(history.datePlayed, style: .date)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(resultLabel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(resultColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(resultColor.opacity(0.1)))

                if history.attended {
                    Text("Attended")
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .glassCard(padding: 0)
    }
}
