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

        describe("Element") {
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

                    let element = Node(
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    expect(json.Element) == .node(element)
                }
                
                it("works with type node without tags") {
                    let json = JSON([
                        "type": "node",
                        "id": 34,
                        "lat": 7.125,
                        "lon": 8.75
                        ])
                    
                    let element = Node(
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: [:]
                    )
                    
                    expect(json.Element) == .node(element)
                }

                it("works with type way") {
                    /*
                     "id" : 480943143,
                     "tags" : {
                        "leisure" : "pitch",
                        "sport" : "basketball"
                     },
                     "type" : "way",
                     "nodes" : [
                        4738881721,
                        4738881722,
                        4738881723,
                        4738881724,
                        4738881721
                     ]
                     */
                    let json = JSON([
                        "type": "way",
                        "id": 35,
                        "tags": [
                            "a": "tag",
                            "other": "tag"
                        ],
                        "nodes": [
                            21,
                            22,
                            23,
                            24,
                            21
                        ]
                    ])

                    let element = Way(
                        id: 35,
                        nodeIds: [21, 22, 23, 24, 21],
                        tags: ["a": "tag", "other": "tag"]
                    )

                    expect(json.Element) == .way(element)
                }
            }
        }

        describe("Way") {
            describe("add(nodes:)") {
                it("fills in the nodes property by correlating nodes with the nodeIds, in that order") {
                    var way = Way(
                        id: 35,
                        nodeIds: [21, 22, 23, 24, 21],
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let nodes: [Node] = [
                        Node(
                            id: 21,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 20,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 24,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 22,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 23,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: [:]
                        ),
                    ]

                    way.add(nodes: nodes)

                    let expectedNodes = [
                        Node(
                            id: 21,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 22,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 23,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: [:]
                        ),
                        Node(
                            id: 24,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 21,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                    ]

                    expect(way.nodes).to(equal(expectedNodes))
                }

                it("tries it's best if it can't fully match up nodes with nodeIds") {
                    var way = Way(
                        id: 35,
                        nodeIds: [21, 22, 23, 24, 21],
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let nodes: [Node] = [
                        Node(
                            id: 21,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                    ]

                    way.add(nodes: nodes)

                    let expectedNodes = [
                        Node(
                            id: 21,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                        Node(
                            id: 21,
                            location: Location(latitude: 7.125, longitude: 8.75),
                            tags: ["a": "tag", "other": "tag"]
                        ),
                    ]

                    expect(way.nodes).to(equal(expectedNodes))
                }
            }
        }

        describe("Response") {
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
                                "id": 35,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ],
                                "nodes": [
                                    34
                                ]
                            ]
                        ]
                    ])

                    let nodeElement = Node(
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let wayElement = Way(
                        id: 35,
                        nodes: [nodeElement],
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let date = dateFormatter.date(from: "2017-04-03T00:00:00Z")!

                    let response = Response(
                        version: "1.0",
                        generator: "A Generator",
                        timestamp: date,
                        copyright: "Copyright whoever",
                        elements: [.node(nodeElement), .way(wayElement)]
                    )
                    
                    expect(json.Response) == response
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
                                "id": 35,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ],
                                "nodes": [
                                    34
                                ]
                            ]
                        ]
                    ])

                    let nodeElement = Node(
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let wayElement = Way(
                        id: 35,
                        nodes: [nodeElement],
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let date = dateFormatter.date(from: "2017-04-03T00:00:00Z")!

                    let response = Response(
                        version: "0.6",
                        generator: "A Generator",
                        timestamp: date,
                        copyright: "Copyright whoever",
                        elements: [.node(nodeElement), .way(wayElement)]
                    )

                    expect(json.Response) == response
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
                                "id": 35,
                                "tags": [
                                    "a": "tag",
                                    "other": "tag"
                                ],
                                "nodes": [
                                    34
                                ]
                            ]
                        ]
                    ])

                    let nodeElement = Node(
                        id: 34,
                        location: Location(latitude: 7.125, longitude: 8.75),
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let wayElement = Way(
                        id: 35,
                        nodes: [nodeElement],
                        tags: ["a": "tag", "other": "tag"]
                    )

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let date = dateFormatter.date(from: "2017-04-03T00:00:00Z")!

                    let response = Response(
                        version: "0.6",
                        generator: "A Generator",
                        timestamp: date,
                        copyright: "Copyright whoever",
                        elements: [.node(nodeElement), .way(wayElement)]
                    )

                    expect(json.Response) == response
                }
            }
        }
    }
}
