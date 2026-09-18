import Foundation

// MARK: - 认证服务（管理登录状态）
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isLoggedIn = false
    @Published var isLoading = false

    private let defaults = UserDefaults.standard
    private let userKey = "current_user_data"

    private init() {
        // 尝试恢复登录状态
        if let data = defaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isLoggedIn = true
        }
    }

    // MARK: - 登录
    func login(username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // Flask 登录表单提交
        try await APIService.shared.postFormRaw("/login", fields: [
            "username": username,
            "password": password
        ])

        // 获取当前用户信息
        let me: MeResponse = try await APIService.shared.get("/api/me")
        currentUser = User(
            id: me.id,
            username: me.username,
            email: me.email,
            nickname: me.nickname,
            avatar: me.avatar,
            bio: nil,
            ownerId: me.ownerId
        )
        isLoggedIn = true
        saveUser()
    }

    // MARK: - 注册
    func register(username: String, email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        try await APIService.shared.postFormRaw("/register", fields: [
            "username": username,
            "email": email,
            "password": password
        ])

        let me: MeResponse = try await APIService.shared.get("/api/me")
        currentUser = User(
            id: me.id,
            username: me.username,
            email: me.email,
            nickname: me.nickname,
            avatar: me.avatar,
            bio: nil,
            ownerId: me.ownerId
        )
        isLoggedIn = true
        saveUser()
    }

    // MARK: - 登出
    func logout() {
        Task {
            try? await APIService.shared.postFormRaw("/logout", fields: [:])
        }
        currentUser = nil
        isLoggedIn = false
        defaults.removeObject(forKey: userKey)
    }

    // MARK: - 刷新用户信息
    func refreshUser() async {
        guard isLoggedIn else { return }
        do {
            let me: MeResponse = try await APIService.shared.get("/api/me")
            if var user = currentUser {
                user.nickname = me.nickname
                user.avatar = me.avatar
                user.email = me.email
                currentUser = user
                saveUser()
            }
        } catch {
            if case APIError.unauthorized = error {
                logout()
            }
        }
    }

    // MARK: - 持久化
    private func saveUser() {
        guard let user = currentUser,
              let data = try? JSONEncoder().encode(user) else { return }
        defaults.set(data, forKey: userKey)
    }
}