import Foundation

struct SportSkill: Codable, Hashable, Identifiable {
    var sportId: String
    var level: SkillLevel
    var preferredPosition: String
    var gamesPlayedInSport: Int
    var stats: [String: Int]

    var id: String { sportId }
}
