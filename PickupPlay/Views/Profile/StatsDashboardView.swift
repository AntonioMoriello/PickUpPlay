import SwiftUI

struct StatsDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var selectedPeriod = 0

    private let periods = ["All Time", "This Season", "This Month"]

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(0..<periods.count, id: \.self) { i in
                            Text(periods[i]).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    if let stats = profileVM.stats {
                        HStack(spacing: 12) {
                            StatCard(title: "Games", value: "\(stats.totalGamesPlayed)", icon: "gamecontroller.fill", color: AppTheme.accentCyan)
                            StatCard(title: "Organized", value: "\(stats.totalGamesOrganized)", icon: "plus.circle.fill", color: AppTheme.accentAmber)
                            StatCard(title: "Win Rate", value: String(format: "%.0f%%", stats.winRate), icon: "chart.line.uptrend.xyaxis", color: AppTheme.accentGreen)
                        }
                        .padding(.horizontal, 16)

                        HStack(spacing: 12) {
                            StatCard(title: "Wins", value: "\(stats.wins)", icon: "trophy.fill", color: AppTheme.accentAmber)
                            StatCard(title: "Losses", value: "\(stats.losses)", icon: "xmark.circle", color: AppTheme.accentRose)
                            StatCard(title: "Draws", value: "\(stats.draws)", icon: "equal.circle", color: .gray)
                        }
                        .padding(.horizontal, 16)

                        if !stats.sportBreakdown.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "By Sport", icon: "sportscourt.fill")

                                ForEach(stats.sportBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { sportId, count in
                                    let sportName = Sport.allSports.first(where: { $0.id == sportId })?.name ?? sportId
                                    let total = max(stats.totalGamesPlayed, 1)
                                    HStack {
                                        Text(sportName)
                                            .font(.subheadline)
                                            .fontDesign(.rounded)
                                        Spacer()
                                        Text("\(count) games")
                                            .font(.caption)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)

                                    ProgressView(value: Double(count), total: Double(total))
                                        .tint(AppTheme.accentGreen)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 16)
                            .glassCard(padding: 0)
                            .padding(.horizontal, 16)
                        }
                    } else {
                        EmptyStateView(
                            icon: "chart.bar",
                            title: "No Stats Yet",
                            message: "Play some games to see your statistics!"
                        )
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Stats Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                Task { await profileVM.fetchStats(userId: userId) }
            }
        }
        .onChange(of: selectedPeriod) { _, newValue in
            guard let userId = authViewModel.currentUser?.id else { return }
            Task {
                switch newValue {
                case 1:
                    await profileVM.fetchStats(userId: userId, months: 3)
                case 2:
                    await profileVM.fetchStats(userId: userId, months: 1)
                default:
                    await profileVM.fetchStats(userId: userId)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(padding: 0)
    }
}
