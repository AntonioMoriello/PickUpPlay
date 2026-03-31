import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var iconName: String
    var type: AchievementType
    var sportId: String
    var requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedAt: Date?

    var progressPercent: Double {
        guard requirement > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(requirement))
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_game", name: "First Game", description: "Play your first pickup game", iconName: "figure.run", type: .gamesPlayed, sportId: "", requirement: 1, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "five_games", name: "Getting Started", description: "Play 5 pickup games", iconName: "flame.fill", type: .gamesPlayed, sportId: "", requirement: 5, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "ten_games", name: "Regular Player", description: "Play 10 pickup games", iconName: "star.fill", type: .gamesPlayed, sportId: "", requirement: 10, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "twenty_five_games", name: "Veteran", description: "Play 25 pickup games", iconName: "medal.fill", type: .gamesPlayed, sportId: "", requirement: 25, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "fifty_games", name: "Legend", description: "Play 50 pickup games", iconName: "trophy.fill", type: .milestone, sportId: "", requirement: 50, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "first_organize", name: "Game Maker", description: "Organize your first game", iconName: "plus.circle.fill", type: .gamesOrganized, sportId: "", requirement: 1, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "five_organize", name: "Community Builder", description: "Organize 5 games", iconName: "person.3.fill", type: .gamesOrganized, sportId: "", requirement: 5, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "first_follower", name: "Social Butterfly", description: "Get your first follower", iconName: "person.badge.plus", type: .social, sportId: "", requirement: 1, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "three_day_streak", name: "On a Roll", description: "Play games 3 days in a row", iconName: "bolt.fill", type: .streak, sportId: "", requirement: 3, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
        Achievement(id: "multi_sport", name: "Multi-Sport Athlete", description: "Play 3 different sports", iconName: "sportscourt.fill", type: .sportSpecific, sportId: "", requirement: 3, currentProgress: 0, isUnlocked: false, unlockedAt: nil),
    ]
}
