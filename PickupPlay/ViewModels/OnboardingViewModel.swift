//
//  OnboardingViewModel.swift
//  PickupPlay
//
import Foundation
import Combine
import CoreLocation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedSports: Set<String> = []
    @Published var skillLevels: [String: SkillLevel] = [:]
    @Published var currentStep: Int = 0
    @Published var isComplete: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var availableSports: [Sport] = []

    private let userRepository: UserRepository
    private let sportRepository: SportRepository

    init() {
        self.userRepository = UserRepository()
        self.sportRepository = SportRepository()
    }

    func loadSports() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let sports = try await sportRepository.getAllSports()
            self.availableSports = sports.isEmpty ? Sport.allSports : sports
        } catch {
            self.errorMessage = "Failed to load sports: \(error.localizedDescription)"
            self.availableSports = Sport.allSports
        }
    }

    func selectSport(_ sportId: String) {
        selectedSports.insert(sportId)
        if skillLevels[sportId] == nil {
            skillLevels[sportId] = .beginner
        }
    }

    func deselectSport(_ sportId: String) {
        selectedSports.remove(sportId)
        skillLevels.removeValue(forKey: sportId)
    }

    func toggleSport(_ sportId: String) {
        if selectedSports.contains(sportId) {
            deselectSport(sportId)
        } else {
            selectSport(sportId)
        }
    }

    func setSkillLevel(sportId: String, level: SkillLevel) {
        skillLevels[sportId] = level
    }

    func nextStep() {
        currentStep += 1
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func complete(userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let sportSkills: [SportSkill] = selectedSports.map { sportId in
                SportSkill(
                    sportId: sportId,
                    level: skillLevels[sportId] ?? .beginner,
                    preferredPosition: "",
                    gamesPlayedInSport: 0,
                    stats: [:]
                )
            }

            try await userRepository.updateUser(id: userId, data: [
                "sportSkills": try sportSkills.map { try Firestore.Encoder().encode($0) },
                "favoriteSports": Array(selectedSports)
            ])

            self.isComplete = true
        } catch {
            self.errorMessage = "Failed to save preferences: \(error.localizedDescription)"
        }
    }
}

import FirebaseFirestore
