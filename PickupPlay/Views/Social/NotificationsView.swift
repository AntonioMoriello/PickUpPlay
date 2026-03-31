import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private let notificationRepo = NotificationRepository()

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if isLoading && notifications.isEmpty {
                ProgressView("Loading notifications...")
                    .fontDesign(.rounded)
            } else if notifications.isEmpty {
                EmptyStateView(
                    icon: "bell.fill",
                    title: "No Notifications",
                    message: "You're all caught up! New notifications will appear here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(notifications) { notification in
                            NotificationCard(notification: notification) {
                                Task { await markAsRead(notification) }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !notifications.isEmpty {
                    Button("Mark All Read") {
                        Task { await markAllRead() }
                    }
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(AppTheme.gradient)
                }
            }
        }
        .onAppear { loadNotifications() }
        .onReceive(NotificationCenter.default.publisher(for: .notificationsDidChange)) { _ in
            loadNotifications()
        }
        .errorBanner(message: $errorMessage)
    }

    private func loadNotifications() {
        guard let userId = authViewModel.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                notifications = try await notificationRepo.getNotifications(userId: userId)
            } catch {
                errorMessage = "Failed to load notifications: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    private func markAsRead(_ notification: AppNotification) async {
        do {
            try await notificationRepo.markAsRead(notificationId: notification.id)
            if let idx = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[idx] = AppNotification(
                    id: notification.id, userId: notification.userId,
                    title: notification.title, body: notification.body,
                    type: notification.type, referenceId: notification.referenceId,
                    isRead: true, createdAt: notification.createdAt
                )
            }
        } catch {
            errorMessage = "Failed to mark as read"
        }
    }

    private func markAllRead() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        do {
            try await notificationRepo.markAllAsRead(userId: userId)
            notifications = notifications.map {
                AppNotification(id: $0.id, userId: $0.userId, title: $0.title, body: $0.body, type: $0.type, referenceId: $0.referenceId, isRead: true, createdAt: $0.createdAt)
            }
        } catch {
            errorMessage = "Failed to mark all as read"
        }
    }
}

struct NotificationCard: View {
    let notification: AppNotification
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button { onTap?() } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(notification.isRead ? Color(.systemGray5) : AppTheme.accentGreen.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: notification.type.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(notification.isRead ? .gray : AppTheme.accentGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(notification.isRead ? .regular : .semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)

                    Text(notification.body)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack {
                    Text(notification.createdAt, style: .relative)
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)

                    if !notification.isRead {
                        Circle()
                            .fill(AppTheme.accentGreen)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(14)
            .glassCard(padding: 0)
        }
        .buttonStyle(.plain)
    }
}
