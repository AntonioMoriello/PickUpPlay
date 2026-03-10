//
//  CDCachedGame+CoreDataProperties.swift
//  PickupPlay
//
import Foundation
import CoreData

@objc(CDCachedGame)
public class CDCachedGame: NSManagedObject {
}

extension CDCachedGame {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCachedGame> {
        return NSFetchRequest<CDCachedGame>(entityName: "CDCachedGame")
    }

    @NSManaged public var gameId: String?
    @NSManaged public var gameData: Data?
    @NSManaged public var cachedAt: Date?
}

extension CDCachedGame: Identifiable {
}
