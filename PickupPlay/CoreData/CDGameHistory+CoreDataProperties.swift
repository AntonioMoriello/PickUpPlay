//
//  CDGameHistory+CoreDataProperties.swift
//  PickupPlay
//
import Foundation
import CoreData

@objc(CDGameHistory)
public class CDGameHistory: NSManagedObject {
}

extension CDGameHistory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGameHistory> {
        return NSFetchRequest<CDGameHistory>(entityName: "CDGameHistory")
    }

    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var gameId: String?
    @NSManaged public var sportId: String?
    @NSManaged public var venueId: String?
    @NSManaged public var datePlayed: Date?
    @NSManaged public var attended: Bool
    @NSManaged public var teamId: String?
    @NSManaged public var result: String?
    @NSManaged public var stats: NSDictionary?
}

extension CDGameHistory: Identifiable {
}
