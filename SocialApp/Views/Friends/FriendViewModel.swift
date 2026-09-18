import Foundation
import SwiftUI

@MainActor
final class FriendViewModel: ObservableObject {
    @Published var searchResults: [FriendSearchUser] = []
    @Published var isLoading = false
    @Published var toast: ToastMessage?

    func searchUser(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        do {
            let resp: FriendSearchResponse = try await APIService.shared.get(
                "/api/friend/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
            )
            searchResults = resp.users
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
            searchResults = []
        }
        isLoading = false
    }

    func sendRequest(friendId: Int) async {
        do {
            let resp: FriendRequestResponse = try await APIService.shared.post(
                "/api/friend/request",
                body: ["friend_id": friendId]
            )
            toast = ToastMessage(message: resp.message, type: .success)
            // 更新搜索结果状态
            if let idx = searchResults.firstIndex(where: { $0.id == friendId }) {
                searchResults[idx] = FriendSearchUser(
                    id: searchResults[idx].id,
                    username: searchResults[idx].username,
                    nickname: searchResults[idx].nickname,
                    avatar: searchResults[idx].avatar,
                    bio: searchResults[idx].bio,
                    friendStatus: "sent"
                )
            }
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }
}