import Quick
import Nimble

@testable import SwiftOpenStreetMapTests

Quick.QCKMain([
        ModelsTest.self,
        OverpassServiceTest.self,
    ],
    testCases: [
        testCase(ModelsTest.allTests),
        testCase(OverpassServiceTest.allTests),
    ]
)
