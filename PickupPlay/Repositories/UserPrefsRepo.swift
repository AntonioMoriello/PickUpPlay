//
//  UserPrefsRepo.swift
//  PickupPlay
//
import Foundation
import CoreData

class UserPrefsRepo {
    private let coreDataManager = CoreDataManager.shared

    func savePrefs(userId: String, mapZoom: Double? = nil, sportFilter: String? = nil) {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<CDUserPrefs> = CDUserPrefs.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            let results = try context.fetch(fetchRequest)
            let prefs: CDUserPrefs

            if let existing = results.first {
                prefs = existing
            } else {
                prefs = CDUserPrefs(context: context)
                prefs.userId = userId
            }

            if let mapZoom = mapZoom {
                prefs.preferredMapZoom = mapZoom
            }
            if let sportFilter = sportFilter {
                prefs.defaultSportFilter = sportFilter
            }
            prefs.lastSyncDate = Date()

            coreDataManager.save()
        } catch {
            print("UserPrefsRepo save error: \(error)")
        }
    }

    func getPrefs(userId: String) -> CDUserPrefs? {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<CDUserPrefs> = CDUserPrefs.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("UserPrefsRepo fetch error: \(error)")
            return nil
        }
    }
}
