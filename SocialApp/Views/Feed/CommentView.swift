import SwiftUI

struct CommentView: View {
    let postId: Int
    @State private var comments: [Comment] = []
    @State private var newComment = ""
    @State private var isLoading = true
    @State private var toast: ToastMessage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 评论列表
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if comments.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("暂无评论")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(comments) { comment in
                                HStack(alignment: .top, spacing: 10) {
                                    NavigationLink(destination: ProfileView(userId: comment.userId)) {
                                        CachedAsyncImage(
                                            url: comment.author?.avatarURL,
                                            placeholder: comment.author?.displayName ?? "?",
                                            size: 32
                                        )
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(comment.author?.displayName ?? "用户")
                                                .font(.subheadline.weight(.semibold))
                                            Text(comment.formattedTime)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(comment.content)
                                            .font(.body)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }

                // 输入栏
                Divider()
                HStack(spacing: 8) {
                    TextField("写评论...", text: $newComment)
                        .textFieldStyle(.roundedBorder)

                    Button("发送") {
                        Task { await submitComment() }
                    }
                    .fontWeight(.semibold)
                    .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
            .toast(toast: $toast)
        }
        .task { await loadComments() }
    }

    private func loadComments() async {
        isLoading = true
        do {
            comments = try await APIService.shared.get("/api/posts/\(postId)/comments")
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
        isLoading = false
    }

    private func submitComment() async {
        let text = newComment.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        newComment = ""
        do {
            let comment: Comment = try await APIService.shared.post(
                "/api/posts/\(postId)/comments",
                body: ["content": text]
            )
            comments.append(comment)
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }
}