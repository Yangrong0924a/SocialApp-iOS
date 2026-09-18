import Foundation
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var toast: ToastMessage?

    private var currentPage = 1
    private let pageSize = 10

    func loadPosts() async {
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1
        do {
            let resp: PostListResponse = try await APIService.shared.get("/api/posts?page=1")
            posts = resp.posts
            hasMore = resp.hasNext
            currentPage = resp.page
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        currentPage += 1
        do {
            let resp: PostListResponse = try await APIService.shared.get("/api/posts?page=\(currentPage)")
            posts.append(contentsOf: resp.posts)
            hasMore = resp.hasNext
            currentPage = resp.page
        } catch {
            currentPage -= 1
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
        isLoading = false
    }

    func toggleLike(postId: Int) async {
        do {
            let resp: LikeResponse = try await APIService.shared.post("/api/posts/\(postId)/like")
            if let idx = posts.firstIndex(where: { $0.id == postId }) {
                posts[idx] = Post(
                    id: posts[idx].id,
                    userId: posts[idx].userId,
                    content: posts[idx].content,
                    image: posts[idx].image,
                    createdAt: posts[idx].createdAt,
                    author: posts[idx].author,
                    likeCount: resp.likeCount,
                    commentCount: posts[idx].commentCount,
                    isLiked: resp.liked
                )
            }
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
        }
    }

    func createPost(content: String, imageData: Data?) async -> Bool {
        do {
            if let imageData = imageData {
                let _: CreatePostResponse = try await APIService.shared.upload(
                    "/api/posts",
                    fileData: imageData,
                    fileName: "post_image.jpg",
                    fieldName: "image",
                    extraFields: ["content": content]
                )
            } else {
                let _: CreatePostResponse = try await APIService.shared.post(
                    "/api/posts",
                    body: ["content": content]
                )
            }
            await loadPosts()
            return true
        } catch {
            toast = ToastMessage(message: error.localizedDescription, type: .error)
            return false
        }
    }
}