import Foundation
import CoreData

class UserPrefsRepo {
    private let coreDataManager = CoreDataManager.shared

    func savePrefs(
        userId: String,
        mapZoom: Double? = nil,
        sportFilter: String? = nil,
        notificationPrefs: NotificationPreferences? = nil,
        privacySettings: PrivacySettings? = nil,
        sportPreferences: SportPreferences? = nil
    ) {
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
            if let notificationPrefs {
                prefs.notificationPrefsData = encode(notificationPrefs)
            }
            if let privacySettings {
                prefs.privacySettingsData = encode(privacySettings)
            }
            if let sportPreferences {
                prefs.sportPreferencesData = encode(sportPreferences)
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

    func getPreferences(userId: String) -> UserPreferences? {
        guard let prefs = getPrefs(userId: userId) else { return nil }

        var userPreferences = UserPreferences.default
        if let notificationPrefs: NotificationPreferences = decode(prefs.notificationPrefsData) {
            userPreferences.notificationPrefs = notificationPrefs
        }
        if let privacySettings: PrivacySettings = decode(prefs.privacySettingsData) {
            userPreferences.privacySettings = privacySettings
        }
        if let sportPreferences: SportPreferences = decode(prefs.sportPreferencesData) {
            userPreferences.sportPreferences = sportPreferences
        } else if let defaultSportFilter = prefs.defaultSportFilter {
            userPreferences.sportPreferences.favoriteSports = [defaultSportFilter]
        }

        return userPreferences
    }

    private func encode<T: Encodable>(_ value: T) -> String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func decode<T: Decodable>(_ value: String?) -> T? {
        guard let value, let data = value.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
