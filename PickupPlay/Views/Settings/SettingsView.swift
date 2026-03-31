import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showNotificationPrefs = false
    @State private var showPrivacy = false
    @State private var showSportPrefs = false
    @State private var showLogoutConfirm = false
    @State private var showNotifications = false
    @State private var showGroups = false
    @State private var showAbout = false
    @State private var showTerms = false
    @State private var showPrivacyPolicy = false

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        SettingsRow(icon: "bell.fill", title: "Notification Preferences", color: AppTheme.accentAmber) {
                            showNotificationPrefs = true
                        }
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "lock.shield.fill", title: "Privacy", color: AppTheme.accentCyan) {
                            showPrivacy = true
                        }
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "sportscourt.fill", title: "Sport Preferences", color: AppTheme.accentGreen) {
                            showSportPrefs = true
                        }
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        SettingsRow(icon: "bell.badge.fill", title: "Notification Inbox", color: AppTheme.accentRose) {
                            showNotifications = true
                        }
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "person.3.fill", title: "Groups", color: AppTheme.accentCyan) {
                            showGroups = true
                        }
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        SettingsRow(icon: "info.circle.fill", title: "About PickupPlay", color: .gray) {
                            showAbout = true
                        }
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "doc.text.fill", title: "Terms of Service", color: .gray) {
                            showTerms = true
                        }
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .gray) {
                            showPrivacyPolicy = true
                        }
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    Button(role: .destructive) {
                        showLogoutConfirm = true
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
                    }
                    .padding(.horizontal, 20)

                    Text("PickupPlay v1.0")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showNotificationPrefs) {
            NotificationPrefsView()
        }
        .navigationDestination(isPresented: $showPrivacy) {
            PrivacySettingsView()
        }
        .navigationDestination(isPresented: $showSportPrefs) {
            SportPreferencesView()
        }
        .navigationDestination(isPresented: $showNotifications) {
            NotificationsView()
        }
        .navigationDestination(isPresented: $showGroups) {
            GroupsListView()
        }
        .navigationDestination(isPresented: $showAbout) {
            SettingsInfoView(
                title: "About PickupPlay",
                bodyText: "PickupPlay helps local athletes discover, organize, and join pickup games across many sports. The app combines SwiftUI, Firebase, Core Data, and MapKit to support discovery, coordination, and personal sports history."
            )
        }
        .navigationDestination(isPresented: $showTerms) {
            SettingsInfoView(
                title: "Terms of Service",
                bodyText: "PickupPlay is intended for coordinating recreational sports. Users are responsible for their own safety, venue compliance, and respectful behavior. Availability, attendance, and messaging features are provided on a best-effort basis for demo and school-project use."
            )
        }
        .navigationDestination(isPresented: $showPrivacyPolicy) {
            SettingsInfoView(
                title: "Privacy Policy",
                bodyText: "PickupPlay stores account, profile, game, and preference data to power discovery and social features. Shared content is stored in Firebase services, while local preferences and history are cached on-device with Core Data. Location is only used for nearby discovery features and can be limited in app settings."
            )
        }
        .alert("Sign Out?", isPresented: $showLogoutConfirm) {
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct SettingsRow: View {
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

struct SettingsInfoView: View {
    let title: String
    let bodyText: String

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                Text(bodyText)
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
