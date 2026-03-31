import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var chatVM = ChatViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                if chatVM.isLoading && chatVM.chatRooms.isEmpty {
                    ProgressView("Loading messages...")
                        .fontDesign(.rounded)
                } else if chatVM.chatRooms.isEmpty {
                    EmptyStateView(
                        icon: "message.fill",
                        title: "No Messages",
                        message: "Join a game or group to start chatting with other players!"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(chatVM.chatRooms) { chatRoom in
                                NavigationLink(destination: ChatRoomView(chatRoomId: chatRoom.id)) {
                                    ChatRoomCard(chatRoom: chatRoom)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task { await reloadChatRooms() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .chatRoomsDidChange)) { _ in
                Task { await reloadChatRooms() }
            }
            .errorBanner(message: $chatVM.errorMessage)
        }
    }

    private func reloadChatRooms() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        await chatVM.loadChatRooms(userId: userId)
    }
}

struct ChatRoomCard: View {
    let chatRoom: ChatRoom

    private var typeIcon: String {
        switch chatRoom.type {
        case .gameChat: return "sportscourt.fill"
        case .groupChat: return "person.3.fill"
        case .directMessage: return "person.fill"
        }
    }

    private var typeLabel: String {
        switch chatRoom.type {
        case .gameChat: return "Game Chat"
        case .groupChat: return "Group Chat"
        case .directMessage: return "Direct Message"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentCyan.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: typeIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.gradient)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(typeLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)

                Text(chatRoom.lastMessagePreview.isEmpty ? "No messages yet" : chatRoom.lastMessagePreview)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(chatRoom.updatedAt, style: .relative)
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)

                Text("\(chatRoom.participantIds.count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(AppTheme.accentCyan))
            }
        }
        .padding(14)
        .glassCard(padding: 0)
    }
}
