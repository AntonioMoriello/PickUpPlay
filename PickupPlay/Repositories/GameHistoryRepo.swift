//
//  GameHistoryRepo.swift
//  PickupPlay
//
import Foundation
import CoreData

class GameHistoryRepo {
    private let context = CoreDataManager.shared.context

    func saveToHistory(_ history: GameHistory) {
        let entity = CDGameHistory(context: context)
        entity.id = history.id
        entity.userId = history.userId
        entity.gameId = history.gameId
        entity.sportId = history.sportId
        entity.venueId = history.venueId
        entity.datePlayed = history.datePlayed
        entity.attended = history.attended
        entity.teamId = history.teamId
        entity.result = history.result.rawValue
        entity.stats = history.stats as NSDictionary
        CoreDataManager.shared.save()
    }

    func getHistory(userId: String) -> [GameHistory] {
        let request: NSFetchRequest<CDGameHistory> = CDGameHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "datePlayed", ascending: false)]

        do {
            let results = try context.fetch(request)
            return results.map { mapToGameHistory($0) }
        } catch {
            print("Error fetching game history: \(error)")
            return []
        }
    }

    func getHistoryForSport(userId: String, sportId: String) -> [GameHistory] {
        let request: NSFetchRequest<CDGameHistory> = CDGameHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND sportId == %@", userId, sportId)
        request.sortDescriptors = [NSSortDescriptor(key: "datePlayed", ascending: false)]

        do {
            let results = try context.fetch(request)
            return results.map { mapToGameHistory($0) }
        } catch {
            print("Error fetching sport history: \(error)")
            return []
        }
    }

    private func mapToGameHistory(_ entity: CDGameHistory) -> GameHistory {
        GameHistory(
            id: entity.id ?? UUID().uuidString,
            userId: entity.userId ?? "",
            gameId: entity.gameId ?? "",
            sportId: entity.sportId ?? "",
            venueId: entity.venueId ?? "",
            datePlayed: entity.datePlayed ?? Date(),
            attended: entity.attended,
            teamId: entity.teamId ?? "",
            result: GameResult(rawValue: entity.result ?? "NOT_RECORDED") ?? .notRecorded,
            stats: entity.stats as? [String: Int] ?? [:]
        )
    }
}
