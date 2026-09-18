import Foundation

// MARK: - API 错误
enum APIError: LocalizedError {
    case invalidURL
    case httpError(Int, String)
    case decodingError(String)
    case networkError(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的 URL"
        case .httpError(let code, let msg): return "\(msg) (\(code))"
        case .decodingError(let msg): return "数据解析失败: \(msg)"
        case .networkError(let msg): return "网络错误: \(msg)"
        case .unauthorized: return "请先登录"
        }
    }
}

// MARK: - API 服务
final class APIService {
    static let shared = APIService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }

    // MARK: - 通用 GET 请求
    func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: Config.baseURL + path) else {
            throw APIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: req)
        try checkResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 通用 POST 请求（JSON）
    func post<T: Decodable>(_ path: String, body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: Config.baseURL + path) else {
            throw APIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            req.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, response) = try await session.data(for: req)
        try checkResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 通用 POST 请求（Form 表单，用于登录/注册）
    func postForm<T: Decodable>(_ path: String, fields: [String: String]) async throws -> T {
        guard let url = URL(string: Config.baseURL + path) else {
            throw APIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = fields.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        req.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await session.data(for: req)
        try checkResponse(response)

        // 尝试解析 JSON；如果失败返回空结构
        if let result = try? decoder.decode(T.self, from: data) {
            return result
        }
        // 对 string 类型兼容
        if T.self == String.self, let str = String(data: data, encoding: .utf8) {
            return str as! T
        }
        throw APIError.decodingError("无法解析响应")
    }

    // MARK: - 文件上传（multipart）
    func upload<T: Decodable>(_ path: String, fileData: Data, fileName: String, fieldName: String = "file", extraFields: [String: String] = [:]) async throws -> T {
        guard let url = URL(string: Config.baseURL + path) else {
            throw APIError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // Extra fields
        for (key, value) in extraFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // File
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        let (data, response) = try await session.data(for: req)
        try checkResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 通用 POST 返回原文（用于 form 提交后读取 cookie）
    @discardableResult
    func postFormRaw(_ path: String, fields: [String: String]) async throws -> String {
        guard let url = URL(string: Config.baseURL + path) else {
            throw APIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = fields.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        req.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await session.data(for: req)
        try checkResponse(response)
        return String(data: data, encoding: .utf8) ?? ""
    }

    // MARK: - 检查 HTTP 响应
    private func checkResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("无效的响应")
        }
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 302:
            // Flask 重定向表示未登录，但不等同于错误
            // 检查 Location header
            if let location = httpResponse.allHeaderFields["Location"] as? String,
               location.contains("login") {
                throw APIError.unauthorized
            }
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.httpError(404, "请求的资源不存在")
        case 500:
            throw APIError.httpError(500, "服务器内部错误")
        default:
            throw APIError.httpError(httpResponse.statusCode, "请求失败")
        }
    }

    // MARK: - 下载图片
    func downloadImage(from url: URL) async throws -> Data {
        let (data, _) = try await session.data(from: url)
        return data
    }
}

// MARK: - 辅助类型
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        _encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - 空响应
struct EmptyResponse: Codable {}

// MARK: - 错误响应
struct ErrorResponse: Decodable {
    let error: String?
}