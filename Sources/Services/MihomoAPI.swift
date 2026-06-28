import Foundation

enum MihomoAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Mihomo service URL."
        case .requestFailed(let code):
            return "Request failed with status code \(code)."
        case .emptyResponse:
            return "The service returned an empty response."
        }
    }
}

struct MihomoProxiesResponse: Decodable {
    let proxies: [String: ProxyItem]
    let orderedKeys: [String]
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let proxiesContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: CodingKeys(stringValue: "proxies")!)
        
        var proxiesDict: [String: ProxyItem] = [:]
        var keys: [String] = []
        
        for key in proxiesContainer.allKeys {
            let proxy = try proxiesContainer.decode(ProxyItem.self, forKey: key)
            proxiesDict[key.stringValue] = proxy
            keys.append(key.stringValue)
        }
        
        self.proxies = proxiesDict
        self.orderedKeys = keys
    }
}

struct MihomoConfigsResponse: Codable {
    let mode: String
}

struct ProxyItem: Codable {
    let name: String
    let type: String
    let now: String?
    let all: [String]?
    let history: [HistoryItem]?
}

struct HistoryItem: Codable {
    let time: String
    let delay: Int
}

class MihomoAPI {
    static let shared = MihomoAPI()
    
    private init() {}
    
    private func makeRequest(url: URL, secret: String, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let trimmedSecret = secret.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSecret.isEmpty {
            request.setValue("Bearer \(trimmedSecret)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        request.timeoutInterval = 8.0 // 8 second timeout
        return request
    }
    
    func fetchProxies(service: MihomoService) async throws -> MihomoProxiesResponse {
        // Ensure URL starts with http:// or https://
        var urlString = service.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        
        guard let baseURL = URL(string: urlString) else {
            throw MihomoAPIError.invalidURL
        }
        let url = baseURL.appendingPathComponent("proxies")
        
        let request = makeRequest(url: url, secret: service.secret)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw MihomoAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(MihomoProxiesResponse.self, from: data)
        return result
    }
    
    func switchNode(service: MihomoService, groupName: String, nodeName: String) async throws {
        var urlString = service.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        
        guard let escapedGroupName = groupName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(urlString)/proxies/\(escapedGroupName)") else {
            throw MihomoAPIError.invalidURL
        }
        
        let bodyObject = ["name": nodeName]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyObject)
        
        let request = makeRequest(url: url, secret: service.secret, method: "PUT", body: bodyData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 204 || httpResponse.statusCode == 200 else {
            throw MihomoAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
    
    func testLatency(service: MihomoService, groupName: String) async throws {
        var urlString = service.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        
        guard let escapedGroupName = groupName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(urlString)/proxies/\(escapedGroupName)/delay?timeout=2000&url=http://www.gstatic.com/generate_204") else {
            throw MihomoAPIError.invalidURL
        }
        
        let request = makeRequest(url: url, secret: service.secret)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw MihomoAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
    
    func testNodeLatency(service: MihomoService, nodeName: String) async throws -> Int {
        var urlString = service.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        
        guard let escapedNodeName = nodeName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(urlString)/proxies/\(escapedNodeName)/delay?timeout=2000&url=http://www.gstatic.com/generate_204") else {
            throw MihomoAPIError.invalidURL
        }
        
        let request = makeRequest(url: url, secret: service.secret)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw MihomoAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        struct DelayResponse: Codable {
            let delay: Int
        }
        
        let delayResponse = try JSONDecoder().decode(DelayResponse.self, from: data)
        return delayResponse.delay
    }
    
    func fetchMode(service: MihomoService) async throws -> String {
        var urlString = service.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        
        guard let baseURL = URL(string: urlString) else {
            throw MihomoAPIError.invalidURL
        }
        let url = baseURL.appendingPathComponent("configs")
        
        let request = makeRequest(url: url, secret: service.secret)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw MihomoAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(MihomoConfigsResponse.self, from: data)
        return result.mode
    }
    
    func updateMode(service: MihomoService, mode: String) async throws {
        var urlString = service.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        
        guard let baseURL = URL(string: urlString) else {
            throw MihomoAPIError.invalidURL
        }
        let url = baseURL.appendingPathComponent("configs")
        
        let bodyObject = ["mode": mode]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyObject)
        
        let request = makeRequest(url: url, secret: service.secret, method: "PATCH", body: bodyData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 204 || httpResponse.statusCode == 200 else {
            throw MihomoAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
}
