//
//  FavoriteVenuesRepo.swift
//  PickupPlay
//
import Foundation
import CoreData

class FavoriteVenuesRepo {
    private let context = CoreDataManager.shared.context

    func addFavorite(venueId: String, venueName: String) {
        guard !isFavorite(venueId: venueId) else { return }
        let entity = CDFavoriteVenue(context: context)
        entity.venueId = venueId
        entity.venueName = venueName
        entity.savedAt = Date()
        CoreDataManager.shared.save()
    }

    func removeFavorite(venueId: String) {
        let request: NSFetchRequest<CDFavoriteVenue> = CDFavoriteVenue.fetchRequest()
        request.predicate = NSPredicate(format: "venueId == %@", venueId)

        do {
            let results = try context.fetch(request)
            for entity in results {
                context.delete(entity)
            }
            CoreDataManager.shared.save()
        } catch {
            print("Error removing favorite: \(error)")
        }
    }

    func getFavorites() -> [(venueId: String, venueName: String, savedAt: Date)] {
        let request: NSFetchRequest<CDFavoriteVenue> = CDFavoriteVenue.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]

        do {
            let results = try context.fetch(request)
            return results.map {
                (venueId: $0.venueId ?? "", venueName: $0.venueName ?? "", savedAt: $0.savedAt ?? Date())
            }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }

    func isFavorite(venueId: String) -> Bool {
        let request: NSFetchRequest<CDFavoriteVenue> = CDFavoriteVenue.fetchRequest()
        request.predicate = NSPredicate(format: "venueId == %@", venueId)
        request.fetchLimit = 1

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
}
