import SwiftUI
import Combine
import CoreLocation

struct LocationPermissionView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationManager = LocationPermissionManager()
    @State private var animatePulse = false
    @State private var awaitingPermissionDecision = false

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 32) {
                StepProgressIndicator(currentStep: 2, totalSteps: 3)
                    .padding(.top, 16)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(AppTheme.accentGreen.opacity(0.15), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(animatePulse ? 1.2 : 0.9)
                        .opacity(animatePulse ? 0 : 0.6)

                    Circle()
                        .stroke(AppTheme.accentCyan.opacity(0.15), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(animatePulse ? 1.3 : 1.0)
                        .opacity(animatePulse ? 0 : 0.4)

                    Circle()
                        .fill(AppTheme.accentGreen.opacity(0.12))
                        .frame(width: 120, height: 120)

                    Image(systemName: "location.fill")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(AppTheme.gradient)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        animatePulse = true
                    }
                }

                VStack(spacing: 12) {
                    Text("Enable Location")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("Allow PickupPlay to use your location to find nearby games and venues in your area.")
                        .font(.body)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        if locationManager.authorizationStatus == .notDetermined {
                            awaitingPermissionDecision = true
                            locationManager.requestPermission()
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                            Text("Enable Location")
                        }
                    }
                    .buttonStyle(AppPrimaryButtonStyle())

                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip for Now")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }

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
                .padding(.bottom, 40)
            }
        }
        .loading(onboardingVM.isLoading, message: "Saving preferences...")
        .onChange(of: locationManager.authorizationStatus) { _, newValue in
            guard awaitingPermissionDecision else { return }
            guard newValue != .notDetermined else { return }

            awaitingPermissionDecision = false
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        guard let userId = authViewModel.currentUser?.id else { return }
        Task {
            await onboardingVM.complete(userId: userId)
            if onboardingVM.isComplete {
                authViewModel.needsOnboarding = false
            }
        }
    }
}

class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}

#Preview {
    LocationPermissionView(onboardingVM: OnboardingViewModel())
        .environmentObject(AuthViewModel())
}
