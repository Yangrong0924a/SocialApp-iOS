import SwiftUI

struct PostRow: View {
    let post: Post
    let onLike: () -> Void
    @State private var showComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 作者信息
            HStack(spacing: 10) {
                NavigationLink(destination: ProfileView(userId: post.userId)) {
                    CachedAsyncImage(
                        url: post.author?.avatarURL,
                        placeholder: post.author?.displayName ?? "?",
                        size: 36
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.displayName ?? "用户\(post.userId)")
                        .font(.subheadline.weight(.semibold))
                    Text(post.formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // 内容
            if !post.content.isEmpty {
                Text(post.content)
                    .font(.body)
                    .lineLimit(6)
            }

            // 图片
            if let imageURL = post.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    case .failure:
                        Color.gray.opacity(0.2)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(Image(systemName: "photo"))
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // 操作栏
            HStack(spacing: 16) {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .gray)
                        Text("\(post.likeCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Button(action: { showComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(post.commentCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .font(.system(size: 14))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .sheet(isPresented: $showComments) {
            CommentView(postId: post.id)
        }
    }
}