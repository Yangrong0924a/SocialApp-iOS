// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SocialApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SocialApp",
            targets: ["SocialApp"]
        ),
    ],
    dependencies: [
        // SocketIO (可选)：启用实时聊天推送
        // 取消注释以下行以启用完整 SocketIO 支持
        // .package(url: "https://github.com/socketio/socket.io-client-swift.git", from: "16.1.0"),
    ],
    targets: [
        .target(
            name: "SocialApp",
            dependencies: [
                // "SocketIO",  // 取消注释启用
            ],
            path: "SocialApp",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)