import Foundation

enum NotificationType: String, Codable, CaseIterable {
    case gameInvite = "GAME_INVITE"
    case gameUpdate = "GAME_UPDATE"
    case gameReminder = "GAME_REMINDER"
    case gameCancelled = "GAME_CANCELLED"
    case playerJoined = "PLAYER_JOINED"
    case playerLeft = "PLAYER_LEFT"
    case newMessage = "NEW_MESSAGE"
    case newFollower = "NEW_FOLLOWER"
    case achievementUnlocked = "ACHIEVEMENT_UNLOCKED"
    case ratingReceived = "RATING_RECEIVED"
    case groupInvite = "GROUP_INVITE"
    case groupUpdate = "GROUP_UPDATE"

    var displayName: String {
        switch self {
        case .gameInvite: return "Game Invite"
        case .gameUpdate: return "Game Update"
        case .gameReminder: return "Game Reminder"
        case .gameCancelled: return "Game Cancelled"
        case .playerJoined: return "Player Joined"
        case .playerLeft: return "Player Left"
        case .newMessage: return "New Message"
        case .newFollower: return "New Follower"
        case .achievementUnlocked: return "Achievement Unlocked"
        case .ratingReceived: return "Rating Received"
        case .groupInvite: return "Group Invite"
        case .groupUpdate: return "Group Update"
        }
    }

    var iconName: String {
        switch self {
        case .gameInvite: return "envelope.fill"
        case .gameUpdate: return "arrow.triangle.2.circlepath"
        case .gameReminder: return "bell.fill"
        case .gameCancelled: return "xmark.circle.fill"
        case .playerJoined: return "person.badge.plus"
        case .playerLeft: return "person.badge.minus"
        case .newMessage: return "message.fill"
        case .newFollower: return "person.fill.badge.plus"
        case .achievementUnlocked: return "trophy.fill"
        case .ratingReceived: return "star.fill"
        case .groupInvite: return "person.3.fill"
        case .groupUpdate: return "person.3.sequence.fill"
        }
    }
}
