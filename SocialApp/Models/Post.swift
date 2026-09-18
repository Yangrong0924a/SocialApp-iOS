import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let content: String
    let image: String?
    let createdAt: String
    let author: User?
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content, image
        case createdAt = "created_at"
        case author
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isLiked = "is_liked"
    }

    var imageURL: URL? {
        guard let image = image, !image.isEmpty else { return nil }
        return URL(string: Config.baseURL + image)
    }

    var formattedTime: String {
        // 服务端返回 ISO 8601 格式，取相对时间
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .abbreviated
            return rel.localizedString(for: date, relativeTo: Date())
        }
        return createdAt
    }
}

struct PostListResponse: Codable {
    let posts: [Post]
    let hasNext: Bool
    let page: Int

    enum CodingKeys: String, CodingKey {
        case posts
        case hasNext = "has_next"
        case page
    }
}

struct LikeResponse: Codable {
    let liked: Bool
    let likeCount: Int

    enum CodingKeys: String, CodingKey {
        case liked
        case likeCount = "like_count"
    }
}

struct CreatePostResponse: Codable {
    let id: Int
    let userId: Int
    let content: String
    let image: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content, image
        case createdAt = "created_at"
    }
}