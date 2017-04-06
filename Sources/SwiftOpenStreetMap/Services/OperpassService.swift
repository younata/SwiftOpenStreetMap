import Foundation
import FutureHTTP
import CBGPromise
import SwiftyJSON
import Result

protocol OverpassService {
}

struct DefaultOverpassService: OverpassService {
    private let baseURL: URL
    private let httpClient: HTTPClient

    init(baseURL: URL, httpClient: HTTPClient) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    func query(_ query: String) -> Future<Result<OverpassResponse, OverpassServiceError>> {
        var request = URLRequest(url: self.baseURL)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return self.httpClient.request(request).map { result -> Result<OverpassResponse, OverpassServiceError> in
            switch result {
            case .success(let response):
                guard let status = response.status else {
                    return .failure(.unknown)
                }
                switch (status) {
                case .ok:
                    let json = JSON(rawData: response.body)
                    if let overpassResponse = json.overpassResponse {
                        return .success(overpassResponse)
                    } else {
                        return .failure(.unknown)
                    }
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
