import Foundation
import CoreData

class CacheRepository {
    private let context = CoreDataManager.shared.context
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func cacheGames(_ games: [Game]) {
        clearOldCache()

        for game in games {
            guard let data = try? encoder.encode(game) else { continue }
            let request: NSFetchRequest<CDCachedGame> = CDCachedGame.fetchRequest()
            request.predicate = NSPredicate(format: "gameId == %@", game.id)

            let existing = (try? context.fetch(request))?.first

            let entity = existing ?? CDCachedGame(context: context)
            entity.gameId = game.id
            entity.gameData = data
            entity.cachedAt = Date()
        }
        CoreDataManager.shared.save()
    }

    func getCachedGames() -> [Game] {
        let request: NSFetchRequest<CDCachedGame> = CDCachedGame.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]

        do {
            let results = try context.fetch(request)
            return results.compactMap { entity in
                guard let data = entity.gameData else { return nil }
                return try? decoder.decode(Game.self, from: data)
            }
        } catch {
            print("Error fetching cached games: \(error)")
            return []
        }
    }

    func clearOldCache() {
        let cutoff = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        let request: NSFetchRequest<CDCachedGame> = CDCachedGame.fetchRequest()
        request.predicate = NSPredicate(format: "cachedAt < %@", cutoff as NSDate)

        do {
            let results = try context.fetch(request)
            for entity in results {
                context.delete(entity)
            }
            CoreDataManager.shared.save()
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
}
