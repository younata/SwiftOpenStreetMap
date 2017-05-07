import Quick
import Nimble
@testable import SwiftOpenStreetMap

class QueryBuilderTest: QuickSpec {
    override func spec() {
        describe("nodeQuery(boundingBox:tags:)") {
            it("produces a non-recursive query for nodes matching the given strings and bounding box") {
                let boundingBox = BoundingBox(south: 1.5, west: 1.75, north: 2.5, east: 2.75)
                let tags: Set<Tag> = [.hasKey("hello"), .hasValue(key: "good", value: "bye")]

                let query = nodeQuery(boundingBox: boundingBox, tags: tags)

                expect(query).to(equal("node[\"good\"=\"bye\"][\"hello\"](1.5, 1.75, 2.5, 2.75);"))
            }
        }

        describe("wayQuery(boundingBox:tags:)") {
            it("produces a recursive query for nodes matching the given strings and bounding box") {
                let boundingBox = BoundingBox(south: 1.5, west: 1.75, north: 2.5, east: 2.75)
                let tags: Set<Tag> = [.hasKey("hello"), .hasValue(key: "good", value: "bye")]

                let query = wayQuery(boundingBox: boundingBox, tags: tags)

                expect(query).to(equal("way[\"good\"=\"bye\"][\"hello\"](1.5, 1.75, 2.5, 2.75);(._;>;);"))
            }
        }

        describe("Tag") {
            describe("not inverted") {
                it("hasKey") {
                    expect(Tag.hasKey("a key").isValid()).to(beTruthy())
                    expect(Tag.hasKey("a key").query()).to(equal("[\"a key\"]"))
                }

                it("hasValue") {
                    expect(Tag.hasValue(key: "a key", value: "a value").isValid()).to(beTruthy())
                    expect(Tag.hasValue(key: "a key", value: "a value").query()).to(equal("[\"a key\"=\"a value\"]"))
                }

                it("matchesValue") {
                    expect(Tag.matchesValue(key: "a key", value: "a value").isValid()).to(beTruthy())
                    expect(Tag.matchesValue(key: "a key", value: "a value").query()).to(equal("[\"a key\"~\"a value\"]"))
                }

                it("matchesKeyAndValue") {
                    expect(Tag.matchesKeyAndValue(key: "a key", value: "a value").isValid()).to(beTruthy())
                    expect(Tag.matchesKeyAndValue(key: "a key", value: "a value").query()).to(equal("[~\"a key\"~\"a value\"]"))
                }
            }

            describe("inverted") {
                it("hasKey") {
                    expect(Tag.not(.hasKey("a key")).isValid()).to(beTruthy())
                    expect(Tag.not(.hasKey("a key")).query()).to(equal("[!\"a key\"]"))
                }

                it("hasValue") {
                    expect(Tag.not(.hasValue(key: "a key", value: "a value")).isValid()).to(beTruthy())
                    expect(Tag.not(.hasValue(key: "a key", value: "a value")).query()).to(equal("[\"a key\"!=\"a value\"]"))
                }

                it("matchesValue") {
                    expect(Tag.not(.matchesValue(key: "a key", value: "a value")).isValid()).to(beTruthy())
                    expect(Tag.not(.matchesValue(key: "a key", value: "a value")).query()).to(equal("[\"a key\"!~\"a value\"]"))
                }

                it("considers multiple inversion levels as invalid") {
                    expect(Tag.not(.not(.hasKey(""))).isValid()).to(beFalsy())
                    expect(Tag.not(.not(.hasKey(""))).query()).to(equal(""))
                }

                it("considers inverted matchesKeyAndValue as invalid") {
                    expect(Tag.not(.matchesKeyAndValue(key: "", value: "")).isValid()).to(beFalsy())
                    expect(Tag.not(.matchesKeyAndValue(key: "", value: "")).query()).to(equal(""))
                }
            }
        }
    }
}
