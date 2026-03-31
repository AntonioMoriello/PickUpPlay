import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }

    private init() {
        container = CoreDataManager.makeContainer(inMemoryFallback: false)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("CoreData save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private static func makeContainer(inMemoryFallback: Bool) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "PickupPlay")

        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
            if inMemoryFallback {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        var loadError: NSError?
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                loadError = error
            }
        }

        if let loadError, !inMemoryFallback {
            print("CoreData failed to load persistent store, using in-memory fallback: \(loadError), \(loadError.userInfo)")
            return makeContainer(inMemoryFallback: true)
        }

        if let loadError, inMemoryFallback {
            print("CoreData failed to load in-memory fallback store: \(loadError), \(loadError.userInfo)")
        }

        return container
    }
}
