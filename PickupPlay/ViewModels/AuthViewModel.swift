import Foundation
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var needsOnboarding: Bool = false

    private let authService: AuthService
    private let userRepository: UserRepository
    private let sportRepository: SportRepository
    private let demoDataService: DemoDataService
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var isPerformingAuthAction = false

    init() {
        self.authService = AuthService()
        self.userRepository = UserRepository()
        self.sportRepository = SportRepository()
        self.demoDataService = DemoDataService.shared
        observeAuthState()
    }

    func observeAuthState() {
        authStateHandle = authService.observeAuthState { [weak self] firebaseUser in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                guard !self.isPerformingAuthAction else { return }
                if let firebaseUser = firebaseUser {
                    await self.bootstrapAuthenticatedUser(firebaseUser)
                } else {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        isPerformingAuthAction = true
        defer {
            isLoading = false
            isPerformingAuthAction = false
        }

        do {
            let result = try await authService.signUp(email: email, password: password)
            let newUser = User.newUser(id: result.user.uid, email: email, displayName: displayName)
            try await userRepository.updateUser(newUser)
            try? await sportRepository.populateSportsIfNeeded()
            if let bootstrappedUser = await demoDataService.prepareSignedInExperience(for: result.user) {
                self.currentUser = User(
                    id: bootstrappedUser.id,
                    email: bootstrappedUser.email,
                    displayName: displayName,
                    profileImageURL: bootstrappedUser.profileImageURL,
                    createdAt: bootstrappedUser.createdAt,
                    currentLocation: bootstrappedUser.currentLocation,
                    sportSkills: bootstrappedUser.sportSkills,
                    favoriteSports: bootstrappedUser.favoriteSports,
                    favoriteVenueIds: bootstrappedUser.favoriteVenueIds,
                    followingIds: bootstrappedUser.followingIds,
                    followerIds: bootstrappedUser.followerIds,
                    groupIds: bootstrappedUser.groupIds,
                    reliabilityScore: bootstrappedUser.reliabilityScore,
                    gamesPlayed: bootstrappedUser.gamesPlayed,
                    gamesOrganized: bootstrappedUser.gamesOrganized,
                    profileVisibility: bootstrappedUser.profileVisibility,
                    locationSharingEnabled: bootstrappedUser.locationSharingEnabled,
                    showOnlineStatusEnabled: bootstrappedUser.showOnlineStatusEnabled,
                    fcmToken: bootstrappedUser.fcmToken
                )
                try await userRepository.updateUser(id: result.user.uid, data: [
                    "displayName": displayName
                ])
            } else {
                self.currentUser = newUser
            }
            self.isAuthenticated = true
            self.needsOnboarding = true
            AppEvents.post(.profileDidChange)
        } catch {
            self.errorMessage = mapAuthError(error)
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await authService.signIn(email: email, password: password)
            await bootstrapAuthenticatedUser(result.user)
        } catch {
            self.errorMessage = mapAuthError(error)
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
            self.needsOnboarding = false
        } catch {
            self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await authService.resetPassword(email: email)
        } catch {
            self.errorMessage = mapAuthError(error)
        }
    }

    func refreshCurrentUser() async {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid ?? currentUser?.id else { return }
        await loadUser(id: userId)
    }

    private func loadUser(id: String) async {
        do {
            if let user = try await userRepository.getUser(id: id) {
                self.currentUser = user
                self.needsOnboarding = user.sportSkills.isEmpty
            } else if let firebaseUser = authService.currentUser, firebaseUser.uid == id,
                      let user = try? await demoDataService.ensureUserProfile(for: firebaseUser) {
                self.currentUser = user
                self.needsOnboarding = user.sportSkills.isEmpty
            }
        } catch {
            self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
        }
    }

    private func bootstrapAuthenticatedUser(_ firebaseUser: FirebaseAuth.User) async {
        isAuthenticated = true
        if let user = await demoDataService.prepareSignedInExperience(for: firebaseUser) {
            currentUser = user
            needsOnboarding = user.sportSkills.isEmpty
        } else {
            await loadUser(id: firebaseUser.uid)
        }
    }

    private func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else {
            return error.localizedDescription
        }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .wrongPassword, .invalidCredential:
            return "Incorrect email or password."
        case .userNotFound:
            return "No account found with this email."
        case .networkError:
            return "Network error. Please check your connection."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        default:
            return error.localizedDescription
        }
    }
}
