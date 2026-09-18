import SwiftUI

struct UserAvatarView: View {
    let url: URL?
    let name: String
    var size: CGFloat = 40

    var body: some View {
        CachedAsyncImage(url: url, placeholder: name, size: size)
    }
}

// MARK: - 加载中指示器
struct LoadingView: View {
    var message: String = "加载中..."

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 空状态
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String?

    init(icon: String = "tray", title: String, message: String? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.4))
            Text(title)
                .font(.title3)
                .foregroundColor(.secondary)
            if let msg = message {
                Text(msg)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}