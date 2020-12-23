import Foundation

public struct Response: Decodable, Equatable {
    public var version: String
    public var generator: String
    public var timestamp: Date
    public var copyright: String

    public var ways: [Way] = [Way]()
    public var nodes: [Node] = [Node]()
    lazy public var elements: [SwiftOpenStreetMap.Element] = {
        return self.nodes.map { Element.node($0) } + self.ways.map { Element.way($0) }
    }()

    public static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.version == rhs.version &&
            lhs.generator == rhs.generator &&
            lhs.timestamp == rhs.timestamp &&
            lhs.copyright == rhs.copyright &&
            lhs.ways == rhs.ways &&
            lhs.nodes == rhs.nodes
    }

    public init(version: String, generator: String, timestamp: Date, copyright: String, elements: [Element]) {
        self.version = version
        self.generator = generator
        self.timestamp = timestamp
        self.copyright = copyright
        self.nodes = elements.compactMap { $0.asNode() }
        self.ways = elements.compactMap {
            guard let way = $0.asWay() else { return nil }
            return way.with(nodes: nodes)
        }
    }

    enum CodingKeys : String, CodingKey {
        case version
        case generator
        case osm3s
        case elements
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version: String
        if let doubleVersion = try? container.decode(Double.self, forKey: .version) {
            version = String(doubleVersion)
        } else {
            version = try container.decode(String.self, forKey: .version)
        }

        let generator = try container.decode(String.self, forKey: .generator)
        let osm3s = try container.decode(OSM3S.self, forKey: .osm3s)
        let timestamp = osm3s.timestamp_osm_base
        let copyright = osm3s.copyright

        let elements = try container.decode([Element].self, forKey: .elements)
        self.init(version: version, generator: generator, timestamp: timestamp, copyright: copyright, elements: elements)
    }
}

private struct OSM3S: Decodable {
    let timestamp_osm_base: Date
    let copyright: String
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

    public private(set) var nodes: [Node] = []

    public mutating func add(nodes: [Node]) {
        self.nodes = []
        for id in self.nodeIds {
            if let node = nodes.first(where: { $0.id == id }) {
                self.nodes.append(node)
            }
        }
    }

    fileprivate func with(nodes: [Node]) -> Way {
        var way = Way(id: self.id, nodeIds: self.nodeIds, tags: self.tags)

        way.add(nodes: nodes)

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

public struct Relation: Equatable {
    public var id: Int
    public var members: [Element]
    public var tags: [String: String]

    public static func == (lhs: Relation, rhs: Relation) -> Bool {
        return false
    }
}

public indirect enum Element: Decodable, Equatable {
    case node(Node)
    case way(Way)
    case relation(Element)

    private enum ElementKind: String, Decodable {
        case way
        case node
        // Relation is not yet supported.
    }


    enum CodingKeys : String, CodingKey {
        case id
        case type
        case tags
        case nodes
    }

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let jsonType = try container.decode(ElementKind.self, forKey: .type)
        let id = try container.decode(Int.self, forKey: .id)
        let tags = try container.decodeIfPresent([String: String].self, forKey: .tags) ?? [:]

        switch jsonType {
        case .node:
            let location = try Location(from: decoder)
            self = .node(Node(id: id, location: location, tags: tags))
        case .way:
            let nodes = try container.decode([Int].self, forKey: .nodes)
            self = .way(Way(id: id, nodeIds: nodes, tags: tags))
        }
    }
}

public struct Location: Decodable, Equatable {
    public var latitude: Double
    public var longitude: Double

    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    enum CodingKeys : String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
