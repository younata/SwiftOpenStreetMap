import Quick
import Nimble
import Foundation
import SwiftyJSON

@testable import SwiftOpenStreetMap

class ModelsTest: QuickSpec {
    override func spec() {
        describe("Location") {
            describe("init(json:)") {
                it("works with lat and lon") {
                    let json = JSON(["lat": 6.5, "lon": 7.5])

                    let location = Location(latitude: 6.5, longitude: 7.5)

                    expect(json.location) == location
                }
            }
        }

        describe("OverpassElement") {
            describe("init(json:)") {
                it("works with type node") {
                    let json = JSON([
                        "type": "node",
                        "id": 34,
                        "lat": 7.125,
                        "lon": 8.75,
                        "tags": [
                            "a": "tag",
                            "other": "tag"
                        ]
                    ])

                    let element = OverpassElement(
                        type: .node,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    expect(json.overpassElement) == element
                }

                it("works with type way") {
                    let json = JSON([
                        "type": "way",
                        "id": 34,
                        "lat": 7.125,
                        "lon": 8.75,
                        "tags": [
                            "a": "tag",
                            "other": "tag"
                        ]
                    ])

                    let element = OverpassElement(
                        type: .way,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    expect(json.overpassElement) == element
                }

                it("works with type relation") {
                    let json = JSON([
                        "type": "relation",
                        "id": 34,
                        "lat": 7.125,
                        "lon": 8.75,
                        "tags": [
                            "a": "tag",
                            "other": "tag"
                        ]
                    ])

                    let element = OverpassElement(
                        type: .relation,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    expect(json.overpassElement) == element
                }
            }
        }

        describe("OverpassResponse") {
            describe("init(json:)") {

                it("handles the case where version is an int") {
                    let json = JSON([
                        "version": 1,
                        "generator": "A Generator",
                        "osm3s": [
                            "timestamp_osm_base": "2017-04-03T00:00:00Z",
                            "copyright": "Copyright whoever",
                        ],
                        "elements": [
                            [
                                "type": "node",
                                "id": 34,
                                "lat": 7.125,
                                "lon": 8.75,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ]
                            ],
                            [
                                "type": "way",
                                "id": 34,
                                "lat": 7.125,
                                "lon": 8.75,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ]
                            ]
                        ]
                    ])

                    let nodeElement = OverpassElement(
                        type: .node,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let wayElement = OverpassElement(
                        type: .way,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let date = dateFormatter.date(from: "2017-04-03T00:00:00Z")!

                    let response = OverpassResponse(
                        version: "1.0",
                        generator: "A Generator",
                        timestamp: date,
                        copyright: "Copyright whoever",
                        elements: [nodeElement, wayElement]
                    )
                    
                    expect(json.overpassResponse) == response
                }

                it("handles the case where version is a double") {
                    /*
                     "version": 0.6,
                     "generator": "Overpass API",
                     "osm3s": {
                     "timestamp_osm_base": "2017-04-03T18:28:02Z",
                     "copyright": "The data included in this document is from www.openstreetmap.org. The data is made available under ODbL."
                     },
                     "elements"
                     */
                    let json = JSON([
                        "version": 0.6,
                        "generator": "A Generator",
                        "osm3s": [
                            "timestamp_osm_base": "2017-04-03T00:00:00Z",
                            "copyright": "Copyright whoever",
                        ],
                        "elements": [
                            [
                                "type": "node",
                                "id": 34,
                                "lat": 7.125,
                                "lon": 8.75,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ]
                            ],
                            [
                                "type": "way",
                                "id": 34,
                                "lat": 7.125,
                                "lon": 8.75,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ]
                            ]
                        ]
                    ])

                    let nodeElement = OverpassElement(
                        type: .node,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let wayElement = OverpassElement(
                        type: .way,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let date = dateFormatter.date(from: "2017-04-03T00:00:00Z")!

                    let response = OverpassResponse(
                        version: "0.6",
                        generator: "A Generator",
                        timestamp: date,
                        copyright: "Copyright whoever",
                        elements: [nodeElement, wayElement]
                    )

                    expect(json.overpassResponse) == response
                }

                it("handles the case where version is a string") {
                    let json = JSON([
                        "version": "0.6",
                        "generator": "A Generator",
                        "osm3s": [
                            "timestamp_osm_base": "2017-04-03T00:00:00Z",
                            "copyright": "Copyright whoever",
                        ],
                        "elements": [
                            [
                                "type": "node",
                                "id": 34,
                                "lat": 7.125,
                                "lon": 8.75,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ]
                            ],
                            [
                                "type": "way",
                                "id": 34,
                                "lat": 7.125,
                                "lon": 8.75,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ]
                            ]
                        ]
                    ])

                    let nodeElement = OverpassElement(
                        type: .node,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let wayElement = OverpassElement(
                        type: .way,
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let date = dateFormatter.date(from: "2017-04-03T00:00:00Z")!

                    let response = OverpassResponse(
                        version: "0.6",
                        generator: "A Generator",
                        timestamp: date,
                        copyright: "Copyright whoever",
                        elements: [nodeElement, wayElement]
                    )

                    expect(json.overpassResponse) == response
                }
            }
        }
    }
}
