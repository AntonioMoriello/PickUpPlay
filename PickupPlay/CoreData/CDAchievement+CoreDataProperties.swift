//
//  CDAchievement+CoreDataProperties.swift
//  PickupPlay
//
import Foundation
import CoreData

@objc(CDAchievement)
public class CDAchievement: NSManagedObject {
}

extension CDAchievement {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAchievement> {
        return NSFetchRequest<CDAchievement>(entityName: "CDAchievement")
    }

    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var name: String?
    @NSManaged public var achievementDescription: String?
    @NSManaged public var iconName: String?
    @NSManaged public var type: String?
    @NSManaged public var sportId: String?
    @NSManaged public var requirement: Int32
    @NSManaged public var currentProgress: Int32
    @NSManaged public var isUnlocked: Bool
    @NSManaged public var unlockedAt: Date?
}

extension CDAchievement: Identifiable {
}
