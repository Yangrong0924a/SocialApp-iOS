import Foundation

struct Message: Codable, Identifiable {
    let id: Int
    let senderId: Int
    let receiverId: Int
    let content: String?
    let mediaType: String?
    let mediaUrl: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case content
        case mediaType = "media_type"
        case mediaUrl = "media_url"
        case createdAt = "created_at"
    }

    var mediaURL: URL? {
        guard let url = mediaUrl, !url.isEmpty else { return nil }
        return URL(string: Config.baseURL + url)
    }

    var isImage: Bool { mediaType == "image" }
    var isAudio: Bool { mediaType == "audio" }
    var isVideo: Bool { mediaType == "video" }

    var formattedTime: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            return df.string(from: date)
        }
        return createdAt
    }
}

struct SendMessageResponse: Codable {
    let userMsg: Message
    let botReply: Message?

    enum CodingKeys: String, CodingKey {
        case userMsg = "user_msg"
        case botReply = "bot_reply"
    }
}

struct UploadMediaResponse: Codable {
    let userMsg: Message
    let botReply: Message?

    enum CodingKeys: String, CodingKey {
        case userMsg = "user_msg"
        case botReply = "bot_reply"
    }
}