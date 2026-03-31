import SwiftUI
import FirebaseCore

@main
struct PickupPlayApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        _ = FirebaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.needsOnboarding {
                    OnboardingContainerView()
                } else {
                    MainTabView()
                }
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authViewModel.needsOnboarding)
    }
}

struct OnboardingContainerView: View {
    @StateObject private var onboardingVM = OnboardingViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch onboardingVM.currentStep {
            case 0:
                SportSelectionView(onboardingVM: onboardingVM)
            case 1:
                SkillLevelSetupView(onboardingVM: onboardingVM)
            case 2:
                LocationPermissionView(onboardingVM: onboardingVM)
            default:
                SportSelectionView(onboardingVM: onboardingVM)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: onboardingVM.currentStep)
        .onChange(of: onboardingVM.isComplete) { _, completed in
            if completed {
                authViewModel.needsOnboarding = false
            }
        }
    }
}

#Preview("Authenticated") {
    MainTabView()
        .environmentObject(AuthViewModel())
}

#Preview("Welcome") {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
