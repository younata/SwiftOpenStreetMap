import Foundation
import FutureHTTP
import CBGPromise

public protocol OverpassService {
    func query(_ query: String) -> Future<Result<Response, OverpassServiceError>>
    func raw(query: String) -> Future<Result<[String: Any], OverpassServiceError>>
}

public struct DefaultOverpassService: OverpassService {
    private let baseURL: URL
    private let httpClient: HTTPClient

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    public init(baseURL: URL, httpClient: HTTPClient) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    public func query(_ query: String) -> Future<Result<SwiftOpenStreetMap.Response, OverpassServiceError>> {
        return self.data(query: query).map { (result: Result<Data, OverpassServiceError>) -> Result<Response, OverpassServiceError> in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                do {
                    return .success(try decoder.decode(Response.self, from: data))
                } catch {
                    return .failure(.unknown)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    public func raw(query: String) -> Future<Result<[String: Any], OverpassServiceError>> {
        return self.data(query: query).map { (result: Result<Data, OverpassServiceError>) -> Result<[String: Any], OverpassServiceError> in
            switch result {
            case .success(let data):
                do {
                    return .success(try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:])
                } catch {
                    return .failure(.unknown)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    private func data(query: String) -> Future<Result<Data, OverpassServiceError>> {
        var request = URLRequest(url: self.baseURL)
        request.httpMethod = "POST"
        request.httpBody = self.format(query: query).data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return self.httpClient.request(request).map { result -> Result<Data, OverpassServiceError> in
            switch result {
            case .success(let response):
                guard let status = response.status else {
                    return .failure(.unknown)
                }
                switch (status) {
                case .ok:
                    return .success(response.body)
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
