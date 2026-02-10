//
//  AuthService.swift
//  PickupPlay
//
import Foundation
import FirebaseAuth

class AuthService {
    private let auth = FirebaseManager.shared.auth

    func signUp(email: String, password: String) async throws -> AuthDataResult {
        try await auth.createUser(withEmail: email, password: password)
    }

    func signIn(email: String, password: String) async throws -> AuthDataResult {
        try await auth.signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func observeAuthState(_ handler: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        auth.addStateDidChangeListener { _, user in
            handler(user)
        }
    }

    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }
}
