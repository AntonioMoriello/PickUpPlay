//
//  CDFavoriteVenue+CoreDataProperties.swift
//  PickupPlay
//
import Foundation
import CoreData

@objc(CDFavoriteVenue)
public class CDFavoriteVenue: NSManagedObject {
}

extension CDFavoriteVenue {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFavoriteVenue> {
        return NSFetchRequest<CDFavoriteVenue>(entityName: "CDFavoriteVenue")
    }

    @NSManaged public var venueId: String?
    @NSManaged public var venueName: String?
    @NSManaged public var savedAt: Date?
}

extension CDFavoriteVenue: Identifiable {
}
