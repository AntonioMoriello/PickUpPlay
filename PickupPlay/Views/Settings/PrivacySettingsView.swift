import SwiftUI

struct PrivacySettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(AppTheme.accentCyan.opacity(0.12))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.accentCyan)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Profile Visibility")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                Text("Who can see your profile")
                                    .font(.caption)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Picker("", selection: $settingsVM.preferences.privacySettings.profileVisibility) {
                                ForEach(PrivacySettings.ProfileVisibility.allCases, id: \.self) { visibility in
                                    Text(visibility.rawValue).tag(visibility)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppTheme.accentGreen)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        Divider().padding(.leading, 56)

                        Toggle(isOn: $settingsVM.preferences.privacySettings.locationSharing) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(AppTheme.accentGreen.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.accentGreen)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Location Sharing")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontDesign(.rounded)
                                    Text("Share your location for nearby game discovery")
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .tint(AppTheme.accentGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        Divider().padding(.leading, 56)

                        Toggle(isOn: $settingsVM.preferences.privacySettings.showOnlineStatus) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(AppTheme.accentAmber.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "wifi")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.accentAmber)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Online Status")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontDesign(.rounded)
                                    Text("Show when you're active on the app")
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .tint(AppTheme.accentGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                settingsVM.loadPreferences(userId: userId)
            }
        }
        .onChange(of: settingsVM.preferences.privacySettings) { _, newValue in
            guard let userId = authViewModel.currentUser?.id else { return }
            settingsVM.updatePrivacy(newValue, userId: userId)
        }
    }
}
