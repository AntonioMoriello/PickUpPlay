import Foundation
import Combine

@MainActor
final class PlayerDirectoryViewModel: ObservableObject {
    @Published private(set) var usersById: [String: User] = [:]

    private let userRepository = UserRepository()

    func load(userIds: [String]) async {
        let missingIds = userIds.filter { usersById[$0] == nil }
        guard !missingIds.isEmpty else { return }

        for userId in missingIds {
            if let user = try? await userRepository.getUser(id: userId) {
                usersById[userId] = user
            }
        }
    }

    func displayName(for userId: String) -> String {
        usersById[userId]?.displayName ?? userId
    }

    func initials(for userId: String) -> String {
        if let displayName = usersById[userId]?.displayName,
           let first = displayName.first {
            return String(first).uppercased()
        }

        return String(userId.prefix(1)).uppercased()
    }
}
