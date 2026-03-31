import Foundation
import Combine
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class GroupViewModel: ObservableObject {
    @Published var groups: [SportGroup] = []
    @Published var discoverGroups: [SportGroup] = []
    @Published var selectedGroup: SportGroup? = nil
    @Published var members: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let groupRepository: GroupRepository
    private let userRepository: UserRepository
    private let chatService: ChatService
    private let locationService: LocationService
    private let notificationService: NotificationService

    init() {
        self.groupRepository = GroupRepository()
        self.userRepository = UserRepository()
        self.chatService = ChatService()
        self.locationService = LocationService()
        self.notificationService = NotificationService()
    }

    func fetchMyGroups(userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let resolvedUserId = resolvedCurrentUserId(fallback: userId) else {
            groups = []
            return
        }

        do {
            groups = try await groupRepository.getGroupsForUser(userId: resolvedUserId)
        } catch {
            errorMessage = "Failed to fetch groups: \(error.localizedDescription)"
        }
    }

    func fetchDiscoverGroups() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            discoverGroups = try await groupRepository.getPublicGroups()
        } catch {
            errorMessage = "Failed to discover groups: \(error.localizedDescription)"
        }
    }

    func createGroup(name: String, description: String, sportIds: [String], isPublic: Bool, creatorId: String) async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let resolvedCreatorId = resolvedCurrentUserId(fallback: creatorId) else {
            errorMessage = "Please sign in again to create a group."
            return nil
        }

        do {
            let location = await locationService.getCurrentLocation() ?? AppLocationDefaults.defaultLocation
            var group = SportGroup.new(
                name: name,
                description: description,
                creatorId: resolvedCreatorId,
                sportIds: sportIds,
                isPublic: isPublic,
                location: GeoPoint(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            )

            let chatRoom = try await chatService.createChatRoom(
                type: .groupChat,
                participantIds: [resolvedCreatorId],
                groupId: group.id
            )
            group = SportGroup(
                id: group.id, name: group.name, description: group.description,
                imageURL: group.imageURL, creatorId: group.creatorId,
                chatRoomId: chatRoom.id, adminIds: group.adminIds,
                memberIds: group.memberIds, sportIds: group.sportIds,
                location: group.location, isPublic: group.isPublic, createdAt: group.createdAt
            )

            try await groupRepository.createGroup(group)
            try? await notificationService.createNotification(
                userId: resolvedCreatorId,
                title: "Group Created",
                body: "\(group.name) is ready to start building its community.",
                type: .groupUpdate,
                referenceId: group.id
            )
            AppEvents.post(.groupsDidChange)
            return group.id
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
            return nil
        }
    }

    func joinGroup(groupId: String, userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let resolvedUserId = resolvedCurrentUserId(fallback: userId) else {
            errorMessage = "Please sign in again to join this group."
            return
        }

        do {
            guard let group = try await groupRepository.getGroup(id: groupId) else {
                errorMessage = "Group not found."
                return
            }

            try await groupRepository.joinGroup(groupId: groupId, userId: resolvedUserId)
            if !group.chatRoomId.isEmpty {
                try await chatService.addParticipant(chatRoomId: group.chatRoomId, userId: resolvedUserId)
            }

            if let updatedGroup = try await groupRepository.getGroup(id: groupId) {
                selectedGroup = updatedGroup
                updateGroupInCollections(updatedGroup)
            }
            if group.creatorId != resolvedUserId {
                try? await notificationService.createNotification(
                    userId: group.creatorId,
                    title: "New Group Member",
                    body: "A new player joined \(group.name).",
                    type: .groupUpdate,
                    referenceId: groupId
                )
            }
            AppEvents.post(.groupsDidChange)
        } catch {
            errorMessage = "Failed to join group: \(error.localizedDescription)"
        }
    }

    func leaveGroup(groupId: String, userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let resolvedUserId = resolvedCurrentUserId(fallback: userId) else {
            errorMessage = "Please sign in again to leave this group."
            return
        }

        do {
            guard let group = try await groupRepository.getGroup(id: groupId) else {
                errorMessage = "Group not found."
                return
            }

            try await groupRepository.leaveGroup(groupId: groupId, userId: resolvedUserId)
            if !group.chatRoomId.isEmpty {
                try await chatService.removeParticipant(chatRoomId: group.chatRoomId, userId: resolvedUserId)
            }

            if let updatedGroup = try await groupRepository.getGroup(id: groupId) {
                selectedGroup = updatedGroup
                updateGroupInCollections(updatedGroup)
            }

            groups.removeAll { $0.id == groupId }
            if group.creatorId != resolvedUserId {
                try? await notificationService.createNotification(
                    userId: group.creatorId,
                    title: "Group Member Left",
                    body: "A member left \(group.name).",
                    type: .groupUpdate,
                    referenceId: groupId
                )
            }
            AppEvents.post(.groupsDidChange)
        } catch {
            errorMessage = "Failed to leave group: \(error.localizedDescription)"
        }
    }

    func fetchMembers(groupId: String) async {
        guard let group = selectedGroup ?? groups.first(where: { $0.id == groupId }) else { return }
        isLoading = true
        defer { isLoading = false }

        var fetchedMembers: [User] = []
        for memberId in group.memberIds {
            if let user = try? await userRepository.getUser(id: memberId) {
                fetchedMembers.append(user)
            }
        }
        members = fetchedMembers
    }

    func promoteToAdmin(groupId: String, userId: String) async {
        do {
            try await groupRepository.promoteToAdmin(groupId: groupId, userId: userId)
            selectedGroup = try await groupRepository.getGroup(id: groupId)
        } catch {
            errorMessage = "Failed to promote member: \(error.localizedDescription)"
        }
    }

    func removeMember(groupId: String, userId: String) async {
        do {
            guard let group = try await groupRepository.getGroup(id: groupId) else {
                errorMessage = "Group not found."
                return
            }

            try await groupRepository.removeMember(groupId: groupId, userId: userId)
            if !group.chatRoomId.isEmpty {
                try await chatService.removeParticipant(chatRoomId: group.chatRoomId, userId: userId)
            }
            members.removeAll { $0.id == userId }
            if let updatedGroup = try await groupRepository.getGroup(id: groupId) {
                selectedGroup = updatedGroup
                updateGroupInCollections(updatedGroup)
            }
            AppEvents.post(.groupsDidChange)
        } catch {
            errorMessage = "Failed to remove member: \(error.localizedDescription)"
        }
    }

    private func updateGroupInCollections(_ group: SportGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
        }

        if let index = discoverGroups.firstIndex(where: { $0.id == group.id }) {
            discoverGroups[index] = group
        }
    }

    private func resolvedCurrentUserId(fallback userId: String?) -> String? {
        if let authUserId = FirebaseManager.shared.auth.currentUser?.uid,
           !authUserId.isEmpty {
            return authUserId
        }

        guard let userId,
              !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return userId
    }
}
