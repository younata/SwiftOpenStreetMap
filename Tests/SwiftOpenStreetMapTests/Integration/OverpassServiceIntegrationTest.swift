import Quick
import Nimble
import Foundation

import CBGPromise
import Result

import FutureHTTP
@testable import SwiftOpenStreetMap

class OverpassServiceIntegrationTest: QuickSpec {
    override func spec() {
        var subject: DefaultOverpassService!

        let baseURL = URL(string: "https://overpass-api.de/api/interpreter")!
        let httpClient = URLSession(configuration: URLSessionConfiguration.default)

        beforeEach {
            subject = DefaultOverpassService(baseURL: baseURL, httpClient: httpClient)
        }

        it("can get nodes") {
            // Moscone Convention Center, SF
            let south = 37.7821513749276
            let west = -122.403833425193
            let north = 37.7842669776393
            let east = -122.402116811508
            let result = subject.query("node(\(south),\(west),\(north),\(east));").wait()!

            expect(result.error).to(beNil())
        }
    }
}
