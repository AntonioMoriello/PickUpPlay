import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Hashable {
    let id: String
    var email: String
    var displayName: String
    var profileImageURL: String
    var createdAt: Date
    var currentLocation: GeoPoint
    var sportSkills: [SportSkill]
    var favoriteSports: [String]
    var favoriteVenueIds: [String]
    var followingIds: [String]
    var followerIds: [String]
    var groupIds: [String]
    var reliabilityScore: Double
    var gamesPlayed: Int
    var gamesOrganized: Int
    var profileVisibility: PrivacySettings.ProfileVisibility? = .everyone
    var locationSharingEnabled: Bool? = true
    var showOnlineStatusEnabled: Bool? = true
    var fcmToken: String? = nil

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User {
    static func newUser(id: String, email: String, displayName: String) -> User {
        User(
            id: id,
            email: email,
            displayName: displayName,
            profileImageURL: "",
            createdAt: Date(),
            currentLocation: GeoPoint(latitude: 0, longitude: 0),
            sportSkills: [],
            favoriteSports: [],
            favoriteVenueIds: [],
            followingIds: [],
            followerIds: [],
            groupIds: [],
            reliabilityScore: 5.0,
            gamesPlayed: 0,
            gamesOrganized: 0,
            profileVisibility: .everyone,
            locationSharingEnabled: true,
            showOnlineStatusEnabled: true,
            fcmToken: nil
        )
    }
}
