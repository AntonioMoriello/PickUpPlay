import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    let unlocked = profileVM.achievements.filter(\.isUnlocked)
                    let locked = profileVM.achievements.filter { !$0.isUnlocked }

                    HStack(spacing: 12) {
                        StatCard(
                            title: "Unlocked",
                            value: "\(unlocked.count)",
                            icon: "trophy.fill",
                            color: AppTheme.accentAmber
                        )
                        StatCard(
                            title: "Total",
                            value: "\(profileVM.achievements.count)",
                            icon: "medal.fill",
                            color: AppTheme.accentCyan
                        )
                    }
                    .padding(.horizontal, 16)

                    if !unlocked.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Unlocked", icon: "trophy.fill")

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(unlocked) { achievement in
                                    AchievementBadge(achievement: achievement)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    if !locked.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "In Progress", icon: "chart.line.uptrend.xyaxis")

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(locked) { achievement in
                                    AchievementBadge(achievement: achievement)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                Task { await profileVM.fetchAchievements(userId: userId) }
            }
        }
    }
}
