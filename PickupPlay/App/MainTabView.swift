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

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.iconName)
                }
                .tag(Tab.home)

            MapViewStub()
                .tabItem {
                    Label(Tab.map.rawValue, systemImage: Tab.map.iconName)
                }
                .tag(Tab.map)

            CreateGamePlaceholder()
                .tabItem {
                    Label(Tab.create.rawValue, systemImage: Tab.create.iconName)
                }
                .tag(Tab.create)

            MessagesPlaceholder()
                .tabItem {
                    Label(Tab.messages.rawValue, systemImage: Tab.messages.iconName)
                }
                .tag(Tab.messages)

            ProfilePlaceholder()
                .tabItem {
                    Label(Tab.profile.rawValue, systemImage: Tab.profile.iconName)
                }
                .tag(Tab.profile)
        }
        .tint(AppTheme.accentGreen)
    }
}

struct CreateGamePlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentGreen.opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(AppTheme.gradient)
                    }

                    Text("Create Game")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)

                    Text("Coming soon")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Create Game")
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

                    Text("Coming soon")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Messages")
        }
    }
}

struct ProfilePlaceholder: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.gradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: AppTheme.accentGreen.opacity(0.3), radius: 16, y: 8)

                        Text(String((authViewModel.currentUser?.displayName ?? "P").prefix(1)).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

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

                    Text("Full profile coming soon")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(.systemGray6)))

                    Spacer()

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
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
