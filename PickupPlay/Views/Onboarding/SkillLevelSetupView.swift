//
//  SkillLevelSetupView.swift
//  PickupPlay
//
import SwiftUI

struct SkillLevelSetupView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel

    private var selectedSportsList: [Sport] {
        onboardingVM.availableSports.filter { onboardingVM.selectedSports.contains($0.id) }
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    StepProgressIndicator(currentStep: 1, totalSteps: 3)
                        .padding(.top, 16)

                    Text("Set Your Skill Levels")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("How skilled are you in each sport?")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 16)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(selectedSportsList) { sport in
                            SkillLevelCard(
                                sport: sport,
                                selectedLevel: Binding(
                                    get: { onboardingVM.skillLevels[sport.id] ?? .beginner },
                                    set: { onboardingVM.setSkillLevel(sportId: sport.id, level: $0) }
                                )
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }

                VStack(spacing: 10) {
                    Button {
                        onboardingVM.nextStep()
                    } label: {
                        Text("Next")
                    }
                    .buttonStyle(AppPrimaryButtonStyle())

                    Button {
                        onboardingVM.previousStep()
                    } label: {
                        Text("Back")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .background(.ultraThinMaterial)
            }
        }
    }
}

struct SkillLevelCard: View {
    let sport: Sport
    @Binding var selectedLevel: SkillLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentGreen.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: sport.iconName)
                        .font(.title3)
                        .foregroundStyle(AppTheme.gradient)
                }

                Text(sport.name)
                    .font(.headline)
                    .fontDesign(.rounded)

                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(SkillLevel.allCases) { level in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLevel = level
                        }
                    } label: {
                        Text(level.displayName)
                            .font(.caption)
                            .fontWeight(selectedLevel == level ? .bold : .medium)
                            .fontDesign(.rounded)
                            .foregroundColor(selectedLevel == level ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedLevel == level ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray6)))
                            )
                            .shadow(
                                color: selectedLevel == level ? AppTheme.accentGreen.opacity(0.3) : .clear,
                                radius: 6,
                                y: 3
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .glassCard()
    }
}

#Preview {
    let vm = OnboardingViewModel()
    SkillLevelSetupView(onboardingVM: vm)
        .onAppear {
            vm.selectSport("basketball")
            vm.selectSport("soccer")
            vm.selectSport("tennis")
            vm.availableSports = Sport.allSports
        }
}
