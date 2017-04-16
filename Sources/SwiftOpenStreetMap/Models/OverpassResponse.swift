import Foundation
import SwiftyJSON

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}()

public struct Response: Equatable {
    public var version: String
    public var generator: String
    public var timestamp: Date
    public var copyright: String

    public var elements: [SwiftOpenStreetMap.Element]

    public static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.version == rhs.version &&
            lhs.generator == rhs.generator &&
            lhs.timestamp == rhs.timestamp &&
            lhs.copyright == rhs.copyright &&
            lhs.elements == rhs.elements
    }

    public init(version: String, generator: String, timestamp: Date, copyright: String, elements: [Element]) {
        self.version = version
        self.generator = generator
        self.timestamp = timestamp
        self.copyright = copyright

        let nodes = elements.flatMap { $0.asNode() }
        let ways = elements.flatMap { try! $0.asWay()?.with(nodes: nodes) }

        self.elements = nodes.map { Element.node($0) } + ways.map { Element.way($0) }
    }

    public init?(json: JSON) {
        let version: String
        if let doubleVersion = json["version"].double {
            version = String(doubleVersion)
        } else if let stringVersion = json["version"].string {
            version = stringVersion
        } else { return nil }
        guard let generator = json["generator"].string,
            let osm3s = json["osm3s"].dictionary,
            let dateString = osm3s["timestamp_osm_base"]?.string,
            let date = dateFormatter.date(from: dateString),
            let copyright = osm3s["copyright"]?.string,
            let elementsArray = json["elements"].array else {
                return nil
        }

        let elements = elementsArray.flatMap { $0.Element }

        self.init(version: version, generator: generator, timestamp: date, copyright: copyright, elements: elements)
    }
}

public struct Node: Equatable {
    public var id: Int
    public var location: Location
    public var tags: [String: String]

    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id &&
            lhs.location == rhs.location &&
            lhs.tags == rhs.tags
    }

    public init(id: Int, location: Location, tags: [String: String]) {
        self.id = id
        self.location = location
        self.tags = tags
    }
}

public struct Way: Equatable {
    public var id: Int
    public var nodeIds: [Int]
    public var tags: [String: String]

    public enum Error: Swift.Error {
        case insufficientData
    }

    public private(set) var nodes: [Node] = []

    public mutating func add(nodes: [Node]) throws {
        self.nodes = []
        for id in self.nodeIds {
            if let node = nodes.first(where: { $0.id == id }) {
                self.nodes.append(node)
            } else {
                throw Error.insufficientData
            }
        }
    }

    fileprivate func with(nodes: [Node]) throws -> Way {
        var way = Way(id: self.id, nodeIds: self.nodeIds, tags: self.tags)

        try way.add(nodes: nodes)

        return way
    }

    public static func == (lhs: Way, rhs: Way) -> Bool {
        return lhs.id == rhs.id &&
            lhs.tags == rhs.tags &&
            lhs.nodeIds == rhs.nodeIds &&
            lhs.nodes == rhs.nodes
    }

    public init(id: Int, nodeIds: [Int], tags: [String: String]) {
        self.id = id
        self.nodeIds = nodeIds
        self.tags = tags
    }

    public init(id: Int, nodes: [Node], tags: [String: String]) {
        self.id = id
        self.nodes = nodes
        self.nodeIds = nodes.map { return $0.id }
        self.tags = tags
    }
}

public enum Element: Equatable {
    case node(Node)
    case way(Way)

    public static func == (lhs: Element, rhs: Element) -> Bool {
        switch (lhs, rhs) {
        case (.node(let lhsNode), .node(let rhsNode)):
            return lhsNode == rhsNode
        case (.way(let lhsWay), .way(let rhsWay)):
            return lhsWay == rhsWay
        default:
            return false
        }
    }

    public func asNode() -> Node? {
        if case let .node(n) = self {
            return n
        }
        return nil
    }

    public func asWay() -> Way? {
        if case let .way(w) = self {
            return w
        }
        return nil
    }

    fileprivate init?(json: JSON) {
        guard let jsonType = json["type"].string,
            let id = json["id"].int,
            let jsonTags = json["tags"].dictionary else {
                return nil
        }

        var tags: [String: String] = [:]
        for (key, jsonVal) in jsonTags {
            if let val = jsonVal.string {
                tags[key] = val
            } else {
                return nil
            }
        }


        switch jsonType {
        case "node":
            guard let location = json.location else { return nil }
            self = .node(Node(id: id, location: location, tags: tags))
        case "way":
            guard let jsonNodes = json["nodes"].array else { return nil }
            let nodes = jsonNodes.flatMap { $0.int }
            self = .way(Way(id: id, nodeIds: nodes, tags: tags))
        default:
            return nil
        }
    }
}

public struct Location: Equatable {
    public var latitude: Double
    public var longitude: Double

    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    fileprivate init?(json: JSON) {
        guard let latitude = json["lat"].double,
            let longitude = json["lon"].double else {
                return nil
        }
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension JSON {
    public var Response: SwiftOpenStreetMap.Response? { return SwiftOpenStreetMap.Response(json: self) }
    public var Element: SwiftOpenStreetMap.Element? { return SwiftOpenStreetMap.Element(json: self) }
    public var location: Location? { return Location(json: self) }
}
