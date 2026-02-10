//
//  SportSelectionView.swift
//  PickupPlay
//
import SwiftUI

struct SportSelectionView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    StepProgressIndicator(currentStep: 0, totalSteps: 3)
                        .padding(.top, 16)

                    Text("Pick Your Sports")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("Select the sports you enjoy playing")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)

                    if !onboardingVM.selectedSports.isEmpty {
                        Text("\(onboardingVM.selectedSports.count) selected")
                            .font(.caption)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(AppTheme.gradient))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.bottom, 16)
                .animation(.spring(response: 0.3), value: onboardingVM.selectedSports.count)

                if let error = onboardingVM.errorMessage {
                    ErrorBanner(message: error) {
                        onboardingVM.errorMessage = nil
                    }
                }

                ScrollView {
                    SportIconGrid(
                        sports: onboardingVM.availableSports,
                        selectedSportIds: Binding(
                            get: { onboardingVM.selectedSports },
                            set: { newValue in
                                let added = newValue.subtracting(onboardingVM.selectedSports)
                                let removed = onboardingVM.selectedSports.subtracting(newValue)
                                for id in added { onboardingVM.selectSport(id) }
                                for id in removed { onboardingVM.deselectSport(id) }
                            }
                        )
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }

                VStack {
                    Button {
                        onboardingVM.nextStep()
                    } label: {
                        Text("Next")
                    }
                    .buttonStyle(AppPrimaryButtonStyle(isEnabled: !onboardingVM.selectedSports.isEmpty))
                    .disabled(onboardingVM.selectedSports.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                .background(.ultraThinMaterial)
            }
        }
        .loading(onboardingVM.isLoading)
        .task {
            await onboardingVM.loadSports()
        }
    }
}

#Preview {
    SportSelectionView(onboardingVM: OnboardingViewModel())
}
