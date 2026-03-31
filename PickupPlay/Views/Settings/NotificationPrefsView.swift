import SwiftUI

struct NotificationPrefsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        NotificationToggle(title: "Game Invites", icon: "envelope.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.gameInvite)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Game Updates", icon: "arrow.triangle.2.circlepath",
                            isOn: $settingsVM.preferences.notificationPrefs.gameUpdate)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Game Reminders", icon: "bell.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.gameReminder)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Game Cancelled", icon: "xmark.circle.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.gameCancelled)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Player Joined", icon: "person.badge.plus",
                            isOn: $settingsVM.preferences.notificationPrefs.playerJoined)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Player Left", icon: "person.badge.minus",
                            isOn: $settingsVM.preferences.notificationPrefs.playerLeft)
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        NotificationToggle(title: "New Messages", icon: "message.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.newMessage)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "New Followers", icon: "person.fill.badge.plus",
                            isOn: $settingsVM.preferences.notificationPrefs.newFollower)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Achievements", icon: "trophy.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.achievementUnlocked)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Ratings", icon: "star.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.ratingReceived)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Group Invites", icon: "person.3.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.groupInvite)
                        Divider().padding(.leading, 56)
                        NotificationToggle(title: "Group Updates", icon: "person.3.sequence.fill",
                            isOn: $settingsVM.preferences.notificationPrefs.groupUpdate)
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                settingsVM.loadPreferences(userId: userId)
            }
        }
        .onChange(of: settingsVM.preferences.notificationPrefs) { _, newValue in
            guard let userId = authViewModel.currentUser?.id else { return }
            settingsVM.updateNotificationPrefs(newValue, userId: userId)
        }
    }
}

struct NotificationToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppTheme.accentGreen.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accentGreen)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
            }
        }
        .tint(AppTheme.accentGreen)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
