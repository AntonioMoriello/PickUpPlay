import Foundation

enum MessageType: String, Codable, CaseIterable {
    case text = "TEXT"
    case system = "SYSTEM"
    case image = "IMAGE"
    case location = "LOCATION"
}
