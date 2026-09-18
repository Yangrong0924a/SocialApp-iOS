import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索用户...", text: $searchText)
                        .autocapitalization(.none)
                        .onSubmit { Task { await vm.searchUser(query: searchText) } }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            vm.searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                if vm.isLoading {
                    ProgressView()
                        .padding()
                } else if vm.searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("未找到用户")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    List(vm.searchResults) { user in
                        HStack(spacing: 12) {
                            CachedAsyncImage(
                                url: user.avatarURL,
                                placeholder: user.displayName,
                                size: 44
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.displayName)
                                    .font(.body.weight(.medium))
                                if let bio = user.bio, !bio.isEmpty {
                                    Text(bio)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            switch user.friendStatus {
                            case "none":
                                Button(action: { Task { await vm.sendRequest(friendId: user.id) } }) {
                                    Text("添加")
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            case "sent":
                                Text("已请求")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            case "friend":
                                Text("好友")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            case "received":
                                Text("待接受")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("添加好友")
            .navigationBarTitleDisplayMode(.inline)
            .toast(toast: $vm.toast)
        }
    }
}