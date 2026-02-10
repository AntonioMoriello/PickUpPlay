//
//  CDUserPrefs+CoreDataProperties.swift
//  PickupPlay
//
import Foundation
import CoreData

@objc(CDUserPrefs)
public class CDUserPrefs: NSManagedObject {
}

extension CDUserPrefs {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserPrefs> {
        return NSFetchRequest<CDUserPrefs>(entityName: "CDUserPrefs")
    }

    @NSManaged public var userId: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var preferredMapZoom: Double
    @NSManaged public var defaultSportFilter: String?
}

extension CDUserPrefs: Identifiable {
}
