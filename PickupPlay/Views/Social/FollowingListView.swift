import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if profileVM.isLoading && profileVM.followingList.isEmpty {
                ProgressView("Loading...")
                    .fontDesign(.rounded)
            } else if profileVM.followingList.isEmpty {
                EmptyStateView(
                    icon: "person.2.fill",
                    title: "Not Following Anyone",
                    message: "Follow other players to see their activity and connect for games!"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(profileVM.followingList) { user in
                            NavigationLink(destination: PlayerProfileView(userId: user.id)) {
                                FollowingUserRow(user: user) {
                                    Task {
                                        await profileVM.unfollowUser(user.id)
                                        await authViewModel.refreshCurrentUser()
                                        if let userId = authViewModel.currentUser?.id {
                                            await profileVM.loadProfile(userId: userId)
                                            await profileVM.fetchFollowingList(userId: userId)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Following")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                Task {
                    await profileVM.loadProfile(userId: userId)
                    await profileVM.fetchFollowingList(userId: userId)
                }
            }
        }
        .errorBanner(message: $profileVM.errorMessage)
    }
}

struct FollowingUserRow: View {
    let user: User
    var onUnfollow: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.gradient)
                    .frame(width: 44, height: 44)
                Text(String(user.displayName.prefix(1)).uppercased())
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                Text("\(user.gamesPlayed) games played")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let onUnfollow {
                Button("Unfollow") {
                    onUnfollow()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(AppTheme.accentRose)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(AppTheme.accentRose.opacity(0.1)))
            }
        }
        .padding(14)
        .glassCard(padding: 0)
    }
}
