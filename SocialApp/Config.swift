import Foundation

enum Config {
    // ========== 服务器地址 ==========
    // 开发时用电脑 IP，发布时替换为实际服务器域名
    #if DEBUG
    static let baseURL = "http://10.152.3.93:5000"
    #else
    static let baseURL = "http://10.152.3.93:5000"
    #endif

    static let socketURL = baseURL

    // ========== 文件上传限制 ==========
    static let maxImageSize: Int64 = 10 * 1024 * 1024   // 10MB
    static let maxAudioSize: Int64 = 20 * 1024 * 1024   // 20MB
    static let maxVideoSize: Int64 = 50 * 1024 * 1024   // 50MB
}