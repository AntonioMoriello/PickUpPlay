//
//  MainTabView.swift
//  PickupPlay
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home = "Home"
        case map = "Map"
        case create = "Create"
        case messages = "Messages"
        case profile = "Profile"

        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .map: return "map.fill"
            case .create: return "plus.circle.fill"
            case .messages: return "message.fill"
            case .profile: return "person.fill"
            }
        }
    }

    @State private var showCreateGame = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.iconName)
                }
                .tag(Tab.home)

            GameMapView()
                .tabItem {
                    Label(Tab.map.rawValue, systemImage: Tab.map.iconName)
                }
                .tag(Tab.map)

            Color.clear
                .tabItem {
                    Label(Tab.create.rawValue, systemImage: Tab.create.iconName)
                }
                .tag(Tab.create)

            MessagesPlaceholder()
                .tabItem {
                    Label(Tab.messages.rawValue, systemImage: Tab.messages.iconName)
                }
                .tag(Tab.messages)

            ProfileTab()
                .tabItem {
                    Label(Tab.profile.rawValue, systemImage: Tab.profile.iconName)
                }
                .tag(Tab.profile)
        }
        .tint(AppTheme.accentGreen)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .create {
                showCreateGame = true
                selectedTab = .home
            }
        }
        .fullScreenCover(isPresented: $showCreateGame) {
            CreateGameView()
                .environmentObject(authViewModel)
        }
    }
}

struct ProfileTab: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSportBrowser = false
    @State private var showSavedVenues = false
    @State private var showVenueMap = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.gradient)
                                .frame(width: 100, height: 100)
                                .shadow(color: AppTheme.accentGreen.opacity(0.3), radius: 16, y: 8)

                            Text(String((authViewModel.currentUser?.displayName ?? "P").prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 16)

                        VStack(spacing: 6) {
                            Text(authViewModel.currentUser?.displayName ?? "Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 12) {
                            QuickStatCard(
                                title: "Games",
                                value: "\(authViewModel.currentUser?.gamesPlayed ?? 0)",
                                icon: "gamecontroller.fill",
                                color: AppTheme.accentCyan
                            )
                            QuickStatCard(
                                title: "Organized",
                                value: "\(authViewModel.currentUser?.gamesOrganized ?? 0)",
                                icon: "star.fill",
                                color: AppTheme.accentAmber
                            )
                            QuickStatCard(
                                title: "Rating",
                                value: String(format: "%.1f", authViewModel.currentUser?.reliabilityScore ?? 5.0),
                                icon: "heart.fill",
                                color: AppTheme.accentGreen
                            )
                        }
                        .padding(.horizontal, 16)

                        VStack(spacing: 0) {
                            ProfileMenuRow(icon: "sportscourt.fill", title: "Browse Sports", color: AppTheme.accentGreen) {
                                showSportBrowser = true
                            }
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "map.fill", title: "Venue Map", color: AppTheme.accentCyan) {
                                showVenueMap = true
                            }
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "heart.fill", title: "Saved Venues", color: AppTheme.accentRose) {
                                showSavedVenues = true
                            }
                        }
                        .glassCard(padding: 0)
                        .padding(.horizontal, 16)

                        Button(role: .destructive) {
                            authViewModel.signOut()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .font(.headline)
                            .fontDesign(.rounded)
                            .foregroundColor(AppTheme.accentRose)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous)
                                    .fill(AppTheme.accentRose.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous)
                                    .strokeBorder(AppTheme.accentRose.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(isPresented: $showSportBrowser) {
                SportBrowserView()
            }
            .navigationDestination(isPresented: $showSavedVenues) {
                SavedVenuesView()
            }
            .navigationDestination(isPresented: $showVenueMap) {
                VenueMapView()
            }
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct MessagesPlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentCyan.opacity(0.12))
                            .frame(width: 100, height: 100)
                        Image(systemName: "message.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(AppTheme.gradient)
                    }

                    Text("Messages")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)

                    Text("Chat with your teammates.\nComing in the next update!")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Messages")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
