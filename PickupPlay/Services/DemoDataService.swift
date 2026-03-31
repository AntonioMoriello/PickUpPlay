import Foundation
import FirebaseAuth
import FirebaseFirestore

final class DemoDataService {
    static let shared = DemoDataService()

    private let db = FirebaseManager.shared.firestore
    private let sportRepository = SportRepository()
    private let venueRepository = VenueRepository()
    private let userRepository = UserRepository()
    private let groupRepository = GroupRepository()
    private let gameRepository = GameRepository()
    private let notificationRepository = NotificationRepository()
    private let chatRepository = ChatRepository()
    private let achievementRepo = AchievementRepo()

    private init() {}

    func prepareBaseData() async {
        do {
            try await sportRepository.populateSportsIfNeeded()
            try await venueRepository.populateVenuesIfNeeded()
            try await ensureDemoUsers()
            try await ensureDemoGroups()
            try await ensureDemoGames()
            AppEvents.post(.venuesDidChange)
            AppEvents.post(.groupsDidChange)
            AppEvents.post(.gamesDidChange)
        } catch {
            print("DemoDataService prepareBaseData error: \(error)")
        }
    }

    func prepareSignedInExperience(for firebaseUser: FirebaseAuth.User?) async -> User? {
        await prepareBaseData()

        guard let firebaseUser else { return nil }

        do {
            let user = try await ensureUserProfile(for: firebaseUser)
            achievementRepo.initializeAchievements(userId: user.id)
            try await ensureWelcomeNotification(for: user)
            try await ensureWelcomeChat(for: user)
            AppEvents.post(.profileDidChange)
            AppEvents.post(.notificationsDidChange)
            AppEvents.post(.chatRoomsDidChange)
            return try await userRepository.getUser(id: user.id) ?? user
        } catch {
            print("DemoDataService prepareSignedInExperience error: \(error)")
            return nil
        }
    }

