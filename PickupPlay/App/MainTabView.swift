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
            HomeView(
                onCreateGame: {
                    showCreateGame = true
                },
                onOpenMap: {
                    selectedTab = .map
                }
            )
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

            MessagesListView()
                .tabItem {
                    Label(Tab.messages.rawValue, systemImage: Tab.messages.iconName)
                }
                .tag(Tab.messages)

            MyProfileView()
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

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
