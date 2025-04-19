import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum Scheme: String {
    case https
}

public typealias Headers = [String: String]

public protocol NetworkRequest: Sendable {
    var baseUrl: String { get }
    var scheme: Scheme { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var body: Encodable? { get }
    var headers: Headers { get async throws }
    var queryItems: [URLQueryItem]? { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { get }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? { get }
}

extension NetworkRequest {
    private var urlComponents: URLComponents? {
        guard let urlComponents = URLComponents(string: baseUrl) else {
            return nil
        }
        return urlComponents
    }

    var urlRequest: URLRequest {
        guard var urlComponents else {
            fatalError("URL components could not be created.")
        }
        urlComponents.scheme = scheme.rawValue
        urlComponents.queryItems = queryItems
        urlComponents.path = urlComponents.path + path
        guard let url = urlComponents.url else {
            fatalError("URL could not be created.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        return request
    }
}
