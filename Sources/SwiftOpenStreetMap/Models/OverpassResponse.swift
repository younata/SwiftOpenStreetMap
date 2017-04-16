import Foundation
import SwiftyJSON

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}()

public struct OverpassResponse: Equatable {
    public var version: String
    public var generator: String
    public var timestamp: Date
    public var copyright: String

    public var elements: [OverpassElement]

    public static func == (lhs: OverpassResponse, rhs: OverpassResponse) -> Bool {
        return lhs.version == rhs.version &&
            lhs.generator == rhs.generator &&
            lhs.timestamp == rhs.timestamp &&
            lhs.copyright == rhs.copyright &&
            lhs.elements == rhs.elements
    }

    public init(version: String, generator: String, timestamp: Date, copyright: String, elements: [OverpassElement]) {
        self.version = version
        self.generator = generator
        self.timestamp = timestamp
        self.copyright = copyright
        self.elements = elements
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

        let elements = elementsArray.flatMap { $0.overpassElement }

        self.init(version: version, generator: generator, timestamp: date, copyright: copyright, elements: elements)
    }
}

public struct OverpassElement: Equatable {
    public enum ElementType: String {
        case node
        case way
        case relation
    }

    public var type: ElementType
    public var id: Int
    public var location: Location
    public var tags: [String: String]

    public static func == (lhs: OverpassElement, rhs: OverpassElement) -> Bool {
        return lhs.type == rhs.type &&
            lhs.id == rhs.id &&
            lhs.location == rhs.location &&
            lhs.tags == rhs.tags
    }

    public init(type: ElementType, id: Int, location: Location, tags: [String: String]) {
        self.type = type
        self.id = id
        self.location = location
        self.tags = tags
    }

    fileprivate init?(json: JSON) {
        guard let jsonType = json["type"].string, let type = ElementType(rawValue: jsonType),
            let id = json["id"].int,
            let jsonTags = json["tags"].dictionary,
            let location = json.location else {
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

        self.init(type: type, id: id, location: location, tags: tags)
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
    public var overpassResponse: OverpassResponse? { return OverpassResponse(json: self) }
    public var overpassElement: OverpassElement? { return OverpassElement(json: self) }
    public var location: Location? { return Location(json: self) }
}
