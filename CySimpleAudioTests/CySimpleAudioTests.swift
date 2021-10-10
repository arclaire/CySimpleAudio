//
//  CySimpleAudioTests.swift
//  CySimpleAudioTests
//
//  Created by Lucy on 08/10/21.
//

import XCTest
@testable import CySimpleAudio

class CySimpleAudioTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testPlay(){
        let vc = ViewController()
        let str = "https://p.scdn.co/mp3-preview/1eff24b8ac660e8f7db44f81a6e7eced697e4a06?cid=21ce98fbb8cb43468ab444e8c3016e96"
        if let _ = URL(string: str) {
            XCTAssert(true, "A Valid URL can be stream")
        } else {
            XCTAssert(false, "Invalid URL")
        }
    }

    func testTokenExpired(){
        let vc = ViewController()

        if vc.isTokenExpired() {
            XCTAssert(true, "TokenExpire recall token api")
        }
    }



}
