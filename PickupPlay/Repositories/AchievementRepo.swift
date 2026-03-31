import Foundation
import CoreData

class AchievementRepo {
    private let context = CoreDataManager.shared.context

    func initializeAchievements(userId: String) {
        migrateLegacyAchievementsIfNeeded()

        let existing = getAchievements(userId: userId)
        guard existing.isEmpty else { return }

        for achievement in Achievement.allAchievements {
            let entity = CDAchievement(context: context)
            entity.id = achievement.id
            entity.userId = userId
            entity.name = achievement.name
            entity.achievementDescription = achievement.description
            entity.iconName = achievement.iconName
            entity.type = achievement.type.rawValue
            entity.sportId = achievement.sportId
            entity.requirement = Int32(achievement.requirement)
            entity.currentProgress = 0
            entity.isUnlocked = false
            entity.unlockedAt = nil
        }
        CoreDataManager.shared.save()
    }

    func getAchievements(userId: String) -> [Achievement] {
        let request: NSFetchRequest<CDAchievement> = CDAchievement.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            let results = try context.fetch(request)
            return results.map { mapToAchievement($0) }
        } catch {
            return []
        }
    }

    func syncProgress(userId: String, history: [GameHistory], organizedGamesCount: Int, followerCount: Int) {
        initializeAchievements(userId: userId)

        let playedCount = history.count
        let uniqueSportsCount = Set(history.map(\.sportId).filter { !$0.isEmpty }).count
        let streakCount = longestStreak(from: history)

        let request: NSFetchRequest<CDAchievement> = CDAchievement.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            let achievements = try context.fetch(request)
            for achievement in achievements {
                let type = AchievementType(rawValue: achievement.type ?? "") ?? .gamesPlayed
                let progress: Int

                switch type {
                case .gamesPlayed, .milestone:
                    progress = playedCount
                case .gamesOrganized:
                    progress = organizedGamesCount
                case .social:
                    progress = followerCount
                case .sportSpecific:
                    progress = uniqueSportsCount
                case .streak:
                    progress = streakCount
                }

                achievement.currentProgress = Int32(progress)
                if progress >= achievement.requirement && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedAt = Date()
                }
            }
            CoreDataManager.shared.save()
        } catch {
            print("Error syncing achievements: \(error)")
        }
    }

    func updateProgress(userId: String, achievementId: String, progress: Int) {
        let request: NSFetchRequest<CDAchievement> = CDAchievement.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", achievementId, userId)

        do {
            if let entity = try context.fetch(request).first {
                entity.currentProgress = Int32(progress)
                if progress >= entity.requirement && !entity.isUnlocked {
                    entity.isUnlocked = true
                    entity.unlockedAt = Date()
                }
                CoreDataManager.shared.save()
            }
        } catch {
            print("Error updating achievement: \(error)")
        }
    }

    func unlock(userId: String, achievementId: String) {
        let request: NSFetchRequest<CDAchievement> = CDAchievement.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", achievementId, userId)

        do {
            if let entity = try context.fetch(request).first {
                entity.isUnlocked = true
                entity.unlockedAt = Date()
                entity.currentProgress = entity.requirement
                CoreDataManager.shared.save()
            }
        } catch {
            print("Error unlocking achievement: \(error)")
        }
    }

    private func mapToAchievement(_ entity: CDAchievement) -> Achievement {
        Achievement(
            id: entity.id ?? UUID().uuidString,
            name: entity.name ?? "",
            description: entity.achievementDescription ?? "",
            iconName: entity.iconName ?? "star.fill",
            type: AchievementType(rawValue: entity.type ?? "") ?? .gamesPlayed,
            sportId: entity.sportId ?? "",
            requirement: Int(entity.requirement),
            currentProgress: Int(entity.currentProgress),
            isUnlocked: entity.isUnlocked,
            unlockedAt: entity.unlockedAt
        )
    }

    private func migrateLegacyAchievementsIfNeeded() {
        let request: NSFetchRequest<CDAchievement> = CDAchievement.fetchRequest()
        request.predicate = NSPredicate(format: "userId == nil")

        do {
            let legacyAchievements = try context.fetch(request)
            guard !legacyAchievements.isEmpty else { return }

            legacyAchievements.forEach(context.delete)
            CoreDataManager.shared.save()
        } catch {
            print("Error migrating achievements: \(error)")
        }
    }

    private func longestStreak(from history: [GameHistory]) -> Int {
        let uniqueDays = Set(history.map { Calendar.current.startOfDay(for: $0.datePlayed) })
        let sortedDays = uniqueDays.sorted()

        guard !sortedDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for index in 1..<sortedDays.count {
            let previous = sortedDays[index - 1]
            let currentDay = sortedDays[index]

            if Calendar.current.dateComponents([.day], from: previous, to: currentDay).day == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }
}
