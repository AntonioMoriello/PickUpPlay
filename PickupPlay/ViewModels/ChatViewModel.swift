import Foundation
import Combine
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var chatRoom: ChatRoom? = nil
    @Published var chatRooms: [ChatRoom] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let chatService: ChatService
    private let chatRepository: ChatRepository
    private var listener: ListenerRegistration? = nil

    init() {
        self.chatService = ChatService()
        self.chatRepository = ChatRepository()
    }

    func loadChatRoom(chatRoomId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            chatRoom = try await chatRepository.getChatRoom(id: chatRoomId)
        } catch {
            errorMessage = "Failed to load chat: \(error.localizedDescription)"
        }
    }

    func loadChatRooms(userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            chatRooms = try await chatRepository.getChatRoomsForUser(userId: userId)
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
    }

    func observeMessages(chatRoomId: String) {
        listener?.remove()
        listener = chatService.observeMessages(chatRoomId: chatRoomId) { [weak self] messages in
            Task { @MainActor in
                self?.messages = messages
            }
        }
    }

    func sendMessage(content: String, type: MessageType = .text, chatRoomId: String, senderId: String) async {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let message = Message.new(chatRoomId: chatRoomId, senderId: senderId, content: trimmed, type: type)

        do {
            try await chatService.sendMessage(message)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }

    func stopObserving() {
        listener?.remove()
        listener = nil
    }

    deinit {
        listener?.remove()
    }
}
