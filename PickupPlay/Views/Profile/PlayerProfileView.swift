import SwiftUI

struct PlayerProfileView: View {
    let userId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showStats = false

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    if let user = profileVM.user {
                        if profileVM.canViewProfileDetails() {
                            ProfileCardView(
                                user: user,
                                isEditable: false,
                                onFollowTap: { Task { await toggleFollowStatus() } },
                                isFollowing: profileVM.isFollowing(userId: userId)
                            )

                            if !profileVM.gameHistory.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    SectionHeader(title: "Recent Games", icon: "clock.arrow.circlepath")

                                    ForEach(profileVM.gameHistory.prefix(5)) { history in
                                        HStack {
                                            let sportName = Sport.allSports.first(where: { $0.id == history.sportId })?.name ?? history.sportId
                                            Image(systemName: Sport.allSports.first(where: { $0.id == history.sportId })?.iconName ?? "sportscourt.fill")
                                                .foregroundStyle(AppTheme.gradient)
                                            Text(sportName)
                                                .font(.subheadline)
                                                .fontDesign(.rounded)
                                            Spacer()
                                            Text(history.datePlayed, style: .date)
                                                .font(.caption)
                                                .fontDesign(.rounded)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                                .padding(.vertical, 12)
                                .glassCard(padding: 0)
                                .padding(.horizontal, 16)
                            }
                        } else {
                            HiddenProfileCard(
                                user: user,
                                isFollowing: profileVM.isFollowing(userId: userId),
                                onFollowTap: { Task { await toggleFollowStatus() } }
                            )
                            .padding(.horizontal, 16)
                        }
                    } else if profileVM.isLoading {
                        ProgressView()
                            .frame(height: 200)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await profileVM.loadProfile(userId: userId)
                if profileVM.canViewProfileDetails() {
                    profileVM.fetchGameHistory(userId: userId)
                }
            }
        }
        .loading(isLoading: profileVM.isLoading)
        .errorBanner(message: $profileVM.errorMessage)
    }

    private func toggleFollowStatus() async {
        if profileVM.isFollowing(userId: userId) {
            await profileVM.unfollowUser(userId)
        } else {
            await profileVM.followUser(userId)
        }

        await authViewModel.refreshCurrentUser()
        if profileVM.canViewProfileDetails() {
            profileVM.fetchGameHistory(userId: userId)
        }
    }
}

struct HiddenProfileCard: View {
    let user: User
    let isFollowing: Bool
    let onFollowTap: () -> Void

    private var privacyMessage: String {
        switch user.profileVisibility ?? .everyone {
        case .everyone:
            return "This profile is public."
        case .followersOnly:
            return "This profile is visible to followers only."
        case .nobody:
            return "This player has chosen to keep profile details private."
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.gradient)
                    .frame(width: 84, height: 84)
                Text(String(user.displayName.prefix(1)).uppercased())
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Text(user.displayName)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)

            Text(privacyMessage)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                onFollowTap()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isFollowing ? "person.badge.minus" : "person.badge.plus")
                    Text(isFollowing ? "Unfollow" : "Follow")
                }
            }
            .buttonStyle(AppPrimaryButtonStyle())
        }
        .padding(20)
        .glassCard(padding: 0)
    }
}
