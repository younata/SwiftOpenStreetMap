import Foundation
import FutureHTTP
import CBGPromise
import SwiftyJSON
import Result

public protocol OverpassService {
    func query(_ query: String) -> Future<Result<Response, OverpassServiceError>>
}

public struct DefaultOverpassService: OverpassService {
    private let baseURL: URL
    private let httpClient: HTTPClient

    public init(baseURL: URL, httpClient: HTTPClient) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    public func query(_ query: String) -> Future<Result<Response, OverpassServiceError>> {
        return self.raw(query: query).map { result -> Result<Response, OverpassServiceError> in
            switch result {
            case .success(let json):
                if let Response = json.Response {
                    return .success(Response)
                } else {
                    return .failure(.unknown)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    public func raw(query: String) -> Future<Result<JSON, OverpassServiceError>> {
        var request = URLRequest(url: self.baseURL)
        request.httpMethod = "POST"
        request.httpBody = self.format(query: query).data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return self.httpClient.request(request).map { result -> Result<JSON, OverpassServiceError> in
            switch result {
            case .success(let response):
                guard let status = response.status else {
                    return .failure(.unknown)
                }
                switch (status) {
                case .ok:
                    return .success(JSON(data: response.body))
                case .badRequest:
                    return .failure(.syntax(query))
                case .tooManyRequests:
                    return .failure(.multipleRequests)
                case .gatewayTimeout:
                    return .failure(.load)
                default:
                    return .failure(.unknown)
                }
            case .failure(let error):
                return .failure(.client(error))
            }
        }
    }

    private func format(query: String) -> String {
        if query.hasSuffix(";") {
            return "[out:json];\(query)out;"
        } else {
            return "[out:json];\(query);out;"
        }
    }
}

public enum OverpassServiceError: Error, Equatable {
    case syntax(String)
    case multipleRequests
    case load
    case unknown
    case client(HTTPClientError)

    public static func == (lhs: OverpassServiceError, rhs: OverpassServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.syntax(let lhsSyntax), .syntax(let rhsSyntax)):
            return lhsSyntax == rhsSyntax
        case (.multipleRequests, .multipleRequests):
            return true
        case (.load, .load):
            return true
        case (.unknown, .unknown):
            return true
        case (.client(let lhsClient), .client(let rhsClient)):
            return lhsClient == rhsClient
        default:
            return false
        }
    }
}
