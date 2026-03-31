import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showStats = false
    @State private var showHistory = false
    @State private var showAchievements = false
    @State private var showFollowing = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        if let user = profileVM.user ?? authViewModel.currentUser {
                            ProfileCardView(user: user, isEditable: true, onEditTap: {
                                showEditProfile = true
                            })
                        }

                        VStack(spacing: 0) {
                            ProfileMenuRow(icon: "chart.bar.fill", title: "Stats Dashboard", color: AppTheme.accentCyan) {
                                showStats = true
                            }
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "clock.arrow.circlepath", title: "Game History", color: AppTheme.accentGreen) {
                                showHistory = true
                            }
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "trophy.fill", title: "Achievements", color: AppTheme.accentAmber) {
                                showAchievements = true
                            }
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "person.2.fill", title: "Following", color: AppTheme.accentCyan) {
                                showFollowing = true
                            }
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "gearshape.fill", title: "Settings", color: .gray) {
                                showSettings = true
                            }
                        }
                        .glassCard(padding: 0)
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showStats) {
                StatsDashboardView()
            }
            .navigationDestination(isPresented: $showHistory) {
                GameHistoryView()
            }
            .navigationDestination(isPresented: $showAchievements) {
                AchievementsView()
            }
            .navigationDestination(isPresented: $showFollowing) {
                FollowingListView()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showEditProfile) {
                NavigationStack {
                    EditProfileView()
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    Task {
                        await authViewModel.refreshCurrentUser()
                        await profileVM.loadProfile(userId: userId)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
                if let userId = authViewModel.currentUser?.id {
                    Task {
                        await authViewModel.refreshCurrentUser()
                        await profileVM.loadProfile(userId: userId)
                    }
                }
            }
        }
    }
}
