import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var socket: SocketService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 动态
            FeedView()
                .tabItem {
                    Label("动态", systemImage: selectedTab == 0 ? "heart.fill" : "heart")
                }
                .tag(0)

            // Tab 2: 消息
            ChatListView()
                .tabItem {
                    Label("消息", systemImage: selectedTab == 1 ? "message.fill" : "message")
                }
                .tag(1)

            // Tab 3: 我的
            NavigationStack {
                ProfileView(userId: auth.currentUser?.id ?? 0)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: logout) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                            }
                        }
                    }
            }
            .tabItem {
                Label("我的", systemImage: selectedTab == 2 ? "person.fill" : "person")
            }
            .tag(2)
        }
        .tint(.blue)
        .onAppear {
            // 配置 Tab Bar 外观
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    private func logout() {
        socket.disconnect()
        auth.logout()
    }
}