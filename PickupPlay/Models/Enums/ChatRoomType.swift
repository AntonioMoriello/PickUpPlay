import Foundation

enum ChatRoomType: String, Codable, CaseIterable {
    case gameChat = "GAME_CHAT"
    case groupChat = "GROUP_CHAT"
    case directMessage = "DIRECT_MESSAGE"
}
