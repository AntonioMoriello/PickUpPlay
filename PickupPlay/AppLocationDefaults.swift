import CoreLocation
import MapKit
import FirebaseFirestore

enum AppLocationDefaults {
    static let defaultCoordinate = CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)
    static let defaultLocation = CLLocation(
        latitude: defaultCoordinate.latitude,
        longitude: defaultCoordinate.longitude
    )
    static let defaultGeoPoint = GeoPoint(
        latitude: defaultCoordinate.latitude,
        longitude: defaultCoordinate.longitude
    )
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    static let defaultRegion = MKCoordinateRegion(center: defaultCoordinate, span: defaultSpan)
}
