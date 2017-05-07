# SwiftOpenStreetMap

A Swift-based interface to the [OpenStreetMap Overpass API](http://wiki.openstreetmap.org/wiki/Overpass_API).

## Usage

The simple way is to compose the `nodeQuery(boundingBox:tags:)` or `wayQuery(boundingBox:tags:)` functions with an `OverpassService` object (provided is the `DefaultOverpassService` implementation, like so:

```swift
let baseURL = URL(string: "https://example.com/overpass_api")!
let httpClient = URLSession(configuration: URLSessionConfiguration.default)

let service = DefaultOverpassService(baseURL: baseURL, httpClient: httpClient)

let boundingBox = BoundingBox(south: 1.5, west: 1.75, north: 2.5, east: 2.75)
let tags: Set<Tag> = [.hasKey("hello"), .hasValue(key: "good", value: "bye")]

let query = nodeQuery(boundingBox: boundingBox, tags: tags)

service.query(query).then { res: Result<Response, OverpassServiceError> in
    dump(res)
}
```

### Hard Mode

the `OverpassService` protocol also provides a way for you to look at the raw JSON response, for debugging (or maybe you're just interested in that). Additionally, you can pass in your own queries, as `nodeQuery(boundingBox:tags:)` and `wayQuery(boundingBox:tags:)` are both relatively simple query generators.

## License

[MIT](LICENSE)