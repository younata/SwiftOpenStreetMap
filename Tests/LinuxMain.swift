import XCTest
import Quick
import Nimble

@testable import SwiftOpenStreetMapTests

Quick.QCKMain([
        ModelsTest.self,
        OverpassServiceTest.self,
        OverpassServiceIntegrationTest.self,
        QueryBuilderTest.self,
    ],
    testCases: [
        testCase(ModelsTest.allTests),
        testCase(OverpassServiceTest.allTests),
        testCase(OverpassServiceIntegrationTest.allTests),
        testCase(QueryBuilderTest.allTests),
    ]
)
