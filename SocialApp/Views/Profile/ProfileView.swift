import SwiftUI

struct ProfileView: View {
    let userId: Int
    @StateObject private var vm = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showCalendar = false
    @EnvironmentObject var auth: AuthService

    var isSelf: Bool { userId == auth.currentUser?.id }

    var body: some View {
        ScrollView {
            if let user = vm.user {
                VStack(spacing: 20) {
                    // 头像
                    CachedAsyncImage(
                        url: user.avatarURL,
                        placeholder: user.displayName,
                        size: 80
                    )
                    .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 2))

                    // 名字
                    Text(user.displayName)
                        .font(.title2.weight(.bold))

                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // 统计数据
                    HStack(spacing: 40) {
                        statItem(value: "\(vm.posts.count)", label: "动态")
                        statItem(value: "\(vm.checkinStreak)", label: "连续打卡")
                        statItem(value: "打卡", label: "\(vm.totalAll)天")
                    }

                    // 操作按钮
                    if isSelf {
                        HStack(spacing: 16) {
                            Button(action: { vm.isLoading ? nil : Task { await vm.doCheckin() } }) {
                                HStack {
                                    Image(systemName: vm.checkedInToday ? "checkmark.circle.fill" : "calendar.badge.plus")
                                    Text(vm.checkedInToday ? "已打卡" : "今日打卡")
                                }
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(vm.checkedInToday ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .disabled(vm.checkedInToday)

                            Button(action: { showCalendar = true }) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("打卡记录")
                                }
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(20)
                            }

                            Button(action: { showEditProfile = true }) {
                                Image(systemName: "pencil")
                                    .font(.subheadline)
                                    .padding(10)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        // 非本人：好友操作
                        friendActionButton(for: vm.friendStatus, userId: user.id)
                    }

                    // 动态列表
                    if !vm.posts.isEmpty {
                        Divider()
                        HStack {
                            Image(systemName: "heart.text.clipboard")
                            Text("TA的动态")
                                .font(.headline)
                        }
                        .padding(.top, 8)

                        ForEach(vm.posts) { post in
                            PostRow(post: post, onLike: {})
                                .padding(.horizontal, -16)
                        }
                    }
                }
                .padding()
            } else if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(isSelf ? "我的" : (vm.user?.displayName ?? "个人主页"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showCalendar) {
            CalendarCheckInView(userId: userId, vm: vm)
        }
        .toast(toast: $vm.toast)
        .task { await vm.loadProfile(userId: userId) }
    }

    // MARK: - 统计项
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 好友操作按钮
    @ViewBuilder
    private func friendActionButton(for status: String, userId: Int) -> some View {
        switch status {
        case "none":
            Button(action: { Task { await vm.sendFriendRequest(userId: userId) } }) {
                Text("添加好友")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        case "sent":
            Text("已发送好友请求")
                .font(.subheadline)
                .foregroundColor(.secondary)
        case "received":
            Button(action: { Task { await vm.sendFriendRequest(userId: userId) } }) {
                Text("接受好友请求")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        case "friend":
            Button(role: .destructive, action: { Task { await vm.removeFriend(userId: userId) } }) {
                Text("删除好友")
                    .font(.subheadline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .foregroundColor(.red)
                    .cornerRadius(20)
            }
        default:
            EmptyView()
        }
    }
}