    func ensureUserProfile(for firebaseUser: FirebaseAuth.User) async throws -> User {
        if let existing = try await userRepository.getUser(id: firebaseUser.uid) {
            return existing
        }

        let displayName = resolvedDisplayName(
            firebaseDisplayName: firebaseUser.displayName,
            email: firebaseUser.email
        )
        let user = User.newUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "player@pickupplay.app",
            displayName: displayName
        )
        try await userRepository.createUser(user)
        return user
    }

    private func ensureDemoUsers() async throws {
        for user in demoUsers {
            if try await userRepository.getUser(id: user.id) == nil {
                try await userRepository.createUser(user)
            }
        }
    }

    private func ensureDemoGroups() async throws {
        let group = demoGroup
        let chatRoom = demoGroupChatRoom

        if try await chatRepository.getChatRoom(id: chatRoom.id) == nil {
            try await chatRepository.createChatRoom(chatRoom)
        }
        try await seedMessagesIfNeeded(chatRoomId: chatRoom.id, messages: demoGroupMessages)

        if try await groupRepository.getGroup(id: group.id) == nil {
            try await groupRepository.createGroup(group)
        }
    }

    private func ensureDemoGames() async throws {
        for game in demoGames {
            let chatRoom = demoGameChatRoom(for: game)
            if try await chatRepository.getChatRoom(id: chatRoom.id) == nil {
                try await chatRepository.createChatRoom(chatRoom)
            }
            try await seedMessagesIfNeeded(
                chatRoomId: chatRoom.id,
                messages: demoGameMessages(for: game)
            )

            if let existing = try await gameRepository.getGame(id: game.id) {
                try await syncDemoGameVenueIfNeeded(existing: existing, target: game)
            } else {
                try await gameRepository.createGame(game)
            }
        }
    }

    private func syncDemoGameVenueIfNeeded(existing: Game, target: Game) async throws {
        guard existing.venueId != target.venueId ||
                existing.location.latitude != target.location.latitude ||
                existing.location.longitude != target.location.longitude else {
            return
        }

        try await gameRepository.updateGame(id: existing.id, data: [
            "venueId": target.venueId,
            "location": target.location
        ])
    }

    private func ensureWelcomeNotification(for user: User) async throws {
        let notification = AppNotification(
            id: "welcome_notification_\(user.id)",
            userId: user.id,
            title: "Welcome to PickupPlay",
            body: "Browse demo games, join a group, or publish your own match to explore the full app.",
            type: .gameUpdate,
            referenceId: "welcome",
            isRead: false,
            createdAt: Date()
        )

        let ref = db.collection("notifications").document(notification.id)
        let snapshot = try await ref.getDocument()
        guard !snapshot.exists else { return }

        try await notificationRepository.createNotification(notification)
    }

    private func ensureWelcomeChat(for user: User) async throws {
        let chatRoomId = "welcome_chat_\(user.id)"
        let hostId = DemoIdentity.hostId
        if try await chatRepository.getChatRoom(id: chatRoomId) == nil {
            let room = ChatRoom(
                id: chatRoomId,
                gameId: nil,
                groupId: nil,
                type: .directMessage,
                participantIds: [hostId, user.id],
                createdAt: Date(),
                updatedAt: Date(),
                lastMessagePreview: "Tap any game to join, chat, or share it."
            )

            try await chatRepository.createChatRoom(room)
        }

        let messages = [
            Message(
                id: "welcome_chat_msg_1_\(user.id)",
                chatRoomId: chatRoomId,
                senderId: hostId,
                content: "Welcome to PickupPlay. The demo already includes live games, venues, and groups you can explore.",
                type: .system,
                timestamp: Date().addingTimeInterval(-600),
                isRead: false
            ),
            Message(
                id: "welcome_chat_msg_2_\(user.id)",
                chatRoomId: chatRoomId,
                senderId: hostId,
                content: "Tap any game to join, chat, or share it.",
                type: .text,
                timestamp: Date().addingTimeInterval(-300),
                isRead: false
            )
        ]
        try await seedMessagesIfNeeded(chatRoomId: chatRoomId, messages: messages)
    }

    private func seedMessagesIfNeeded(chatRoomId: String, messages: [Message]) async throws {
        let baseRef = db.collection("chatRooms").document(chatRoomId).collection("messages")
        for message in messages {
            let doc = try await baseRef.document(message.id).getDocument()
            if !doc.exists {
                try baseRef.document(message.id).setData(from: message)
            }
        }
    }

    private func resolvedDisplayName(firebaseDisplayName: String?, email: String?) -> String {
        if let firebaseDisplayName,
           !firebaseDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return firebaseDisplayName
        }

        if let email,
           let prefix = email.split(separator: "@").first,
           !prefix.isEmpty {
            return prefix
                .split(separator: ".")
                .map { $0.capitalized }
                .joined(separator: " ")
        }

        return "Pickup Player"
    }

    private var demoUsers: [User] {
        [
            User(
                id: DemoIdentity.hostId,
                email: "captain@pickupplay.demo",
                displayName: "Jordan Captain",
                profileImageURL: "",
                createdAt: Date().addingTimeInterval(-86_400 * 30),
                currentLocation: AppLocationDefaults.defaultGeoPoint,
                sportSkills: [
                    SportSkill(sportId: "basketball", level: .advanced, preferredPosition: "Point Guard", gamesPlayedInSport: 24, stats: [:]),
                    SportSkill(sportId: "soccer", level: .intermediate, preferredPosition: "Midfielder", gamesPlayedInSport: 9, stats: [:])
                ],
                favoriteSports: ["basketball", "soccer"],
                favoriteVenueIds: [Venue.sampleVenues[0].id],
                followingIds: [DemoIdentity.groupCoachId],
                followerIds: [DemoIdentity.groupCoachId, DemoIdentity.volleyLeadId],
                groupIds: [DemoSeed.publicGroupId],
                reliabilityScore: 4.8,
                gamesPlayed: 24,
                gamesOrganized: 11
            ),
            User(
                id: DemoIdentity.groupCoachId,
                email: "coach@pickupplay.demo",
                displayName: "Sam Coach",
                profileImageURL: "",
                createdAt: Date().addingTimeInterval(-86_400 * 20),
                currentLocation: GeoPoint(latitude: 45.5228, longitude: -73.5951),
                sportSkills: [
                    SportSkill(sportId: "soccer", level: .advanced, preferredPosition: "Coach", gamesPlayedInSport: 18, stats: [:]),
                    SportSkill(sportId: "ultimate_frisbee", level: .intermediate, preferredPosition: "Handler", gamesPlayedInSport: 7, stats: [:])
                ],
                favoriteSports: ["soccer", "ultimate_frisbee"],
                favoriteVenueIds: [Venue.sampleVenues[1].id],
                followingIds: [DemoIdentity.hostId],
                followerIds: [DemoIdentity.volleyLeadId],
                groupIds: [DemoSeed.publicGroupId],
                reliabilityScore: 4.6,
                gamesPlayed: 18,
                gamesOrganized: 6
            ),
            User(
                id: DemoIdentity.volleyLeadId,
                email: "volley@pickupplay.demo",
                displayName: "Taylor Spike",
                profileImageURL: "",
                createdAt: Date().addingTimeInterval(-86_400 * 12),
                currentLocation: GeoPoint(latitude: 45.4898, longitude: -73.5605),
                sportSkills: [
                    SportSkill(sportId: "volleyball", level: .expert, preferredPosition: "Setter", gamesPlayedInSport: 30, stats: [:]),
                    SportSkill(sportId: "pickleball", level: .intermediate, preferredPosition: "Doubles", gamesPlayedInSport: 10, stats: [:])
                ],
                favoriteSports: ["volleyball", "pickleball"],
                favoriteVenueIds: [Venue.sampleVenues[5].id],
                followingIds: [DemoIdentity.hostId],
                followerIds: [DemoIdentity.hostId],
                groupIds: [],
                reliabilityScore: 4.9,
                gamesPlayed: 30,
                gamesOrganized: 8
            )
        ]
    }

    private var demoGames: [Game] {
        let now = Date()
        let venues = Venue.sampleVenues

        return [
            Game(
                id: DemoSeed.basketballGameId,
                organizerId: DemoIdentity.hostId,
                sportId: "basketball",
                venueId: venues[0].id,
                chatRoomId: DemoSeed.basketballChatId,
                groupId: DemoSeed.publicGroupId,
                title: "Sunset Hoops Run",
                description: "Friendly full-court run with room for all skill levels.",
                dateTime: Calendar.current.date(byAdding: .hour, value: 6, to: now) ?? now.addingTimeInterval(21_600),
                maxPlayers: 10,
                skillLevel: .intermediate,
                status: .upcoming,
                playerIds: [DemoIdentity.hostId, DemoIdentity.groupCoachId],
                teams: [],
                location: venues[0].coordinates,
                createdAt: now.addingTimeInterval(-3_600)
            ),
            Game(
                id: DemoSeed.soccerGameId,
                organizerId: DemoIdentity.groupCoachId,
                sportId: "soccer",
                venueId: venues[1].id,
                chatRoomId: DemoSeed.soccerChatId,
                groupId: DemoSeed.publicGroupId,
                title: "Wednesday Small-Sided Soccer",
                description: "Fast-paced 7v7 style game. Bring a light and dark shirt.",
                dateTime: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86_400),
                maxPlayers: 14,
                skillLevel: .intermediate,
                status: .upcoming,
                playerIds: [DemoIdentity.groupCoachId, DemoIdentity.hostId],
                teams: [],
                location: venues[1].coordinates,
                createdAt: now.addingTimeInterval(-7_200)
            ),
            Game(
                id: DemoSeed.volleyGameId,
                organizerId: DemoIdentity.volleyLeadId,
                sportId: "volleyball",
                venueId: venues[5].id,
                chatRoomId: DemoSeed.volleyChatId,
                groupId: nil,
                title: "Friday Beach-Style Volleyball",
                description: "Open run focused on fun rallies and quick rotations.",
                dateTime: Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now.addingTimeInterval(172_800),
                maxPlayers: 12,
                skillLevel: .advanced,
                status: .upcoming,
                playerIds: [DemoIdentity.volleyLeadId, DemoIdentity.hostId],
                teams: [],
                location: venues[5].coordinates,
                createdAt: now.addingTimeInterval(-10_800)
            )
        ]
    }

    private var demoGroup: SportGroup {
        SportGroup(
            id: DemoSeed.publicGroupId,
            name: "Montreal Pickup Club",
            description: "A public community for players who bounce between basketball, soccer, volleyball, and anything in season.",
            imageURL: "",
            creatorId: DemoIdentity.hostId,
            chatRoomId: DemoSeed.publicGroupChatId,
            adminIds: [DemoIdentity.hostId, DemoIdentity.groupCoachId],
            memberIds: [DemoIdentity.hostId, DemoIdentity.groupCoachId, DemoIdentity.volleyLeadId],
            sportIds: ["basketball", "soccer", "volleyball", "pickleball"],
            location: AppLocationDefaults.defaultGeoPoint,
            isPublic: true,
            createdAt: Date().addingTimeInterval(-86_400 * 14)
        )
    }

    private var demoGroupChatRoom: ChatRoom {
        ChatRoom(
            id: DemoSeed.publicGroupChatId,
            gameId: nil,
            groupId: DemoSeed.publicGroupId,
            type: .groupChat,
            participantIds: [DemoIdentity.hostId, DemoIdentity.groupCoachId, DemoIdentity.volleyLeadId],
            createdAt: Date().addingTimeInterval(-86_400 * 14),
            updatedAt: Date().addingTimeInterval(-1_800),
            lastMessagePreview: "We still need two more players for the Wednesday soccer run."
        )
    }

    private var demoGroupMessages: [Message] {
        [
            Message(
                id: "demo_group_msg_1",
                chatRoomId: DemoSeed.publicGroupChatId,
                senderId: DemoIdentity.hostId,
                content: "Welcome to Montreal Pickup Club. Use this chat to coordinate sports, rides, or last-minute games.",
                type: .system,
                timestamp: Date().addingTimeInterval(-3_600),
                isRead: false
            ),
            Message(
                id: "demo_group_msg_2",
                chatRoomId: DemoSeed.publicGroupChatId,
                senderId: DemoIdentity.groupCoachId,
                content: "We still need two more players for the Wednesday soccer run.",
                type: .text,
                timestamp: Date().addingTimeInterval(-1_800),
                isRead: false
            )
        ]
    }

    private func demoGameChatRoom(for game: Game) -> ChatRoom {
        ChatRoom(
            id: game.chatRoomId,
            gameId: game.id,
            groupId: game.groupId,
            type: .gameChat,
            participantIds: game.playerIds,
            createdAt: game.createdAt,
            updatedAt: game.createdAt,
            lastMessagePreview: "Game chat created for \(game.title)."
        )
    }

    private func demoGameMessages(for game: Game) -> [Message] {
        [
            Message(
                id: "demo_\(game.id)_msg_1",
                chatRoomId: game.chatRoomId,
                senderId: game.organizerId,
                content: "Game chat created for \(game.title).",
                type: .system,
                timestamp: game.createdAt,
                isRead: false
            )
        ]
    }
}

private enum DemoSeed {
    static let publicGroupId = "demo_public_group"
    static let publicGroupChatId = "demo_public_group_chat"
    static let basketballGameId = "demo_basketball_game"
    static let soccerGameId = "demo_soccer_game"
    static let volleyGameId = "demo_volleyball_game"
    static let basketballChatId = "demo_basketball_chat"
    static let soccerChatId = "demo_soccer_chat"
    static let volleyChatId = "demo_volleyball_chat"
}

private enum DemoIdentity {
    static let hostId = "demo_host_user"
    static let groupCoachId = "demo_group_coach"
    static let volleyLeadId = "demo_volley_lead"
}
