import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var posts: [Post] = []
    @Published var checkedInToday = false
    @Published var checkinStreak = 0
    @Published var friendStatus = "none"
    @Published var isLoading = true
    @Published var toast: ToastMessage?

    // 打卡日历
    @Published var checkinDates: [String] = []
    @Published var totalThisMonth = 0
    @Published var totalAll = 0

    func loadProfile(userId: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let resp: UserDetailResponse = try await APIService.shared.get("/api/profile/\(userId)")
            user = resp.user
            posts = resp.posts
            checkedInToday = resp.checkedInToday
            checkinStreak = resp.checkinStreak
            friendStatus = resp.friendStatus
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func loadCheckinRecords(userId: Int, year: Int, month: Int) async {
        do {
            let resp: CheckinRecordResponse = try await APIService.shared.get(
                "/api/checkin/records?year=\(year)&month=\(month)&total_all=1"
            )
            checkinDates = resp.checkinDates
            totalThisMonth = resp.totalThisMonth
            totalAll = resp.totalAll ?? 0
            checkinStreak = resp.checkinStreak
        } catch {
            // 静默失败
        }
    }

    func doCheckin() async {
        do {
            let resp: CheckinResponse = try await APIService.shared.post("/api/checkin")
            if resp.ok {
                checkedInToday = true
                checkinStreak = resp.checkinStreak
                toast = ToastMessage(message: resp.msg, type: .success)
            }
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func sendFriendRequest(userId: Int) async {
        do {
            let resp: FriendRequestResponse = try await APIService.shared.post(
                "/api/friend/request",
                body: ["friend_id": userId]
            )
            friendStatus = resp.status
            toast = ToastMessage(message: resp.message, type: .success)
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func removeFriend(userId: Int) async {
        do {
            let resp: FriendActionResponse = try await APIService.shared.post(
                "/api/friend/remove",
                body: ["friend_id": userId]
            )
            friendStatus = "none"
            toast = ToastMessage(message: resp.message, type: .success)
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }
}