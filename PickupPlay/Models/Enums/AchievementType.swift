import Foundation

enum AchievementType: String, Codable, CaseIterable {
    case gamesPlayed = "GAMES_PLAYED"
    case gamesOrganized = "GAMES_ORGANIZED"
    case sportSpecific = "SPORT_SPECIFIC"
    case streak = "STREAK"
    case social = "SOCIAL"
    case milestone = "MILESTONE"

    var displayName: String {
        switch self {
        case .gamesPlayed: return "Games Played"
        case .gamesOrganized: return "Games Organized"
        case .sportSpecific: return "Sport Specific"
        case .streak: return "Streak"
        case .social: return "Social"
        case .milestone: return "Milestone"
        }
    }
}
