import Foundation

// MARK: - SocketIO 服务（实时聊天）
//
// 由于 SocketIO SDK 需要外部依赖，这里提供两个版本：
// 1. 有 SocketIO SDK 时的完整版本（下方被注释）
// 2. 无 SocketIO 时的轮询降级版本（当前激活）
//
// 要启用完整 SocketIO，在 Package.swift 添加依赖并取消注释下方代码。

import Foundation

// =====================================================================
// 版本 1：轮询降级方案（无需 SocketIO SDK）
// =====================================================================

@MainActor
final class SocketService: ObservableObject {
    static let shared = SocketService()

    @Published var isConnected = false
    @Published var onlineUserIds: Set<Int> = []

    private var pollingTimer: Timer?
    private var lastMessageId = 0
    weak var delegate: SocketServiceDelegate?

    private init() {}

    func connect() {
        // 轮询方式：每 3 秒检查新消息
        startPolling()
        isConnected = true
    }

    func disconnect() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        isConnected = false
    }

    func sendMessage(senderId: Int, receiverId: Int, content: String) {
        // 消息通过 REST API 发送，socket 只负责通知
        // 通知接收方有新消息
        notifyNewMessage(senderId: senderId, receiverId: receiverId)
    }

    func sendMediaMessage(senderId: Int, receiverId: Int, mediaType: String, mediaUrl: String) {
        notifyNewMessage(senderId: senderId, receiverId: receiverId)
    }

    private func notifyNewMessage(senderId: Int, receiverId: Int) {
        delegate?.onNewMessage(senderId: senderId, receiverId: receiverId)
    }

    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.pollMessages()
            }
        }
    }

    private func pollMessages() async {
        // 轮询实现放在 ChatViewModel 中，这里只做状态维护
    }
}

protocol SocketServiceDelegate: AnyObject {
    func onNewMessage(senderId: Int, receiverId: Int)
    func onOnlineUsersChanged(_ userIds: [Int])
}

// =====================================================================
// 版本 2：完整 SocketIO（需要 socket.io-client-swift SDK）
// =====================================================================
//
// 取消注释以下代码，并在 Package.swift 中添加依赖即可启用
//
// import SocketIO
//
// @MainActor
// final class SocketService: ObservableObject {
//     static let shared = SocketService()
//
//     @Published var isConnected = false
//     @Published var onlineUserIds: Set<Int> = []
//
//     private var manager: SocketManager!
//     private var socket: SocketIOClient!
//     weak var delegate: SocketServiceDelegate?
//
//     private init() {}
//
//     func connect() {
//         guard let url = URL(string: Config.socketURL) else { return }
//         manager = SocketManager(socketURL: url, config: [.log(false), .compress])
//         socket = manager.defaultSocket
//
//         socket.on(clientEvent: .connect) { [weak self] _, _ in
//             self?.isConnected = true
//         }
//         socket.on(clientEvent: .disconnect) { [weak self] _, _ in
//             self?.isConnected = false
//         }
//
//         socket.on("new_message") { [weak self] data, _ in
//             guard let dict = data.first as? [String: Any],
//                   let senderId = dict["sender_id"] as? Int,
//                   let receiverId = dict["receiver_id"] as? Int else { return }
//             self?.delegate?.onNewMessage(senderId: senderId, receiverId: receiverId)
//         }
//
//         socket.on("online_users") { [weak self] data, _ in
//             if let ids = data.first as? [Int] {
//                 self?.onlineUserIds = Set(ids)
//                 self?.delegate?.onOnlineUsersChanged(ids)
//             }
//         }
//
//         socket.connect()
//     }
//
//     func disconnect() {
//         socket?.disconnect()
//         isConnected = false
//     }
//
//     func join(userId: Int) {
//         socket.emit("join", ["user_id": userId])
//     }
//
//     func sendMessage(senderId: Int, receiverId: Int, content: String) {
//         socket.emit("notify_new_message", [
//             "sender_id": senderId,
//             "receiver_id": receiverId,
//             "content": content
//         ])
//     }
//
//     func sendMediaMessage(senderId: Int, receiverId: Int, mediaType: String, mediaUrl: String) {
//         socket.emit("notify_new_message", [
//             "sender_id": senderId,
//             "receiver_id": receiverId,
//             "media_type": mediaType,
//             "media_url": mediaUrl
//         ])
//     }
// }