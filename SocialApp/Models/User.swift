import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: Int
    var username: String
    var email: String?
    var nickname: String?
    var avatar: String?
    var bio: String?
    var ownerId: Int?
    var emergencyContactName: String?
    var emergencyContactEmail: String?
    var lastActiveAt: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, username, email, nickname, avatar, bio
        case ownerId = "owner_id"
        case emergencyContactName = "emergency_contact_name"
        case emergencyContactEmail = "emergency_contact_email"
        case lastActiveAt = "last_active_at"
        case createdAt = "created_at"
    }

    var displayName: String { nickname ?? username }
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: Config.baseURL + avatar)
    }
    var isBot: Bool { ownerId != nil }

    static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
}

// MARK: - API 响应结构

struct UserDetailResponse: Codable {
    let user: User
    let posts: [Post]
    let checkedInToday: Bool
    let checkinStreak: Int
    let friendStatus: String

    enum CodingKeys: String, CodingKey {
        case user, posts
        case checkedInToday = "checked_in_today"
        case checkinStreak = "checkin_streak"
        case friendStatus = "friend_status"
    }
}

struct MeResponse: Codable {
    let id: Int
    let username: String
    let email: String?
    let nickname: String?
    let avatar: String?
    let bio: String?
    let ownerId: Int?

    enum CodingKeys: String, CodingKey {
        case id, username, email, nickname, avatar, bio
        case ownerId = "owner_id"
    }
}

// MARK: - 聊天列表

struct ChatUserResponse: Codable {
    let bot: BotInfo?
    let friends: [FriendInfo]
    let pendingFrom: [User]

    enum CodingKeys: String, CodingKey {
        case bot, friends
        case pendingFrom = "pending_from"
    }
}

struct BotInfo: Codable {
    let user: User
    let lastMessage: Message?
    let unread: Int

    enum CodingKeys: String, CodingKey {
        case user
        case lastMessage = "last_message"
        case unread
    }
}

struct FriendInfo: Codable, Identifiable {
    let user: User
    let lastMessage: Message?
    let unread: Int

    enum CodingKeys: String, CodingKey {
        case user
        case lastMessage = "last_message"
        case unread
    }

    var id: Int { user.id }
}