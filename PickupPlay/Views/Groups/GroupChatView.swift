import SwiftUI

struct GroupChatView: View {
    let chatRoomId: String

    var body: some View {
        ChatRoomView(chatRoomId: chatRoomId)
            .navigationTitle("Group Chat")
    }
}
