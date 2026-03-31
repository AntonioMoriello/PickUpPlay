import Foundation
import CoreData

struct PlayerStats {
    var totalGamesPlayed: Int
    var totalGamesOrganized: Int
    var wins: Int
    var losses: Int
    var draws: Int
    var sportBreakdown: [String: Int]
    var winRate: Double {
        let total = wins + losses + draws
        guard total > 0 else { return 0 }
        return Double(wins) / Double(total) * 100
    }
}

class StatsRepository {
    private let context = CoreDataManager.shared.context

    func getOverallStats(userId: String, organizedGamesCount: Int = 0) -> PlayerStats {
        let history = fetchHistory(userId: userId)

        var sportBreakdown: [String: Int] = [:]
        var wins = 0, losses = 0, draws = 0

        for game in history {
            sportBreakdown[game.sportId ?? "", default: 0] += 1
            switch GameResult(rawValue: game.result ?? "") {
            case .win: wins += 1
            case .loss: losses += 1
            case .draw: draws += 1
            default: break
            }
        }

        return PlayerStats(
            totalGamesPlayed: history.count,
            totalGamesOrganized: organizedGamesCount,
            wins: wins,
            losses: losses,
            draws: draws,
            sportBreakdown: sportBreakdown
        )
    }

    func getSportStats(userId: String, sportId: String, organizedGamesCount: Int = 0) -> PlayerStats {
        let request: NSFetchRequest<CDGameHistory> = CDGameHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND sportId == %@ AND attended == YES", userId, sportId)

        let history = uniqueHistory((try? context.fetch(request)) ?? [])

        var wins = 0, losses = 0, draws = 0
        for game in history {
            switch GameResult(rawValue: game.result ?? "") {
            case .win: wins += 1
            case .loss: losses += 1
            case .draw: draws += 1
            default: break
            }
        }

        return PlayerStats(
            totalGamesPlayed: history.count,
            totalGamesOrganized: organizedGamesCount,
            wins: wins,
            losses: losses,
            draws: draws,
            sportBreakdown: [sportId: history.count]
        )
    }

    func getSeasonSummary(userId: String, months: Int = 3, organizedGamesCount: Int = 0) -> PlayerStats {
        let cutoff = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
        let request: NSFetchRequest<CDGameHistory> = CDGameHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND datePlayed >= %@ AND attended == YES", userId, cutoff as NSDate)

        let history = uniqueHistory((try? context.fetch(request)) ?? [])

        var sportBreakdown: [String: Int] = [:]
        var wins = 0, losses = 0, draws = 0

        for game in history {
            sportBreakdown[game.sportId ?? "", default: 0] += 1
            switch GameResult(rawValue: game.result ?? "") {
            case .win: wins += 1
            case .loss: losses += 1
            case .draw: draws += 1
            default: break
            }
        }

        return PlayerStats(
            totalGamesPlayed: history.count,
            totalGamesOrganized: organizedGamesCount,
            wins: wins,
            losses: losses,
            draws: draws,
            sportBreakdown: sportBreakdown
        )
    }

    private func fetchHistory(userId: String) -> [CDGameHistory] {
        let request: NSFetchRequest<CDGameHistory> = CDGameHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND attended == YES", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "datePlayed", ascending: false)]
        return uniqueHistory((try? context.fetch(request)) ?? [])
    }

    private func uniqueHistory(_ history: [CDGameHistory]) -> [CDGameHistory] {
        var seenGameIds = Set<String>()

        return history.filter { item in
            let gameId = item.gameId ?? item.id ?? UUID().uuidString
            return seenGameIds.insert(gameId).inserted
        }
    }
}
