public func nodeQuery(boundingBox: BoundingBox, tags: Set<Tag>) -> String {
    return buildQuery(of: .node, recursive: false, boundingBox: boundingBox, tags: tags)
}

public func wayQuery(boundingBox: BoundingBox, tags: Set<Tag>) -> String {
    return buildQuery(of: .way, recursive: true, boundingBox: boundingBox, tags: tags)
}


public struct BoundingBox {
    public var south: Double
    public var west: Double
    public var north: Double
    public var east: Double

    public init(south: Double, west: Double, north: Double, east: Double) {
        self.south = south
        self.west = west
        self.north = north
        self.east = east
    }

    public var query: String { return "(\(south), \(west), \(north), \(east))" }
}

public indirect enum Tag: Hashable {
    case not(Tag)
    case hasKey(String)
    case hasValue(key: String, value: String)
    case matchesValue(key: String, value: String)
    case matchesKeyAndValue(key: String, value: String)

    public func isValid() -> Bool {
        switch self {
        case .not(.not(_)):
            return false
        case .not(.matchesKeyAndValue(key: _, value: _)):
            return false
        default:
            return true
        }
    }

    public var hashValue: Int {
        switch self {
        case .hasKey(let key):
            return 2 ^ key.hashValue
        case .hasValue(key: let key, value: let value):
            return 4 ^ key.hashValue ^ value.hashValue
        case .matchesValue(key: let key, value: let value):
            return 8 ^ key.hashValue ^ value.hashValue
        case .matchesKeyAndValue(key: let key, value: let value):
            return 16 ^ key.hashValue ^ value.hashValue
        case .not(let tag):
            return 32 ^ tag.hashValue
        }
    }

    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        guard lhs.isValid() && rhs.isValid() else { return false }

        switch (lhs, rhs) {
        case (.not(let lhsTag), .not(let rhsTag)):
            return lhsTag == rhsTag
        case (.hasKey(let lhsKey), .hasKey(let rhsKey)):
            return lhsKey == rhsKey
        case (let .hasValue(key: lhsKey, value: lhsValue), let .hasValue(key: rhsKey, value: rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        case (let .matchesValue(key: lhsKey, value: lhsValue), let .matchesValue(key: rhsKey, value: rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        case (let .matchesKeyAndValue(key: lhsKey, value: lhsValue), let .matchesKeyAndValue(key: rhsKey, value: rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        default:
            return false
        }
    }

    func query() -> String {
        switch self {
        case .hasKey(let key):
            return "[\"\(key)\"]"
        case .hasValue(key: let key, value: let value):
            return "[\"\(key)\"=\"\(value)\"]"
        case .matchesValue(key: let key, value: let value):
            return "[\"\(key)\"~\"\(value)\"]"
        case .matchesKeyAndValue(key: let key, value: let value):
            return "[~\"\(key)\"~\"\(value)\"]"

        case .not(.hasKey(let key)):
            return "[!\"\(key)\"]"
        case .not(.hasValue(key: let key, value: let value)):
            return "[\"\(key)\"!=\"\(value)\"]"
        case .not(.matchesValue(key: let key, value: let value)):
            return "[\"\(key)\"!~\"\(value)\"]"

        default:
            return ""
        }
    }
}

private func buildQuery(of type: ElementType, recursive: Bool, boundingBox: BoundingBox, tags: Set<Tag>) -> String {
    let tagsString = tags.map({ $0.query() }).sorted().joined()
    if type == .node {
        guard !recursive else { fatalError("not yet supported") }

        return "\(type)\(tagsString)\(boundingBox.query);"
    }
    else if type == .way {
        guard recursive else { fatalError("not yet supported") }

        return "\(type)\(tagsString)\(boundingBox.query);(._;>;);"
    }
    return ""
}

private enum ElementType: String {
    case node
    case way
}
