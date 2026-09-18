import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var botUser: User?
    @Published var friends: [FriendInfo] = []
    @Published var pendingFrom: [User] = []
    @Published var isLoading = false
    @Published var toast: ToastMessage?

    // 当前聊天
    @Published var currentChatUserId: Int?
    @Published var messages: [Message] = []
    @Published var isLoadingMessages = false

    func loadChatUsers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let resp: ChatUserResponse = try await APIService.shared.get("/api/chat/users")
            botUser = resp.bot?.user
            friends = resp.friends
            pendingFrom = resp.pendingFrom
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func loadMessages(with userId: Int) async {
        isLoadingMessages = true
        currentChatUserId = userId
        do {
            messages = try await APIService.shared.get("/api/chat/messages/\(userId)")
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
        isLoadingMessages = false
    }

    func sendMessage(to receiverId: Int, content: String) async {
        do {
            let resp: SendMessageResponse = try await APIService.shared.post(
                "/api/chat/send",
                body: ["receiver_id": receiverId, "content": content]
            )
            messages.append(resp.userMsg)
            if let botReply = resp.botReply {
                // 延迟显示 bot 回复
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                messages.append(botReply)
            }
            SocketService.shared.sendMessage(
                senderId: AuthService.shared.currentUser?.id ?? 0,
                receiverId: receiverId,
                content: content
            )
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func sendMedia(to receiverId: Int, imageData: Data) async {
        do {
            let resp: UploadMediaResponse = try await APIService.shared.upload(
                "/api/chat/upload_media",
                fileData: imageData,
                fileName: "chat_image.jpg",
                fieldName: "file",
                extraFields: ["receiver_id": "\(receiverId)"]
            )
            messages.append(resp.userMsg)
            if let botReply = resp.botReply {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                messages.append(botReply)
            }
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func handleAcceptFriend(userId: Int) async {
        do {
            let _: FriendActionResponse = try await APIService.shared.post(
                "/api/friend/accept",
                body: ["user_id": userId]
            )
            await loadChatUsers()
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func handleRejectFriend(userId: Int) async {
        do {
            let _: FriendActionResponse = try await APIService.shared.post(
                "/api/friend/reject",
                body: ["user_id": userId]
            )
            await loadChatUsers()
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }
}