//
//  WeakObjectSet.swift
//  SwiftNotificationCenter
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation

struct WeakObject<T: AnyObject>: Equatable, Hashable {
    private let identifier: ObjectIdentifier
    weak var object: T?
    init(_ object: T) {
        self.object = object
        self.identifier = ObjectIdentifier(object)
    }
    
    var hashValue: Int {
        return self.identifier.hashValue
    }
    
    static func == (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct WeakObjectSet<T: AnyObject>: Sequence {
    
    var objects: Set<WeakObject<T>>
    
    init() {
        self.objects = Set<WeakObject<T>>([])
    }
    
    init(_ object: T) {
        self.objects = Set<WeakObject<T>>([WeakObject(object)])
    }
    
    init(_ objects: [T]) {
        self.objects = Set<WeakObject<T>>(objects.map { WeakObject($0) })
    }
    
    var allObjects: [T] {
        #if swift(>=4.1)
            return objects.compactMap { $0.object }
        #else
            return objects.flatMap { $0.object }
        #endif
    }
    
    func contains(_ object: T) -> Bool {
        return self.objects.contains(WeakObject(object))
    }
    
    mutating func add(_ object: T) {
        //prevent ObjectIdentifier be reused
        if self.contains(object) {
            self.remove(object)
        }
        self.objects.insert(WeakObject(object))
    }
    
    mutating func add(_ objects: [T]) {
        objects.forEach { self.add($0) }
    }
    
    mutating func remove(_ object: T) {
        self.objects.remove(WeakObject<T>(object))
    }
    
    mutating func remove(_ objects: [T]) {
        objects.forEach { self.remove($0) }
    }
    
    func makeIterator() -> AnyIterator<T> {
        let objects = self.allObjects
        var index = 0
        return AnyIterator {
            defer { index += 1 }
            return index < objects.count ? objects[index] : nil
        }
    }
}
