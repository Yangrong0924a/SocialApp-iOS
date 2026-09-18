import SwiftUI

struct ChatListView: View {
    @StateObject private var vm = ChatViewModel()

    var body: some View {
        NavigationStack {
            List {
                // 机器人
                if let bot = vm.botUser {
                    Section("小暖心") {
                        NavigationLink(destination: ChatDetailView(chatUserId: bot.id, title: bot.displayName)) {
                            HStack(spacing: 12) {
                                CachedAsyncImage(
                                    url: bot.avatarURL,
                                    placeholder: "暖",
                                    size: 44
                                )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bot.displayName)
                                        .font(.body.weight(.medium))
                                    Text("随时陪你聊天 💕")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                // 好友列表
                Section("好友") {
                    if vm.friends.isEmpty {
                        Text("暂无好友，去添加好友吧")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    ForEach(vm.friends) { friendInfo in
                        NavigationLink(destination: ChatDetailView(chatUserId: friendInfo.user.id, title: friendInfo.user.displayName)) {
                            FriendRow(friend: friendInfo)
                        }
                    }
                }

                // 待处理好友请求
                if !vm.pendingFrom.isEmpty {
                    Section("好友请求") {
                        ForEach(vm.pendingFrom) { user in
                            PendingFriendRow(user: user) {
                                Task { await vm.handleAcceptFriend(userId: user.id) }
                            } onReject: {
                                Task { await vm.handleRejectFriend(userId: user.id) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("消息")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FriendsView()) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .toast(toast: $vm.toast)
        }
        .task { await vm.loadChatUsers() }
    }
}

// MARK: - 好友行
struct FriendRow: View {
    let friend: FriendInfo

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(
                url: friend.user.avatarURL,
                placeholder: friend.user.displayName,
                size: 44
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.user.displayName)
                    .font(.body.weight(.medium))

                if let msg = friend.lastMessage {
                    Text(msg.content ?? (msg.isImage ? "[图片]" : "[文件]"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("开始聊天吧")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if friend.unread > 0 {
                Text("\(friend.unread)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 待处理请求行
struct PendingFriendRow: View {
    let user: User
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(
                url: user.avatarURL,
                placeholder: user.displayName,
                size: 40
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.body.weight(.medium))
                Text("请求添加你为好友")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onAccept) {
                Text("接受")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: onReject) {
                Text("拒绝")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
        }
    }
}