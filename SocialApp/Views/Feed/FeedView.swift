import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack {
                if vm.posts.isEmpty && !vm.isLoading {
                    emptyView
                } else {
                    postList
                }

                if vm.isLoading && vm.posts.isEmpty {
                    ProgressView()
                }
            }
            .navigationTitle("动态")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView { content, imageData in
                    Task {
                        if await vm.createPost(content: content, imageData: imageData) {
                            showCreatePost = false
                        }
                    }
                }
            }
            .toast(toast: $vm.toast)
        }
        .task { await vm.loadPosts() }
    }

    private var postList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.posts) { post in
                    PostRow(post: post, onLike: { Task { await vm.toggleLike(postId: post.id) } })
                        .onAppear {
                            if post.id == vm.posts.last?.id {
                                Task { await vm.loadMore() }
                            }
                        }
                }

                if vm.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .refreshable { await vm.loadPosts() }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("暂无动态")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("点击右上角发布第一条动态")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}