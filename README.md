# 社交圈 iOS App

社交圈情侣社交平台的 iOS 原生客户端，使用 Swift + SwiftUI 构建。

## 功能

- 动态流：浏览、发布、点赞、评论
- 即时聊天：文本消息 + 图片消息，支持机器人自动回复
- 每日打卡：日历视图展示打卡记录
- 个人主页：编辑资料、上传头像
- 好友管理：搜索、添加、接受/拒绝好友请求

## 系统要求

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- macOS 14+ (Sonoma) — 构建环境需 macOS

## 获取安装包 (IPA)

> **重要提示**：iOS 应用只能在 **macOS + Xcode** 环境下编译打包。Windows 无法直接生成 IPA。

### 方式一：GitHub Actions 自动构建（推荐）

1. 将项目推送到 GitHub 仓库
2. 进入 GitHub 仓库 → **Actions** → **Build iOS IPA**
3. 点击 **Run workflow** → 选择 **Release** → 开始构建
4. 构建完成后下载 `SocialApp-Release.ipa` 附件
5. 使用 [AltStore](https://altstore.io) / [SideStore](https://sidestore.io) / Sideloadly 安装到 iPhone

> 免费 Apple ID 即可签名安装到自己的 iPhone（每 7 天需刷新）

### 方式二：本地 Xcode 构建（有 Mac）

```bash
# 安装 XcodeGen
brew install xcodegen

# 生成项目
cd SocialApp-iOS
xcodegen generate

# 打开 Xcode
open SocialApp.xcodeproj
```

然后在 Xcode 中：
1. 选择你的 Apple ID Team（个人免费账号也可）
2. 设备选择 **Any iOS Device**
3. Product → **Archive**
4. Distribute App → **Development** → 导出 IPA

### 方式三：Simulator 直接运行（有 Mac，无需开发者账号）

```bash
# 直接推送到模拟器
xcodegen generate
xcodebuild -project SocialApp.xcodeproj -scheme SocialApp -destination 'platform=iOS Simulator,name=iPhone 15' build
open SocialApp.xcodeproj  # 然后 ⌘R 运行
```

## 配置服务器地址

编辑 `SocialApp/Config.swift`：

```swift
static let baseURL = "http://YOUR_SERVER_IP:5000"
```

> iOS 默认允许 HTTP 连接（Info.plist 已配置 `NSAllowsArbitraryLoads`）

## 安装 IPA 到 iPhone（无需越狱）

| 工具 | 要求 | 说明 |
|------|------|------|
| [AltStore](https://altstore.io) | 免费 Apple ID | 每 7 天续签，最多 3 个应用 |
| [SideStore](https://sidestore.io) | 免费 Apple ID | 类似 AltStore，支持无线续签 |
| [Sideloadly](https://sideloadly.io) | 免费 Apple ID | Windows/Mac 均可，USB 安装 |
| [TrollStore](https://github.com/opa334/TrollStore) | 越狱/巨魔 | 永久签名，无限制 |

## 安装到模拟器（无开发者账号）

```bash
# 1. 生成 .app 包
xcodebuild -project SocialApp.xcodeproj \
  -scheme SocialApp \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build

# 2. 推送到模拟器
xcrun simctl install booted \
  ./DerivedData/Build/Products/Debug-iphonesimulator/SocialApp.app
```

## SocketIO 实时推送（可选）

默认使用 HTTP 轮询（3 秒间隔）。如需实时推送：

1. 取消注释 `Package.swift` 中的 SocketIO 依赖
2. 在 `SocketService.swift` 中启用 `version 2`（完整 SocketIO 版本）

## GitHub Secrets 说明

在仓库 Settings → Secrets and variables → Actions 添加：

| Secret | 必填 | 说明 |
|--------|------|------|
| `APPLE_DEVELOPER_EMAIL` | 否 | Apple ID 邮箱 |
| `APPLE_APP_SPECIFIC_PASSWORD` | 否 | Apple ID 专用密码（需在 appleid.apple.com 生成） |
| `MATCH_REPO` | 否 | fastlane match 证书仓库 URL |
| `MATCH_PASSWORD` | 否 | fastlane match 仓库密码 |

## 项目结构

```
SocialApp-iOS/
├── .github/
│   ├── workflows/build-ipa.yml  # GitHub Actions 构建工作流
│   ├── exportOptions.plist       # IPA 导出配置
│   └── Fastfile                  # Fastlane 自动化
├── Package.swift                 # SPM 依赖
├── project.yml                   # XcodeGen 配置
├── README.md
└── SocialApp/
    ├── SocialAppApp.swift        # App 入口
    ├── ContentView.swift         # Tab 导航
    ├── Config.swift              # 服务器配置
    ├── Info.plist                # 应用信息
    ├── Models/                   # 数据模型
    ├── Services/                 # 网络服务
    ├── Views/                    # 视图层
    │   ├── Auth/                 # 登录/注册
    │   ├── Feed/                 # 动态流
    │   ├── Chat/                 # 聊天
    │   ├── Profile/              # 个人主页
    │   ├── Friends/              # 好友管理
    │   └── Components/           # 通用组件
    └── Resources/                # 资源文件