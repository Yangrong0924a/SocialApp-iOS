import Foundation

struct FriendSearchResponse: Codable {
    let users: [FriendSearchUser]
}

struct FriendSearchUser: Codable, Identifiable {
    let id: Int
    let username: String
    let nickname: String?
    let avatar: String?
    let bio: String?
    let friendStatus: String

    enum CodingKeys: String, CodingKey {
        case id, username, nickname, avatar, bio
        case friendStatus = "friend_status"
    }

    var displayName: String { nickname ?? username }
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: Config.baseURL + avatar)
    }
}

struct FriendRequestResponse: Codable {
    let status: String
    let message: String
}

struct FriendActionResponse: Codable {
    let message: String
}