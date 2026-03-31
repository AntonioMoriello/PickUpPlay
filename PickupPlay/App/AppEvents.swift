import Foundation

extension Notification.Name {
    static let gamesDidChange = Notification.Name("PickupPlay.gamesDidChange")
    static let venuesDidChange = Notification.Name("PickupPlay.venuesDidChange")
    static let chatRoomsDidChange = Notification.Name("PickupPlay.chatRoomsDidChange")
    static let groupsDidChange = Notification.Name("PickupPlay.groupsDidChange")
    static let notificationsDidChange = Notification.Name("PickupPlay.notificationsDidChange")
    static let profileDidChange = Notification.Name("PickupPlay.profileDidChange")
}

enum AppEvents {
    static func post(_ name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }
}
