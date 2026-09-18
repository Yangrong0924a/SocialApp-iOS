import SwiftUI

@main
struct SocialAppApp: App {
    @StateObject private var auth = AuthService.shared
    @StateObject private var socket = SocketService.shared

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                ContentView()
                    .environmentObject(auth)
                    .environmentObject(socket)
                    .onAppear {
                        socket.connect()
                    }
                    .onDisappear {
                        socket.disconnect()
                    }
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}