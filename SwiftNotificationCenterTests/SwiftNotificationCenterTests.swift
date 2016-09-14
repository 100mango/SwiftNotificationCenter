//
//  SwiftNotificationCenterTests.swift
//  SwiftNotificationCenterTests
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import XCTest
@testable import SwiftNotificationCenter

class SwiftNotificationCenterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testNotify() {
        let object = MockClass()
        
        NotificationCenter.register(MockProtocol.self, observer: object)
        NotificationCenter.notify(MockProtocol.self) { observer in
            let string = observer.hello()
            XCTAssertTrue(string == "hello")
        }
    }
}

protocol MockProtocol {
    func hello() -> String
}

extension MockProtocol {
    func hello() -> String {
        return "hello"
    }
}

class MockClass: MockProtocol {
}

