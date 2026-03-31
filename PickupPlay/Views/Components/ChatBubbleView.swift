import SwiftUI

struct ChatBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    var senderName: String = ""

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isFromCurrentUser && !senderName.isEmpty && message.type != .system {
                    Text(senderName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.accentCyan)
                }

                if message.type == .system {
                    systemBubble
                } else {
                    messageBubble
                }

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }

    private var messageBubble: some View {
        Text(message.content)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundColor(isFromCurrentUser ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isFromCurrentUser ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray6)))
            )
    }

    private var systemBubble: some View {
        Text(message.content)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundColor(.secondary)
            .italic()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color(.systemGray6).opacity(0.5))
            )
            .frame(maxWidth: .infinity)
    }
}
