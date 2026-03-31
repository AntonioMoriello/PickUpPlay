import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var selectedSports: Set<String> = []
    @State private var skillLevels: [String: SkillLevel] = [:]

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: AppTheme.accentGreen.opacity(0.3), radius: 16, y: 8)

                        Text(String(displayName.prefix(1)).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                        TextField("Your name", text: $displayName)
                            .modernInput()
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sport Preferences")
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

                    if !selectedSports.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Skill Levels")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 20)

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
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    Button("Save Changes") {
                        saveProfile()
                    }
                    .buttonStyle(AppPrimaryButtonStyle())
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
                    .fontDesign(.rounded)
            }
        }
        .onAppear {
            if let user = authViewModel.currentUser {
                displayName = user.displayName
                selectedSports = Set(user.sportSkills.map(\.sportId))
                for skill in user.sportSkills {
                    skillLevels[skill.sportId] = skill.level
                }
            }
        }
        .loading(isLoading: profileVM.isLoading)
        .errorBanner(message: $profileVM.errorMessage)
    }

    private func saveProfile() {
        guard let userId = authViewModel.currentUser?.id else { return }
        Task {
            let sportSkills: [SportSkill] = selectedSports.map { sportId in
                SportSkill(
                    sportId: sportId,
                    level: skillLevels[sportId] ?? .beginner,
                    preferredPosition: "",
                    gamesPlayedInSport: authViewModel.currentUser?.sportSkills.first(where: { $0.sportId == sportId })?.gamesPlayedInSport ?? 0,
                    stats: [:]
                )
            }
            let encoded = try? sportSkills.map { try FirebaseFirestore.Firestore.Encoder().encode($0) }
            await profileVM.updateProfile([
                "displayName": displayName,
                "sportSkills": encoded ?? [],
                "favoriteSports": Array(selectedSports)
            ])
            await authViewModel.refreshCurrentUser()
            AppEvents.post(.profileDidChange)
            dismiss()
        }
    }
}

import FirebaseFirestore
