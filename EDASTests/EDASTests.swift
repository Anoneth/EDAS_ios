//
//  EDASTests.swift
//  EDASTests
//
//  Created by Bla bla on 14.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import XCTest
@testable import EDAS

class EDASTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tokenHolder = TokenHolder()
        tokenHolder.setToken(token: "testtoken")
        XCTAssert(tokenHolder.token == "testtoken")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
