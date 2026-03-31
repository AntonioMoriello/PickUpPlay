import SwiftUI

struct HomeView: View {
    var onCreateGame: () -> Void = {}
    var onOpenMap: () -> Void = {}

    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @State private var animateCards = false
    @State private var showAllGames = false
    @State private var showSportBrowser = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome back,")
                                .font(.title3)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Text(authViewModel.currentUser?.displayName ?? "Player")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.gradient)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        HStack(spacing: 12) {
                            QuickStatCard(
                                title: "Games",
                                value: "\(authViewModel.currentUser?.gamesPlayed ?? 0)",
                                icon: "gamecontroller.fill",
                                color: AppTheme.accentCyan
                            )
                            QuickStatCard(
                                title: "Sports",
                                value: "\(authViewModel.currentUser?.sportSkills.count ?? 0)",
                                icon: "sportscourt.fill",
                                color: AppTheme.accentGreen
                            )
                            QuickStatCard(
                                title: "Rating",
                                value: String(format: "%.1f", authViewModel.currentUser?.reliabilityScore ?? 5.0),
                                icon: "star.fill",
                                color: AppTheme.accentAmber
                            )
                        }
                        .padding(.horizontal, 16)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)

                        HStack(spacing: 12) {
                            QuickActionButton(icon: "plus.circle.fill", title: "Create", color: AppTheme.accentGreen) {
                                onCreateGame()
                            }
                            QuickActionButton(icon: "map.fill", title: "Map", color: AppTheme.accentCyan) {
                                onOpenMap()
                            }
                            QuickActionButton(icon: "magnifyingglass", title: "Browse", color: AppTheme.accentAmber) {
                                showSportBrowser = true
                            }
                        }
                        .padding(.horizontal, 16)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)

                        VStack(spacing: 12) {
                            HStack {
                                SectionHeader(title: "Nearby Games", icon: "mappin.and.ellipse")
                                Spacer()
                                Button("See All") { showAllGames = true }
                                    .font(.subheadline)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(AppTheme.gradient)
                                    .padding(.trailing, 20)
                            }

                            if gameViewModel.isLoading {
                                ProgressView()
                                    .frame(height: 120)
                            } else if gameViewModel.games.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "sportscourt")
                                        .font(.system(size: 32))
                                        .foregroundStyle(AppTheme.gradient)
                                    Text("No nearby games yet")
                                        .font(.subheadline)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.secondary)
                                    Text("Create one or check back later!")
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .glassCard(padding: 0)
                                .padding(.horizontal, 16)
                            } else {
                                ForEach(gameViewModel.games.prefix(3)) { game in
                                    NavigationLink(destination: GameDetailsView(game: game)) {
                                        GameCardView(game: game)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showAllGames) {
                GameListView()
            }
            .navigationDestination(isPresented: $showSportBrowser) {
                SportBrowserView()
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animateCards = true
                }
                Task { await refreshHomeData() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .gamesDidChange)) { _ in
                Task { await gameViewModel.fetchNearbyGames() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
                Task { await authViewModel.refreshCurrentUser() }
            }
            .errorBanner(message: $gameViewModel.errorMessage)
            .loading(isLoading: false)
        }
    }

    private func refreshHomeData() async {
        await authViewModel.refreshCurrentUser()
        await gameViewModel.fetchNearbyGames()
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCard(padding: 0)
        }
    }
}

struct QuickStatCard: View {
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
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassCard(padding: 0)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.gradient)
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
