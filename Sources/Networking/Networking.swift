import Foundation

enum APIError: Error, Equatable {
    case unauthorized
}

public struct RequestExecutor {
    public init() {}
    
    public func execute<T: Codable & Sendable>(_ networkRequest: NetworkRequest) async throws -> T {
        let urlRequest = try await createUrlRequest(for: networkRequest)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let httpResponse = response as? HTTPURLResponse
        switch httpResponse?.statusCode {
        case 200:
            let decoder = JSONDecoder()
            if let dateDecodingStrategy = networkRequest.dateDecodingStrategy {
                decoder.dateDecodingStrategy = dateDecodingStrategy
            }
            let codable = try decoder.decode(T.self, from: data)
            return codable
        case 401:
            throw APIError.unauthorized
        default:
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            throw """
                The backendClient failed to return data with status code \(statusCode). 
                Description: \(httpResponse?.description ?? "nil")
            """
        }
    }
    
    private func createUrlRequest(for networkRequest: NetworkRequest) async throws -> URLRequest {
        var urlRequest = networkRequest.urlRequest
        let headers = try await networkRequest.headers

        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        if let body = networkRequest.body {
            let jsonEncoder = JSONEncoder()
            if let dateEncodingStrategy = networkRequest.dateEncodingStrategy {
                jsonEncoder.dateEncodingStrategy = dateEncodingStrategy
            }
            let encodedBody = try jsonEncoder.encode(body)
            urlRequest.httpBody = encodedBody
        }

        return urlRequest
    }
    
}
