import SwiftUI

struct SportPreferencesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSports: Set<String> = []
    @State private var skillLevels: [String: SkillLevel] = [:]
    @State private var showSaved = false

    private let userRepository = UserRepository()
    private let userPrefsRepo = UserPrefsRepo()

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Favorite Sports")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .padding(.horizontal, 20)

                        SportIconGrid(
                            sports: Sport.allSports,
                            selectedSportIds: $selectedSports
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)

                    if !selectedSports.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Skill Levels")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                ForEach(Array(selectedSports).sorted(), id: \.self) { sportId in
                                    let sportName = Sport.allSports.first(where: { $0.id == sportId })?.name ?? sportId
                                    HStack {
                                        Text(sportName)
                                            .font(.subheadline)
                                            .fontDesign(.rounded)
                                        Spacer()
                                        Picker("", selection: Binding(
                                            get: { skillLevels[sportId] ?? .beginner },
                                            set: { skillLevels[sportId] = $0 }
                                        )) {
                                            ForEach(SkillLevel.allCases, id: \.self) { level in
                                                Text(level.displayName).tag(level)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .tint(AppTheme.accentGreen)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)

                                    if sportId != Array(selectedSports).sorted().last {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                            .glassCard(padding: 0)
                            .padding(.horizontal, 16)
                        }
                    }

                    Button("Save Preferences") {
                        savePreferences()
                    }
                    .buttonStyle(AppPrimaryButtonStyle())
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Sport Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let user = authViewModel.currentUser {
                selectedSports = Set(user.sportSkills.map(\.sportId))
                for skill in user.sportSkills {
                    skillLevels[skill.sportId] = skill.level
                }
            }
        }
        .alert("Preferences Saved!", isPresented: $showSaved) {
            Button("OK") {}
        }
    }

    private func savePreferences() {
        guard let userId = authViewModel.currentUser?.id else { return }
        let sportSkills: [SportSkill] = selectedSports.map { sportId in
            SportSkill(
                sportId: sportId,
                level: skillLevels[sportId] ?? .beginner,
                preferredPosition: "",
                gamesPlayedInSport: authViewModel.currentUser?.sportSkills.first(where: { $0.sportId == sportId })?.gamesPlayedInSport ?? 0,
                stats: [:]
            )
        }
        Task {
            do {
                try await userRepository.updateSportSkills(userId: userId, sportSkills: sportSkills)
                try await userRepository.updateUser(id: userId, data: ["favoriteSports": Array(selectedSports)])
                userPrefsRepo.savePrefs(
                    userId: userId,
                    sportFilter: Array(selectedSports).sorted().first,
                    sportPreferences: SportPreferences(
                        favoriteSports: Array(selectedSports).sorted(),
                        skillLevels: skillLevels
                    )
                )
                await authViewModel.refreshCurrentUser()
                AppEvents.post(.profileDidChange)
                showSaved = true
            } catch {
                print("Error saving preferences: \(error)")
            }
        }
    }
}
