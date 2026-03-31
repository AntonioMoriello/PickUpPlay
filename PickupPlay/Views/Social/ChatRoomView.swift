import SwiftUI

struct ChatRoomView: View {
    let chatRoomId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var chatVM = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    private var currentUserId: String {
        authViewModel.currentUser?.id ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(chatVM.messages) { message in
                            ChatBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderId == currentUserId,
                                senderName: message.senderId == currentUserId ? "" : String(message.senderId.prefix(8))
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                .onChange(of: chatVM.messages.count) { _, _ in
                    if let lastId = chatVM.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Message...", text: $messageText)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    .focused($isInputFocused)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray4) : AppTheme.accentGreen)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await chatVM.loadChatRoom(chatRoomId: chatRoomId) }
            chatVM.observeMessages(chatRoomId: chatRoomId)
        }
        .onDisappear {
            chatVM.stopObserving()
        }
        .errorBanner(message: $chatVM.errorMessage)
    }

    private func sendMessage() {
        let text = messageText
        messageText = ""
        Task {
            await chatVM.sendMessage(
                content: text,
                chatRoomId: chatRoomId,
                senderId: currentUserId
            )
        }
    }
}
