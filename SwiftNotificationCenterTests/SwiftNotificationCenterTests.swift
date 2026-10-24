//
//  SwiftNotificationCenterTests.swift
//  SwiftNotificationCenterTests
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Dispatch
import XCTest
@testable import SwiftNotificationCenter

final class SwiftNotificationCenterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        removeAllObservers()
    }

    override func tearDown() {
        removeAllObservers()
        super.tearDown()
    }

    func testNotify() {
        let object = MockClass()
        var count = 0

        Broadcaster.register(MockProtocol.self, observer: object)
        Broadcaster.notify(MockProtocol.self) { observer in
            XCTAssertTrue((observer as AnyObject) === object)
            XCTAssertEqual(observer.hello(), "hello")
            count += 1
        }
        XCTAssertEqual(count, 1)
    }

    func testRemove() {
        let object = MockClass()
        Broadcaster.register(MockProtocol.self, observer: object)
        Broadcaster.unregister(MockProtocol.self, observer: object)
        Broadcaster.notify(MockProtocol.self) { _ in
            XCTFail("An unregistered observer must not be notified")
        }
    }

    func testNotifyWithoutObservers() {
        Broadcaster.notify(MockProtocol.self) { _ in
            XCTFail("There are no registered observers")
        }
    }

    func testNotifiesEveryObserverOnce() {
        let objects = [MockClass(), MockClass(), MockClass()]
        var notified = Set<ObjectIdentifier>()
        var count = 0

        for object in objects {
            Broadcaster.register(MockProtocol.self, observer: object)
        }
        Broadcaster.notify(MockProtocol.self) { observer in
            notified.insert(ObjectIdentifier(observer as AnyObject))
            count += 1
        }

        XCTAssertEqual(notified, Set(objects.map { ObjectIdentifier($0) }))
        XCTAssertEqual(count, objects.count)
    }

    func testDuplicateRegistrationNotifiesOnlyOnce() {
        let object = MockClass()
        var count = 0

        Broadcaster.register(MockProtocol.self, observer: object)
        Broadcaster.register(MockProtocol.self, observer: object)
        withExtendedLifetime(object) {
            Broadcaster.notify(MockProtocol.self) { _ in count += 1 }
        }

        XCTAssertEqual(count, 1)
    }

    func testRemovingOneObserverPreservesOthers() {
        let removed = MockClass()
        let remaining = MockClass()
        var count = 0

        Broadcaster.register(MockProtocol.self, observer: removed)
        Broadcaster.register(MockProtocol.self, observer: remaining)
        Broadcaster.unregister(MockProtocol.self, observer: removed)
        Broadcaster.notify(MockProtocol.self) { observer in
            XCTAssertTrue((observer as AnyObject) === remaining)
            count += 1
        }

        XCTAssertEqual(count, 1)
    }

    func testRemovingAllObserversOnlyAffectsSpecifiedProtocol() {
        let object = MockClass()
        var count = 0

        Broadcaster.register(MockProtocol.self, observer: object)
        Broadcaster.register(OtherMockProtocol.self, observer: object)
        Broadcaster.unregister(MockProtocol.self)

        Broadcaster.notify(MockProtocol.self) { _ in
            XCTFail("All observers for this protocol were removed")
        }
        Broadcaster.notify(OtherMockProtocol.self) { observer in
            XCTAssertTrue((observer as AnyObject) === object)
            count += 1
        }

        XCTAssertEqual(count, 1)
    }

    func testReleasedObserversAreNotRetainedOrNotified() {
        var object: MockClass? = MockClass()
        let weakObject = WeakObject(object!)

        Broadcaster.register(MockProtocol.self, observer: object!)
        // Drain the asynchronous registration before releasing our reference.
        Broadcaster.notify(MockProtocol.self) { _ in }
        object = nil

        XCTAssertNil(weakObject.object)
        Broadcaster.notify(MockProtocol.self) { _ in
            XCTFail("Released observers must not be notified")
        }
    }

    func testObserverCanUnregisterDuringNotification() {
        let object = MockClass()
        var count = 0

        Broadcaster.register(MockProtocol.self, observer: object)
        withExtendedLifetime(object) {
            Broadcaster.notify(MockProtocol.self) { observer in
                count += 1
                Broadcaster.unregister(MockProtocol.self, observer: observer)
            }
            Broadcaster.notify(MockProtocol.self) { _ in
                XCTFail("The observer unregistered during the previous notification")
            }
        }

        XCTAssertEqual(count, 1)
    }

    func testConcurrentRegistrationAndRemoval() {
        let objects = (0..<100).map { _ in MockClass() }
        let queue = DispatchQueue(label: "SwiftNotificationCenterTests.concurrent", attributes: .concurrent)
        let group = DispatchGroup()

        for object in objects {
            queue.async(group: group) {
                Broadcaster.register(MockProtocol.self, observer: object)
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)

        var count = 0
        Broadcaster.notify(MockProtocol.self) { _ in count += 1 }
        XCTAssertEqual(count, objects.count)

        for object in objects {
            queue.async(group: group) {
                Broadcaster.unregister(MockProtocol.self, observer: object)
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        Broadcaster.notify(MockProtocol.self) { _ in
            XCTFail("All concurrently registered observers were removed")
        }
    }

    func testWeakObjectSetDeduplicatesAndRemovesObjects() {
        let first = MockClass()
        let second = MockClass()
        var objects = WeakObjectSet([first, second, first])

        XCTAssertEqual(objects.allObjects.count, 2)
        XCTAssertTrue(objects.contains(first))
        objects.add(first)
        XCTAssertEqual(Array(objects).count, 2)
        objects.remove(first)
        XCTAssertFalse(objects.contains(first))
        XCTAssertTrue(objects.contains(second))
        objects.remove([second])
        XCTAssertTrue(objects.allObjects.isEmpty)
    }

    func testWeakObjectSetOmitsReleasedObjects() {
        var object: MockClass? = MockClass()
        let weakObject = WeakObject(object!)
        let objects = WeakObjectSet(object!)

        object = nil

        XCTAssertNil(weakObject.object)
        XCTAssertTrue(objects.allObjects.isEmpty)
        XCTAssertTrue(Array(objects).isEmpty)
    }

    private func removeAllObservers() {
        Broadcaster.unregister(MockProtocol.self)
        Broadcaster.unregister(OtherMockProtocol.self)
        // A synchronous read waits for the queued barrier writes to finish.
        Broadcaster.notify(MockProtocol.self) { _ in }
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

protocol OtherMockProtocol: AnyObject {
}

final class MockClass: MockProtocol, OtherMockProtocol {
}
